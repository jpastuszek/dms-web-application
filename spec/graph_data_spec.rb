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

require_relative 'spec_helper'

describe GraphData do
	subject do
		GraphData.new('hello world', 'Bytes', 'query:test', 'test:data', Time.at(60), 20, {
			free: [
				[Time.at(4), 40],
				[Time.at(3), 30],
				[Time.at(2), 20],
				[Time.at(1), 10],
			],
			used: [
				[Time.at(4), 10],
				[Time.at(3), 20],
				[Time.at(2), 30],
				[Time.at(1), 10],
			]
		})
	end

	it 'should convert to json' do
		subject.to_json.should match_json '{"title":"hello world","value_unit":"Bytes","query_tag_expression":"query:test","tag_set":"test:data","value_min":null,"value_max":null,"time_start":40000,"time_end":60000,"series":{"free":[[1000,10],[2000,20],[3000,30],[4000,40]],"used":[[1000,10],[2000,30],[3000,20],[4000,10]]}}'
	end

	describe DataSet do
		subject do
			DataSet.new('memory', 'location:magi, system:memory', Time.at(60), 4) do
				total = 10

				4.times do |time|
					used = time
					component_data 'free', Time.at(60).to_f - time, used
					component_data 'used', Time.at(60).to_f - time, total - used
				end
			end
		end

		it 'should construct from DataSet' do
			GraphData.from_data_set('hello world', 'B', 'query:test', subject).to_json.should match_json '{"title":"hello world","value_unit":"B","query_tag_expression":"query:test","tag_set":"location:magi, system:memory","value_min":null,"value_max":null,"time_start":56000,"time_end":60000,"series":{"free":[[57000,3],[58000,2],[59000,1],[60000,0]],"used":[[57000,7],[58000,8],[59000,9],[60000,10]]}}'
		end
	end
end

