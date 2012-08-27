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

require 'cuba'

module Page
	def self.setup(app)
		require 'cuba/render'
		require_relative 'helpers/view'
		require_relative 'helpers/navigation'
		require_relative 'helpers/error_matcher'
		require_relative 'helpers/empty_param_matcher'
		require_relative 'helpers/optional_param_matcher'

		app.plugin Cuba::Render
		app.settings[:render][:template_engine] = 'haml'
		app.settings[:render][:views] = File.join(File.dirname(__FILE__), '..', '..', 'views')

		app.settings[:pages] = [
			'dashboard',
			'query'
		]
		app.plugin View

		app.plugin Navigation
		app.plugin ErrorMatcher
		app.plugin EmptyParamMatcher
		app.plugin OptionalParamMatcher
	end
end

