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
module Streaming
	class Stream
		def initialize(&app)
			@app = app
			@callbacks = []
		end

		def each(&server)
			@server = server
			@app.call
		end

		# called by Response#write
		def <<(str)
			@server.call(str)
		end

		def callback(&callback)
			@callbacks << callback
		end

		def close
			@callbacks.each do |callback|
				callback.call 
			end
			@callbacks.clear
		end
	end

	def self.setup(cuba)
		# How do I do it withoud using eval????
		Cuba::Response.class_eval """
			def stream(&app)
				@body = Stream.new(&app)
			end

			def on_close(&callback)
				@body.callback(&callback)
			end

			def close
				@body.close if @body.is_a? Stream
			end
		"""
	end
end

