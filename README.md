Installation
------------

Put into your Gemfile:

```ruby
gem "crowd_authentication", :git => "git@github.com:arvatoSystemsNA/crowd_authentication.git"
```

Usage
-----

1. Add your host to remote hosts list in crowd applications http://www.arvatosystems-us.com/crowd/console/secure/application/browse.action

2. Copy config/crowd_authentication.yml file into the rails config directory and set up the credentials for your application.

3. If you are using Rails 2 you have to
```ruby
include CrowdAuthentication::Controller
```
in your ApplicationController.

Use
```ruby
authenticate_with_crowd_id(crowd_id, password)
```
in your controllers for authentication. This method returns true if authentication using given crowd id and password was successful and false otherwise.