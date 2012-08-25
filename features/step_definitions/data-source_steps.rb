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

autoload :Feed, 'dms-web-application/feed.rb'

Then /I should get (.*) bytes padding in first line/ do |padding_size|
	source.should_not be_nil
	source.lines.first.should match(/^:.{#{padding_size}}$/)
end

Then /I should get following JSON object in first message of ID '(.*)'/ do |message_id, json|
	message = source.lines.map{|l| l.split(':', 2)}.select{|id, message| id == message_id}.first
	message.should_not be_nil, "message of ID '#{message_id}' not found in: #{source}"

	source_json = JSON.parse(message[1])

	json = JSON.parse(json)
	source_json.should == json
end

