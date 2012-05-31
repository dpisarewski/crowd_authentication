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

in your controllers for authentication. This method returns a hash with response code and response body in JSON format.

```ruby
{:success => true, :code => 200, :body => body_hash}
```

```ruby
crowd_user_data(crowd_id)
```

 returns a Hash with user data.

For example:

```ruby
{"expand"=>"attributes",
 "link"=>
  {"href"=>
    "",
   "rel"=>"self"},
 "name"=>"dieter.pisarewski@arvatosystems.com",
 "first-name"=>"Dieter",
 "last-name"=>"Pisarewski",
 "display-name"=>"Dieter Pisarewski",
 "email"=>"dieter.pisarewski@arvatosystems.com",
 "password"=>
  {"link"=>
    {"href"=>
      "",
     "rel"=>"edit"}},
 "active"=>true,
 "attributes"=>
  {"attributes"=>[],
   "link"=>
    {"href"=>
      "",
     "rel"=>"self"}}}
```
