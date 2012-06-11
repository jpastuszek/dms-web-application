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
module RequestID
	class CantBuildRequestIDError < RuntimeError
	end

	def request_id
		raise CantBuildRequestIDError, 'missing settings[:program_id], set it to your program UUID' unless settings.has_key? :program_id
		raise CantBuildRequestIDError, 'missing env["request.number"], use Rack::RequestNumber middleware' unless env.has_key? 'request.number'

		p "#{settings[:program_id]}[#{env['request.number']}]"
	end
end

