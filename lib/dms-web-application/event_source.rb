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

class EventSource
	class NoSinkError < RuntimeError
		def initialize
			super 'no sink to write messages to (.each with block)'
		end
	end

	def initialize(ping_interval = 8, padding_size = 2049, paddning_msg = ' padding ')
		@padding = comment_line(paddning_msg.ljust(padding_size, '-'))
		@ping_interval = ping_interval
	end

	def each(&block)
		@sink = block
		write(@padding)
		
		# ping the other end by sending comment every few seconds to detect dead connection
		@ping = ZeroMQService.poller.every(@ping_interval){ping}
		self
	end

	def message(key, body)
		body.each_line do |line|
			write line(key, line.chomp)
		end
		write_end
	end

	def comment(message)
		write comment_line(message)
	end

	def ping
		comment 'ping'
	end

	def close
		@ping.stop if @ping
		@sink = nil
	end

	private

	def line(key, value)
		"#{key}:#{value}\n"
	end

	def comment_line(message)
		":#{message}\n"
	end

	def write(line)
		raise NoSinkError unless @sink
		@sink.call(line)
	end

	def write_end
		write "\n"
	end
end

