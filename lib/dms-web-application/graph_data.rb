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

require 'multi_json'

class GraphData
	def initialize(title, value_unit, query_tag_expression, tag_set, time_from, time_span, component_data)
		@data = {}
		@data[:title] = title.to_s
		@data[:value_unit] = value_unit
		@data[:query_tag_expression] = query_tag_expression.to_s
		@data[:tag_set] = tag_set.to_s
		@data[:value_min] = nil
		@data[:value_max] = nil
		@data[:time_start] = to_json_time(time_from.to_f - time_span)
		@data[:time_end] = to_json_time(time_from)
		@data[:series] = {}
		component_data.each do |name, data|
			series_data = []
			data.reverse_each do |time, value|
				series_data << [to_json_time(time), value]
			end
			@data[:series][name] = series_data
		end
	end

	def self.from_data_set(title, value_unit, query_tag_expression, data_set)
		self.new(title, value_unit, query_tag_expression, data_set.tag_set, data_set.time_from, data_set.time_span, data_set.component_data)
	end

	def to_json(a = nil)
		MultiJson.dump(@data)
	end

	private

	def to_json_time(time)
		Integer(time.to_f * 1000)
	end
end

