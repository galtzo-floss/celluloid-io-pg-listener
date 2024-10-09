# celluloid-io-pg-listener

Simple way to NOTIFY and LISTEN to channels in PostgreSQL

Standalone the listener client works great in an `irb` session.
Real-world, practical, use requires a long running process, and for an example of that see [bin/supervisor](https://github.com/pboling/celluloid-io-pg-listener/blob/master/bin/supervisor)

| Project                 |  CelluloidIOPGListener    |
|------------------------ | ----------------- |
| gem name                |  celluloid-io-pg-listener   |
| license                 |  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) |
| expert support          |  [![Get help on Codementor](https://cdn.codementor.io/badges/get_help_github.svg)](https://www.codementor.io/peterboling?utm_source=github&utm_medium=button&utm_term=peterboling&utm_campaign=github) |
| download rank               |  [![Total Downloads](https://img.shields.io/gem/rt/celluloid-io-pg-listener.svg)](https://rubygems.org/gems/celluloid-io-pg-listener) |
| version                 |  [![Gem Version](https://badge.fury.io/rb/celluloid-io-pg-listener.png)](http://badge.fury.io/rb/celluloid-io-pg-listener) |
| dependencies            |  [![Dependency Status](https://gemnasium.com/pboling/celluloid-io-pg-listener.png)](https://gemnasium.com/pboling/celluloid-io-pg-listener) |
| code quality            |  [![Code Climate](https://codeclimate.com/github/pboling/celluloid-io-pg-listener.png)](https://codeclimate.com/github/pboling/celluloid-io-pg-listener) |
| inline documenation     |  [![Inline docs](http://inch-ci.org/github/pboling/celluloid-io-pg-listener.png)](http://inch-ci.org/github/pboling/celluloid-io-pg-listener) |
| continuous integration  |  [![Build Status](https://secure.travis-ci.org/pboling/celluloid-io-pg-listener.png?branch=master)](https://travis-ci.org/pboling/celluloid-io-pg-listener) |
| test coverage           |  [![Coverage Status](https://coveralls.io/repos/pboling/celluloid-io-pg-listener/badge.png)](https://coveralls.io/r/pboling/celluloid-io-pg-listener) |
| homepage                |  [on Github.com][homepage] |
| documentation           |  [on RubyDoc.info][documentation] |
| live chat               |  [![Join the chat at https://gitter.im/pboling/celluloid-io-pg-listener](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/pboling/celluloid-io-pg-listener?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) |
| Spread ~♡ⓛⓞⓥⓔ♡~      |  [🌏](https://about.me/peter.boling), [👼](https://angel.co/peter-boling), [:shipit:](http://coderwall.com/pboling), [![Tweet Peter](https://img.shields.io/twitter/follow/galtzo.svg?style=social&label=Follow)](http://twitter.com/galtzo) |

[semver]: http://semver.org/
[pvc]: http://docs.rubygems.org/read/chapter/16#page74
[railsbling]: http://www.railsbling.com
[peterboling]: http://www.peterboling.com
[coderbits]: https://coderbits.com/pboling
[coderwall]: http://coderwall.com/pboling
[documentation]: http://rubydoc.info/gems/celluloid-io-pg-listener
[homepage]: https://github.com/pboling/celluloid-io-pg-listener

## Prerequisites

Compatible with Ruby 2.1+, and tested on Travis.  Might also be compatible with Ruby 2.0, but haven't had time or inclination to find out. That's why we have a fork button!

Requires Celluloid greater than 0.17.2 because that release fixed an important memory leak in Celluloid.
```
gem "celluloid", ">= 0.17.2"
```

Currently requires pg gem v0.18.3 or greater, but really that's only because I haven't had time to test with older versions.  Feel free to do that and send a PR.
```
gem "pg", ">= 0.18.3"
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'celluloid-io-pg-listener'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install celluloid-io-pg-listener

## Upgrading 0.2.x to 0.3.x

Change:
```
include CelluloidIOPGListener::Client
```
To:
```
include CelluloidIOPGListener.client(:unlisten_wrapper_with_termination)
```
You now have a choice of unlisten wrappers, with or without termination as part of the unlisten.
The one without terminate is used when you are running a client inside a celluloid supervisor container, which handles termination.
See `bin/supervisor` and `bin/supervision` in this project for two examples of this.

## Usage

Find a data base that exists that you want to run notifications through.  Won't affect anything else in the database,
so doesn't matter which one you pick.  Then pick an arbitrary name for the channel.  Only requirement is that the server
and the client use the same database name and channel name or they won't be communicating.

In an irb session taking care to:
- replace the database names with your own
- replace the channel name, if you want, they are arbitrary, and don't need to be "created" in the DB.

Turn on debug mode to see what is happening:
```
>> $CELLULOID_DEBUG=true
=> true
```

Then create a server:
```
>> server = CelluloidIOPGListener::Examples::Server.new(dbname: "celluloid_io_pg_listener_test", channel: "users_insert")

D, [2015-10-14T12:59:31.840206 #23209] DEBUG -- : Server will send notifications to celluloid_io_pg_listener_test:users_insert

=> #<Celluloid::Proxy::Cell(CelluloidIOPGListener::Examples::Server:0x3ff71a6f6db8) @client_extracted_signature=#<CelluloidIOPGListener::Initialization::ClientExtractedSignature:0x007fee34dec310 @channel="users_insert", @conninfo_hash={:dbname=>"celluloid_io_pg_listener_test"}, @super_signature=[]>>

```

Then start the server sending notifications.  There is no client listening to the notifications yet, so nothing will hear them:
```
>> server.start
=> #<Celluloid::Proxy::Async(CelluloidIOPGListener::Examples::Server)>

D, [2015-10-14T12:59:36.115639 #23209] DEBUG -- : Notified users_insert
D, [2015-10-14T12:59:37.107589 #23209] DEBUG -- : Notified users_insert
D, [2015-10-14T12:59:38.112089 #23209] DEBUG -- : Notified users_insert
D, [2015-10-14T12:59:39.112341 #23209] DEBUG -- : Notified users_insert
```

The notifications will just keep flowing, 1 per second as the example server is configured by default.  Now in another irb session:

```
>> CelluloidIOPGListener::Examples::ListenerClientByInheritance.new(dbname: "celluloid_io_pg_listener_test", channel: "users_insert", callback_method: :foo_bar)

=> #<Celluloid::Proxy::Cell(CelluloidIOPGListener::Examples::ListenerClientByInheritance:0x3fe50d93f15c) @client_extracted_signature=#<CelluloidIOPGListener::Initialization::ClientExtractedSignature:0x007fca1b27c738 @channel="users_insert", @conninfo_hash={:dbname=>"celluloid_io_pg_listener_test"}, @super_signature=[{}]> @callback_method=:foo_bar @listening=true @pg_connection=#<PG::Connection:0x007fca1b287b38> @actions={"users_insert"=>:foo_bar}>

I, [2015-10-14T12:59:46.127120 #23223]  INFO -- : Received notification: ["users_insert", 23220, "1444852786"]
I, [2015-10-14T12:59:47.127021 #23223]  INFO -- : Received notification: ["users_insert", 23220, "1444852787"]
I, [2015-10-14T12:59:48.127152 #23223]  INFO -- : Received notification: ["users_insert", 23220, "1444852788"]
I, [2015-10-14T12:59:49.127509 #23223]  INFO -- : Received notification: ["users_insert", 23220, "1444852789"]
```

Simply exit the sessions to end the test.

Or keep the client running, and only exit the server and do a real test with real DB triggers.

If you have downloaded the gem source, cd to the gem's directory, and run `bin/setup` to create the test database.

Open `psql` and `\c celluloid_io_pg_listener_test`

```
pboling=# \c celluloid_io_pg_listener_test
You are now connected to database "celluloid_io_pg_listener_test" as user "pboling".
celluloid_io_pg_listener_test=# insert into users (name) values ('jack');
NOTICE:  INSERT TRIGGER called on users
INSERT 0 1
celluloid_io_pg_listener_test=# insert into users (name) values ('jill');
NOTICE:  INSERT TRIGGER called on users
INSERT 0 1
celluloid_io_pg_listener_test=# \q
```

In the irb session with the Client still running you will see new notifications:

```
I, [2015-10-14T13:42:55.511294 #25295]  INFO -- : Received notification: ["users_insert", 25304, "{\"table\" : \"users\", \"id\" : 1, \"name\" : \"jack\", \"type\" : \"INSERT\"}"]
I, [2015-10-14T13:43:03.841323 #25295]  INFO -- : Received notification: ["users_insert", 25304, "{\"table\" : \"users\", \"id\" : 2, \"name\" : \"jill\", \"type\" : \"INSERT\"}"]
```

A more advanced client could be made to deserialize that JSON and get real work done.  That's where you come in! ;)

The example [Client (Listener) class included with the gem](https://github.com/pboling/celluloid-io-pg-listener/blob/master/lib/celluloid-io-pg-listener/examples/client.rb) is just a proof of concept.  It shows you how to use the `CelluloidIOPGListener::Client` module to make your own listener class that does what you need done.  You could, for example, push the payload of the notification to Redis, to be worked by Sidekiq or Resque.

```ruby
module CelluloidIOPGListener
  module Examples
    class Client

      include CelluloidIOPGListener.client(:unlisten_wrapper_with_termination)

      # Defining initialize is optional,
      #   unless you have custom args you need to handle
      #   aside from those used by the CelluloidIOPGListener::Client
      # But if you do define it, use a splat,
      #   hash or array splat should work,
      #   depending on your signature needs.
      # With either splat, only pass the splat params to super,
      #   and handle all other params locally.
      #
      # def initialize(optional_arg = nil, *options)
      #   @optional_arg = optional_arg # handle it here, don't pass it on!
      #   super(*options)
      # end

      def insert_callback(channel, payload)
        # <-- within the unlisten_wrapper's block if :insert_callback is the callback_method
        debug "#{self.class} channel is #{channel}"
        debug "#{self.class} payload is #{payload}"
      end

    end
  end
end
```

## Credits

Written by [Peter Boling](http://github.com/pboling) and [Rohit Gupta](http://github.com/rg) for [Trumaker & Co](https://www.trumaker.com/)

Inspired by:
* https://gist.github.com/tpitale/3915671
* https://blog.andyet.com/2015/04/06/postgres-pubsub-with-json

## Development

After checking out the repo, run `bin/setup` to install dependencies, and setup the test environment, including creating a role and a database. Then, run `appraisal rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Running the tests

Setup has been implemented with `bin/setup`, so review the file to see what it will do before you:

    bin/setup

Run the specs with rake:

    appraisal rake

Or, run the specs without rake:

    appraisal rspec

NOTE: If you need to recreate `db/structure.sql` from the contents of the test database:

    cd spec/apps
    SKIP_RAILS_ROOT_OVERRIDE=true bundle exec rake db:structure:dump

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/celluloid-io-pg-listener. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
6. Create new Pull Request

## Versioning

This library aims to adhere to [Semantic Versioning 2.0.0][semver].
Violations of this scheme should be reported as bugs. Specifically,
if a minor or patch version is released that breaks backward
compatibility, a new version should be immediately released that
restores compatibility. Breaking changes to the public API will
only be introduced with new major versions.

As a result of this policy, you can (and should) specify a
dependency on this gem using the [Pessimistic Version Constraint][pvc] with two digits of precision.

For example:

```ruby
spec.add_dependency 'celluloid-io-pg-listener', '~> 0.2'
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


