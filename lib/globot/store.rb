require 'sqlite3'

module Globot
  class Store

    TABLE_NAME = 'plugin_data'

    def self.absolute_path_for(path)
      path = File.join(Globot.basepath, path) unless path.match(/^[\\\/~]/)
      path
    end

    def initialize(path)
      @db = SQLite3::Database.new(self.class.absolute_path_for(path))
      setup!
    end

    # Returns a given key for a given namespace.  Returns `nil` if not found.
    def get(namespace, key)
      @db.get_first_value("SELECT data FROM #{TABLE_NAME} WHERE plugin = ? AND key = ?", namespace, key)
    end

    # Sets the value for a given namespace/key.  Stores the result of `value.to_s`,
    # and returns the value stored.
    def set(namespace, key, value)
      @db.execute("REPLACE INTO #{TABLE_NAME} (plugin, key, data, updated_at) VALUES (?,?,?,datetime())", namespace, key, value.to_s)
      value.to_s
    end

    # Deletes the value for a given namespace/key.  Always returns `nil`.
    def delete(namespace, key)
      @db.execute("DELETE FROM #{TABLE_NAME} WHERE plugin = ? AND key = ?", namespace, key)
    end

    # Create the table we use to store all the plugin data, but only if
    # it doesn't already exist.
    def setup!
      if !data_table_exists?
        @db.execute <<SQL
          CREATE TABLE #{TABLE_NAME} (
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            plugin     VARCHAR(255) NOT NULL,
            key        VARCHAR(255) NOT NULL,
            data       TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            CONSTRAINT plugin_key UNIQUE (plugin, key)
          );
SQL
      end
    end

    def data_table_exists?
      @db.get_first_value("SELECT COUNT(*) FROM sqlite_master WHERE name = ?", TABLE_NAME) == 1
    end

    def truncate!
      @db.execute "DELETE FROM #{TABLE_NAME}" if data_table_exists?
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
