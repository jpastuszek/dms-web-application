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

Given /(.*) module setting (.*) set to '(.*)' string/ do |mod, setting, value|
	eval(mod).settings[setting.to_sym] = value
end

Given /(.*) module mounted under (.*)/ do |mod, prefix|
	app = Class.new(Cuba)
	app.plugin AppRoot
	app.define do
		on prefix do
			run eval mod
		end
	end

	Capybara.app = app
end

Given /console connector publisher (.*), subscriber (.*)/ do |internal_console_publisher, internal_console_subscriber|
	ZeroMQService.socket(:bus) do |zmq|
		zmq.bus_connect(internal_console_publisher, internal_console_subscriber, {hwm: 10, linger: 0})
	end
end

When /I visit (.*)/ do |uri|
	visit uri
end

Then /I should get (.*) value matching \/(.*)\// do |key, regexp|
	regexp = Regexp.new(regexp)
	body.should_not be_nil
	body.should include(key)
	body[key].to_s.should match(regexp)
end

