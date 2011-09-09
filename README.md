# Globot

Globot is the [globaldev](http://globaldev.co.uk/) chat bot.  He's young at the moment, but hopefully growing up quickly.

## Running Globot

Globot relies on [Redis](http://redis.io/) for persistent storage for plugins.  The default configuration provided assumes Redis is running on `localhost` on the default port (`6379`), and uses database `0`.

1. Create a user on your [Campfire](http://campfirenow.com/) site for the bot to run as, and generate an API authentication token (you'll find it on the "Edit my Campfire Account" screen in Campfire.)
2. Get the source: `git clone git://github.com/timblair/globot.git`.
3. Create a `globot.yml` file based on the provided `globot.yml.example`, entering the rooms you want the bot to join, and the appropriate account name and API key.
4. Make sure Redis is running and appropriately configured in `globot.yml`.
5. Run `bundle install` to make sure you've got the gems you need.
6. Run `bundle exec bin/bot start` to run in the console.

## Creating Plugins

Creating a new plugin is as simple as creating a new class which extends from `Globot::Plugin::Base`, and that defines the `handle` method, which takes in an instance of `Globot::Message` as a single argument.  For example, a plugin which welcomes a user when they join the room could be written as follows:

```ruby
class MyTestPlugin < Globot::Plugin::Base
  def handle(msg)
    msg.reply "Hello, #{msg.person.name}" if msg.type == 'EnterMessage'
  end
end
```

## Licensing and Attribution

Copyright (c) 2011 [Tim Blair](http://tim.bla.ir/).

Work has been released under the MIT license as detailed in the LICENSE file that should be distributed with this library; the source code is [freely available](http://github.com/timblair/globot).
