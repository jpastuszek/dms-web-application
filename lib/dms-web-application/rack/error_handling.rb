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
		def initialize(app, &block)
			@app = app
		end

		def call(env)
			# save original env
			orig_env = env.dup
			begin
				return @app.call(env)
			rescue => error
				log.error "Error while processing request: #{env['SCRIPT_NAME']}[#{env["PATH_INFO"]}]", error
				begin
					# reset env to original since it could have been changed
					env.clear
					env.merge!(orig_env)

					# set error so app can handle it
					env["ERROR"] = error

					return @app.call(env)
				rescue => fatal
					log.fatal "Error while handling error #{env["ERROR"]}: #{env['SCRIPT_NAME']}[#{env["PATH_INFO"]}]", fatal
					raise 
				end
			end
		end
	end
end

