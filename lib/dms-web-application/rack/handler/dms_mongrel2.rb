# Copyright (c) 2012 Jakub Pastuszek
#
# This file is part of Distributed Monitoring System.
#
# Distributed Monitoring System is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Distributed Monitoring System is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Distributed Monitoring System.  If not, see <http://www.gnu.org/licenses/>.
#
require 'multi_json'
require 'tnetstring'
require 'rack'

module Rack
	module Handler
		class DMSMongrel2
			class MissingOptionError < ArgumentError
				def initialize(opt_name, env_name)
					super "must specify an #{opt_name} or ENV variable #{env_name}"
				end
			end

			class Request
				def self.parse(msg)
					# UUID CONN_ID PATH SIZE:HEADERS,SIZE:BODY,
					uuid, conn_id, path, rest = msg.split(' ', 4)
					headers, rest = TNetstring.parse(rest)
					headers = MultiJson.load(headers)
					body, _ = TNetstring.parse(rest)

					self.new(uuid, conn_id, path, headers, body)
				end

				def initialize(uuid, conn_id, path, headers, body)
					@uuid = uuid
					@conn_id = conn_id
					@path = path
					@body = body
					@headers = headers

					if json?
						@body = MultiJson.load(body)
						return
					end

					script_name = headers.delete('PATTERN').scan(/.*(?=\/\(?)/).first
					@env = {
							'rack.version' => Rack::VERSION,
							'rack.url_scheme' => 'http',
							'rack.input' => @body,
							'rack.errors' => $stderr,
							'rack.multithread' => true,
							'rack.multiprocess' => true,
							'rack.run_once' => false,
							'REQUEST_METHOD' => headers.delete('METHOD'),
							'SCRIPT_NAME' => Rack::Utils.unescape(script_name),
							'PATH_INFO' => Rack::Utils.unescape(headers.delete('PATH')[script_name.length..-1] || ''), 
							'QUERY_STRING' => headers.delete('QUERY') || ''
						}
						@env['SERVER_NAME'], @env['SERVER_PORT'] = headers['host'].split(':', 2)
						headers.delete('URI') # no use
						headers.delete('VERSION') # no use

						headers.each_pair do |key, value|
							@env["HTTP_" + key.upcase.gsub('-', '_')] = value
						end
				end

				def json?
					@headers['METHOD'] == 'JSON'
				end

				def disconnect?
					@body.is_a? Hash and @body['type'] == 'disconnect'
				end

				attr_reader :uuid
				attr_reader :conn_id
				attr_reader :env
			end

			class Response
				def self.header(uuid, conn_id, status, headers)
					headers = headers.map{ |k, v| "#{k}: #{v}" }.join("\r\n")
					self.new(uuid, conn_id, "HTTP/1.1 #{status.to_i} #{Rack::Utils::HTTP_STATUS_CODES[status.to_i]}\r\n#{headers}\r\n\r\n")
				end

				def self.body(uuid, conn_id, body)
					self.new(uuid, conn_id, body)
				end

				def self.close(uuid, conn_id)
					self.new(uuid, conn_id, '')
				end

				def initialize(uuid, conn_id, data)
					@uuid = uuid
					@conn_id = [conn_id].flatten
					@data = data
				end

				def to_string
					"#{@uuid} #{TNetstring.dump(@conn_id.join(' '))} #{@data}"
				end
			end

			class Server
				def initialize(recv_address, send_address, zeromq, poller, app)
					@recv_address = recv_address
					@send_address = send_address
					@zmq = zeromq
					@poller = poller
					@app = app
				end

				def start
					log.info 'starting Rack handler'
					@zmq.pull_connect(@recv_address) do |pull|
						@zmq.pub_connect(@send_address) do |pub|
							pull.on :raw do |msg|
								log.debug "got Mongrel2 request: #{msg}"
								request = Request.parse(msg)
								if request.disconnect?
									log.debug "client connection lost"
									next
								end

								status, headers, response = @app.call(request.env)

								begin
									log.debug "sending header: #{headers}"
									pub.send Response.header(request.uuid, request.conn_id, status, headers).to_string

									response.each do |body|
										#log.debug "sending body: #{body}"
										pub.send Response.body(request.uuid, request.conn_id, body).to_string
									end
								ensure
									if response.respond_to? :callback
										response.callback do
											log.debug "sending closed"
											pub.send Response.close(request.uuid, request.conn_id).to_string
										end
									else
										log.debug "sending done"
										pub.send Response.close(request.uuid, request.conn_id).to_string
										response.close if response.respond_to? :close
									end
								end
							end

							@poller << pull
							@poller.poll!
						end
					end
				end

				def stop
					log.info 'stopping Rack handler'
				end
			end

			def self.run(app, options = {})
				options = {
					:recv_address => ENV['RACK_MONGREL2_RECV'],
					:send_address => ENV['RACK_MONGREL2_SEND'],
				}.merge(options)

				raise MissingOptionError.new('recv_address', 'RACK_MONGREL2_RECV') unless options[:recv_address]
				raise MissingOptionError.new('send_address', 'RACK_MONGREL2_SEND') unless options[:send_address]

				server = Server.new(options[:recv_address], options[:send_address], ZeroMQService.zeromq, ZeroMQService.poller, app)
				yield server if block_given?
				server.start
			end
		end
	end
end

