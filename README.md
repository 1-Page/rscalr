Rscalr
======

Ruby Scalr API implementation. 

Desciption
----------

Rscalr allows your Ops team to build on top of the Scalr API using Ruby. This is particularly beneficial due to the popularity of Chef, a cloud management software suite also written in Ruby.

Rscalr provides both a low-level client implementation, as well as a more user-friendly domain object layer. Here are some brief examples of how to interact with each API mode.

Installation
------------

Rscalr is available on RubyGems so installing it is simply: 

```bash
gem install rscalr
```

Client Usage
------------

```ruby
require 'rscalr'
scalr = Scalr.new { :key_id => 'your-key-id', :key_secret => 'your-key-secret' }
# list all farms
api_response = scalr.farms_list
# Response objects exted REXML::Document, so you can work with them easily
api_repsonse.write($stdout, 1)
```

Domain Model Usage
------------------

```ruby
require 'rscalr'
scalr = Scalr.new { :key_id => 'your-key-id', :key_secret => 'your-key-secret' }
dashboard = Dashboard.new scalr
farm = dashboard.get_farm 'my-farm-name'
script = dashboard.get_script 'my-script-name'
# execute the script on all instances in the farm (see Script.rb for all options)
script.execute farm.id
```


Caveats
-------

This client library is a work in progress and is not yet complete. Feel free to submit pull requests and/or suggestions. I am not an experienced Rubyist, so if you see anything in the source that makes you cringe, by all means let me know!
