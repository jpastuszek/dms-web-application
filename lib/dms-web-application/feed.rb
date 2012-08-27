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
require 'dms-web-application/graph_data'

class Feed < Cuba
	require_relative 'helpers/streaming'
	require_relative 'helpers/console_bus'
	require_relative 'helpers/optional_param_matcher'
	require_relative 'helpers/request_id'

	self.plugin Streaming
	self.plugin OptionalParamMatcher
	self.plugin ConsoleBus
	self.plugin RequestID

	self.define do
		on 'query/(.*)', 
			param?(:time_from, Time.now.utc.to_s), 
			param?(:time_span, 60*60), 
			param?(:granularity, 1) do |tag_expression, time_from, time_span, granularity|
			time_from = Time.parse(time_from + ' UTC')
			time_span = Float(time_span)
			granularity = Float(granularity)

			# limit output to 2000 samples
			granularity = time_span / 2000 if time_span / granularity > 2000

			query = DataSetQuery.new(tag_expression, time_from, time_span.to_f, granularity.to_f)
			log.debug "sending query: #{query}"
			bus.send query, topic: request_id

			res['Content-Type'] = 'text/event-stream'
			res['Cache-Control'] = 'no-cache'
			res['Connection'] = 'keep-alive'
			res['Access-Control-Allow-Origin'] = '*'

			res.stream do
				res.write ":#{' padding '.ljust(2049, '-')}\n" # padding

				bus.on DataSet, request_id do |data_set|
					log.info "got DataSet: #{data_set}"
					graph_data = GraphData.from_data_set(
							data_set.tag_set,
							'Byte', 
							query.tag_expression,
							data_set
					)
					graph_data.to_json.each_line do |json_line|
						res.write "data: #{json_line}\n"
					end
					res.write "\n"
				end

				res.on_close do
					#TODO: deregistration
					#bus.deregister_on DataSet, request_id
				end
			end
		end
	end
end

