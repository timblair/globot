# Globot

Globot is the [globaldev](http://globaldev.co.uk/) chat bot.  He's young at the moment, but hopefully growing up quickly.

## Running Globot

1. Create a user on your [Campfire](http://campfirenow.com/) site for the bot to run as, and generate an API authentication token (you'll find it on the "Edit my Campfire Account" screen in Campfire.)
2. Get the source: `git clone git://github.com/timblair/globot.git`.
3. Create a `globot.yml` file based on the provided `globot.yml.example`, entering the rooms you want the bot to join, and the appropriate account name and API key.
4. Run `bundle install` to make sure you've got the gems you need.
5. Run `bundle exec bin/bot start` to run in the console, or use the `-d` flag to daemonise.

## Creating Plugins

Creating a new plugin is as simple as creating a new class which extends from `Globot::Plugin::Base`, and that defines the `handle` method, which takes in an instance of `Globot::Message` as a single argument.  For example, a plugin which welcomes a user when they join the room could be written as follows:

	class MyTestPlugin < Globot::Plugin::Base
	  def handle(msg)
	    msg.reply "Hello, #{msg.person.name}" if msg.type == 'EnterMessage'
	  end
	end

## Licensing and Attribution

Copyright (c) 2011 [Tim Blair](http://tim.bla.ir/).

Work has been released under the MIT license as detailed in the LICENSE file that should be distributed with this library; the source code is [freely available](http://github.com/timblair/globot).