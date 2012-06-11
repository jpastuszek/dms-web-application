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
		on true do
			now = Time.now.utc
			send_json(
				time: now.strftime('%I:%M %p'),
				date: now.strftime('%y-%m-%d'),
				datetime: now.to_s,
				unix_timestamp: now.to_f,
				javascript_timestamp: (now.to_f * 1000).to_i
			)
		end
	end
end

