# Globot TODOs

## Config settings for plugins

* Allow plugins access to the `globot\plugins` config key
* This hash will contain any config required for individual plugins

## Persistent storage for plugins

* KVP storage for individual plugins
* Single SQLite table: id, plugin, key, data, timestamp
* Each plugin is free use its own conventions for keys
* Is there a need for some form of migrations for initing new plugins?

### Example usage for plugin storage

* Live departures can store a user's regular route
* Welcome can store all phrases in the DB
* Can have "lunch recommender" when users can add new suggestions
