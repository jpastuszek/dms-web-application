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

Then /the JSON object should match the following object:/ do |test_json|
	@json.should == JSON.parse(test_json)
end

Then /the JSON object should have key '([^']*)'$/ do |key|
	@json.should have_key(key)
end

Then /the JSON object should have key '([^']*)' of value '(.*)'/ do |key, value|
	step "the JSON object should have key '#{key}'"
	@json.should include(key => value)
end

