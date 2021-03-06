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
module View
	def send_page(name, locals = {}, layout = 'layout')
		locals = {
			pages: settings[:pages],
			page: curren_page,
			title: name.titlecase
		}.merge(locals)

		log.debug "rendering page '#{name}' with locals: #{locals}"

		res.write view(name, locals, layout)
	end

	def curren_page
		uri[root_uri.length..-1].split('/')[1]
	end

	def style(name)
		(@styles ||= []).unshift name
	end

	def styles
		@styles | []
	end

	def script(name)
		(@scripts ||= []).unshift name
	end

	def scripts
		@scripts | []
	end
end

class String
	def titlecase
		tr("_", " ").gsub(/(^|\s)([a-z])/) { |char| char.upcase }
	end
end

