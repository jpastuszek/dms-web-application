Feature: Feed query event source
	In order to provide data for graph rendering
	The server offers EventSource API for quering data

	Background:
		Given console connector publisher ipc:///tmp/dms-console-connector-pub, subscriber ipc:///tmp/dms-console-connector-sub
		Given Feed module setting program_id set to 'feed_query_test' string
		Given Feed module mounted under feed
		Given dms-console-connector-stub program
		And stub console connector test set 'static'
		And it is started

	@feed_query
	Scenario: API provides padding data for browsers that buffer data
		When I visit /feed/query/test?granularity=1&time_from=2002-08-19%2014:15&time_span=2
		Then I expect 2 console connector bus messages
		Then I should get 2049 bytes padding in first line

	@feed_query
	Scenario: API provides JSON encoded DataSets
		When I visit /feed/query/test?granularity=1&time_from=2002-08-19%2014:15&time_span=2
		Then I expect 2 console connector bus messages
		Then I should get following JSON object in first message of ID 'data'
		"""
		{"title":"location:magi, system:memory","value_unit":"Byte","value_min":null,"value_max":null,"time_start":1029766498000,"time_end":1029766500000,"series":{"used":[[1029766499000,3],[1029766500000,3]],"free":[[1029766499000,2],[1029766500000,2]]}}
		"""

