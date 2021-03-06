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

require 'time'
require 'active_support/core_ext'

require_relative 'page'

class ServerTime < Cuba
	require_relative 'helpers/json'
	self.plugin Json

	self.define do
		now = Time.now.utc

		on 'timestamp' do
			on 'unix' do
				send_json unix_timestamp: now.to_f
			end

			on 'javascript' do
				send_json javascript_timestamp: now.javascript_timestamp
			end
		end

		on 'utc' do
			now = Time.now.utc

			on 'time' do
				send_json time: now.strftime('%H:%M')
			end

			on 'date' do
				send_json date: now.strftime('%y-%m-%d')
			end

			on 'zone' do
				send_json zone: 'UTC'
			end

			on true do
				send_json datetime: now.strftime('%y-%m-%d %H:%M %Z')
			end
		end
	end
end

class Time
	def javascript_timestamp
		(to_f * 1000).to_i
	end
end


