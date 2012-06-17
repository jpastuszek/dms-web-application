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

require 'time'
require 'active_support/core_ext'

require_relative 'page'

class Query < Cuba
	self.plugin Page

	self.define do
		on true, 
			param?('time_from_date', Time.now.utc.strftime('%y-%m-%d')), 
			param?('time_from_time', Time.now.utc.strftime('%H:%M')), 
			param?('time_span_value', 2), 
			param?('time_span_unit', 'Weeks') do |time_from_date, time_from_time, time_span_value, time_span_unit|
			# handle form submit
			on 'submit', param!('tag_query') do |tag_query|
				go_to 'query', tag_query, {
					time_from_date: time_from_date, 
					time_from_time: time_from_time, 
					time_span_value: time_span_value, 
					time_span_unit: time_span_unit
				}
			end

			tag_query_string = (env['PATH_INFO'][1..-1] || '')
			tag_query = tag_query_string.to_tag_query

			time_from = Time.parse("#{time_from_date} #{time_from_time} UTC")
			time_span = case time_span_unit
				when 'Minutes'
					time_span_value.to_f * 60
				when 'Hours'
					time_span_value.to_f * 60 * 60
				when 'Days'
					time_span_value.to_f * 60 * 60 * 24
				when 'Weeks'
					time_span_value.to_f * 60 * 60 * 24 * 7
				when 'Months'
					time_from.to_f - time_from.months_ago(time_span_value.to_f).to_f
				when 'Years'
					time_from.to_f - time_from.years_ago(time_span_value.to_f).to_f
			end.abs

			log.info "quering for #{tag_query} from #{time_from} span #{time_span} seconds"
			
			send_page 'query', 
				tag_query_string: tag_query_string, 
				tag_query: tag_query,
				time_from_date: time_from_date,
				time_from_time: time_from_time,
				time_from: time_from,
				time_span_value: time_span_value,
				time_span_unit: time_span_unit,
				time_span: time_span
		end

	end
end

