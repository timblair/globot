require 'sqlite3'

module Globot
  class Store

    def initialize(path)
      path = File.join(File.dirname(__FILE__), '..', path) if !path.match(/^[\\\/]/)
      @db = SQLite3::Database.new(path)
      setup!
    end

    def get(key)
    end

    def set(key, value)
    end

    def delete(key)
    end

    # Create the table we use to store all the plugin data, but only if
    # it doesn't already exist.
    def setup!
      if @db.get_first_value('SELECT COUNT(*) FROM sqlite_master WHERE name = "plugin_data"') == 0
        @db.execute <<SQL
          CREATE TABLE plugin_data (
            id         INTEGER PRIMARY KEY,
            plugin     VARCHAR(255),
            key        VARCHAR(255),
            data       TEXT,
            created_at DATETIME,
            updated_at DATETIME
          );
SQL
      end
    end

  end # class Store

  # To simplify a plugin's job of writing to the store, we can use
  # a proxy object which keeps track of which plugin we're writing
  # or reading from, and passes the correct namespace automatically.
  class StoreProxy

    def initialize(store, plugin)
      @store = store
      @plugin = plugin
    end

    def get(key)
      @store.get(namespace, key)
    end

    def set(key, value)
      @store.set(namespace, key, value)
    end

    def delete(key)
      @store.delete(namespace, key)
    end
    # We'll also provide an alias to keep the 3-char method names.
    alias :del :delete

    # We'll use the full plugin class as the namespace.
    def namespace
      @plugin.class.name
    end

  end # class StoreProxy

end
