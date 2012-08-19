Feature: Feed query event source
	In order to provide data for graph rendering
	The server offers EventSource API for quering data

	@feed_query
	Scenario: API provides padding data for browsers that buffer data
		Given console connector publisher ipc:///tmp/dms-console-connector-pub, subscriber ipc:///tmp/dms-console-connector-sub
		Given Feed module setting program_id set to 'feed_query_test' string
		Given Feed module mounted under feed
		When I visit /feed/query/test?granularity=1&time_from=2002-08-19%2014:15&time_span=2
		Then I should get 2049 bytes padding in first line

