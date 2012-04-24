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
		end

		def call(env)
			begin
				return @app.call(env)
			rescue => e
				env["ERROR"] = e
				log.error "Error while processing request: #{env['SCRIPT_NAME'] + env["PATH_INFO"]}", e
				begin
					# call app to handle the error
					return @app.call(env)
				rescue => e
					log.fatal "Error while handling error #{env["ERROR"]}: #{env['SCRIPT_NAME'] + env["PATH_INFO"]}", e
					raise 
				end
			end
		end
	end
end

