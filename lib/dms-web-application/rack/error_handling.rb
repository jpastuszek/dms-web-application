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
module Rack
	class ErrorHandling
		class ErrorReporter < Cuba; end
		def initialize(app, &block)
			@app = app
			@handler = ErrorReporter.define do
				def error(klass)
					env["EXCEPTION"].is_a? klass
				end

				instance_eval &block if block

				on default do
					res.status = 500
					res.write "error: #{env["EXCEPTION"]}"
				end
			end
		end

		def call(env)
			begin
				@app.call(env)
			rescue => e
				env["EXCEPTION"] = e
				log.error "Error while processing request: #{env["PATH_INFO"]}", e
				@handler.call(env)
			end
		end
	end
end

