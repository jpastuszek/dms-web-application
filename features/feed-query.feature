Feature: Feed query event source
	In order to provide data for graph rendering
	The server offers EventSource API for quering data

	Background:
		Given Feed Rack application setting program_id set to feed_query_test string
		And Feed Rack application mounted under /feed

		Given ZeroMQ service bus is configured with console connector publisher address ipc:///tmp/dms-console-connector-pub and subscriber address ipc:///tmp/dms-console-connector-sub
		Given log level set to debug

	@feed-query
	Scenario: API provides padding data for browsers that buffer data
		When I visit /feed/tag_query/test?granularity=1&time_from=2002-08-19%2014:15&time_span=2
		Then I should get 2049 bytes padding in first line

	@feed-query
	Scenario: API provides JSON encoded DataSets
		Given dms-console-connector-stub test set feed-query-test
		Given dms-console-connector-stub will print it's output
		Given dms-console-connector-stub argument --debug
		And dms-console-connector-stub is running
		When I visit /feed/tag_query/test?granularity=1&time_from=2002-08-19%2014:15&time_span=2
		Then I expect 2 ZeroMQ bus messages
		Then I should get JSON object in first message of ID 'data'
		And the JSON object should match the following object:
		"""
		{"title":"location:magi, query:test, system:memory","value_unit":"Byte","query_tag_expression":"test","tag_set":"location:magi, query:test, system:memory","value_min":null,"value_max":null,"time_start":1029766498000,"time_end":1029766500000,"series":{"used":[[1029766499000,3],[1029766500000,3]],"free":[[1029766499000,2],[1029766500000,2]]}}
		"""

	@feed-query @test
	Scenario: API should handle multiple data streams
		Given dms-console-connector-stub test set feed-query-test
		And dms-console-connector-stub is running
		When I visit /feed/tag_query/test?granularity=1&time_from=2002-08-19%2014:15&time_span=2
		Then I expect 2 ZeroMQ bus messages
		Then I should get JSON object in first message of ID 'data'
		And the JSON object should have key 'tag_set' of value 'location:magi, query:test, system:memory'
		And the JSON object should have key 'query_tag_expression' of value 'test'
		When I visit /feed/tag_query/test2?granularity=1&time_from=2002-08-19%2014:20&time_span=2
		Then I expect 2 ZeroMQ bus messages
		Then I should get JSON object in first message of ID 'data'
		And the JSON object should have key 'tag_set' of value 'location:magi, query:test2, system:memory'
		And the JSON object should have key 'query_tag_expression' of value 'test2'

