Feature: Serving server time 
	In order to keep the UI in time sync with the server time
	The server offers JSON API to get it's current time

	Background:
		Given ServerTime Rack application mounted under /server_time

	@rack_test_json
	Scenario: UTC time
		When I visit /server_time/utc/time
		Then I should get time value matching /^\d\d:\d\d$/

	@rack_test_json
	Scenario: UTC date
		When I visit /server_time/utc/date
		Then I should get date value matching /^\d\d-\d\d-\d\d$/

	@rack_test_json
	Scenario: UTC zone
		When I visit /server_time/utc/zone
		Then I should get zone value matching /^UTC$/

	@rack_test_json
	Scenario: UTC date time and zone string
		When I visit /server_time/utc
		Then I should get datetime value matching /^\d\d-\d\d-\d\d \d\d:\d\d UTC$/

	@rack_test_json
	Scenario: UNIX timestamp
		When I visit /server_time/timestamp/unix
		Then I should get unix_timestamp value matching /^\d+\.\d+$/

	@rack_test_json
	Scenario: UNIX timestamp
		When I visit /server_time/timestamp/javascript
		Then I should get javascript_timestamp value matching /^\d+$/

