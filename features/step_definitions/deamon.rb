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

Given /stub console connector is running/ do
	step 'dms-console-connector-stub program is spawned'
end

Given /stub console connector argument (.*)/ do |argument|
	step "dms-console-connector-stub program argument #{argument}"
end

Given /stub console connector test set (.*)/ do |test_set|
	step "stub console connector argument --test-set #{test_set}"
end

