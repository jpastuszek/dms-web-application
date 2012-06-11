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

require_relative 'page'

class ErrorReporter < Cuba
	self.plugin Page

	self.define do
		on error BusDetector::NoBusError do
			res.status = 504
			send_page 'no_bus_error'
		end

		on error Rack::UnhandledRequest::UnhandledRequestError do
			res.status = 404
			send_page '404'
		end

		on error StandardError do
			log.error "Unhandled error: ", env["ERROR"]
			res.status = 500
			send_page '500', :error_class => env["ERROR"].class, :error_message => env["ERROR"].message
		end
	end
end

