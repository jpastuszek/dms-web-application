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

module Rack
	module Handler
		class Mongrel2BuiltIn
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
					headers = MultiJson.decode(headers)
					body, _ = TNetstring.parse(rest)

					self.new(uuid, conn_id, path, headers, body)
				end

				def initialize(uuid, conn_id, path, headers, body)
					@uuid = uuid
					@conn_id = conn_id
					@path = path
					@body = body

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
							'SCRIPT_NAME' => script_name,
							'PATH_INFO' => headers.delete('PATH')[script_name.length..-1], 
							'QUERY_STRING' => headers.delete('QUERY') || ''
						}
						@env['SERVER_NAME'], @env['SERVER_PORT'] = headers['host'].split(':', 2)
						headers.delete('URI') # no use
						headers.delete('VERSION') # no use

						headers.each_pair do |key, value|
							@env["HTTP_" + key.upcase.gsub('-', '_')] = value
						end
				end

				attr_reader :uuid
				attr_reader :conn_id
				attr_reader :env
			end

			class Response
				StatusMessage = {
					100 => 'Continue',
					101 => 'Switching Protocols',
					200 => 'OK',
					201 => 'Created',
					202 => 'Accepted',
					203 => 'Non-Authoritative Information',
					204 => 'No Content',
					205 => 'Reset Content',
					206 => 'Partial Content',
					300 => 'Multiple Choices',
					301 => 'Moved Permanently',
					302 => 'Found',
					303 => 'See Other',
					304 => 'Not Modified',
					305 => 'Use Proxy',
					307 => 'Temporary Redirect',
					400 => 'Bad Request',
					401 => 'Unauthorized',
					402 => 'Payment Required',
					403 => 'Forbidden',
					404 => 'Not Found',
					405 => 'Method Not Allowed',
					406 => 'Not Acceptable',
					407 => 'Proxy Authentication Required',
					408 => 'Request Timeout',
					409 => 'Conflict',
					410 => 'Gone',
					411 => 'Length Required',
					412 => 'Precondition Failed',
					413 => 'Request Entity Too Large',
					414 => 'Request-URI Too Large',
					415 => 'Unsupported Media Type',
					416 => 'Request Range Not Satisfiable',
					417 => 'Expectation Failed',
					500 => 'Internal Server Error',
					501 => 'Not Implemented',
					502 => 'Bad Gateway',
					503 => 'Service Unavailable',
					504 => 'Gateway Timeout',
					505 => 'HTTP Version Not Supported'
				}

				def self.header(uuid, conn_id, status, headers)
					headers = headers.map{ |k, v| "#{k}: #{v}" }.join("\r\n")
					self.new(uuid, conn_id, "HTTP/1.1 #{status.to_i} #{StatusMessage[status.to_i]}\r\n#{headers}\r\n\r\n")
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
							pull.on_raw do |msg|
								log.debug "got Mongrel2 request: #{msg}"
								request = Request.parse(msg)

								status, headers, response = @app.call(request.env)

								begin
									pub.send_raw Response.header(request.uuid, request.conn_id, status, headers).to_string

									response.each do |body|
										pub.send_raw Response.body(request.uuid, request.conn_id, body).to_string
									end
								ensure
									pub.send_raw Response.close(request.uuid, request.conn_id).to_string
									response.close if response.respond_to? :close
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

