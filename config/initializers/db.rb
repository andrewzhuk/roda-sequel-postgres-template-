# frozen_string_literal: true

require 'logger'
require 'sequel'
# no doc
module Application
  class << self
    attr_accessor :db

    def connect_database
      self.db = Sequel.connect(settings[:database_url], loggers: [Logger.new($stdout)])
    end
  end
end
