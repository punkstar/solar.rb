module Solar
  class Database
    include Singleton

    def initialize
      @database = Sequel.connect(ENV["DATABASE_URL"])
    end

    def connection
      @database
    end
  end
end