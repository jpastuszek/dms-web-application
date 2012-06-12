Feature: Serving server time 
	In order to keep the UI in time sync with the server time
	The server offers JSON API to get it's current time

	@rack_test_json
	Scenario: UTC time
		Given ServerTime module mounted under server_time
		When I visit /server_time/utc/time
		Then I should get time value matching /^\d\d:\d\d (AM|PM)$/

	@rack_test_json
	Scenario: UTC date
		Given ServerTime module mounted under server_time
		When I visit /server_time/utc/date
		Then I should get date value matching /^\d\d-\d\d-\d\d$/

	@rack_test_json
	Scenario: UTC zone
		Given ServerTime module mounted under server_time
		When I visit /server_time/utc/zone
		Then I should get zone value matching /^UTC$/

	@rack_test_json
	Scenario: UTC date time and zone string
		Given ServerTime module mounted under server_time
		When I visit /server_time/utc
		Then I should get datetime value matching /^\d\d-\d\d-\d\d \d\d:\d\d (AM|PM) UTC$/

	@rack_test_json
	Scenario: UTC UNIX timestamp
		Given ServerTime module mounted under server_time
		When I visit /server_time/utc/timestamp/unix
		Then I should get unix_timestamp value matching /^\d+\.\d+$/

	@rack_test_json
	Scenario: UTC UNIX timestamp
		Given ServerTime module mounted under server_time
		When I visit /server_time/utc/timestamp/javascript
		Then I should get javascript_timestamp value matching /^\d+$/

