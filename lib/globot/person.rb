module Globot
  class Person

    attr_reader :id, :email, :name, :type, :created_at

    def initialize(person)
      @id         = person['id']
      @email      = person['email_address']
      @name       = person['name']
      @type       = person['type']
      @admin      = person['admin']
      @created_at = person['created_at']
    end

    def admin?
      @admin || false
    end

  end
end
