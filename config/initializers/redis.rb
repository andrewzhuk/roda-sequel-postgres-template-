# frozen_string_literal: true

# @copyright Copyright (C) 2021 Bistox. All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
require 'redis'
require 'connection_pool'

# no doc
module Application
  class << self
    attr_accessor :redis

    def connect_redis
      Redis.exists_returns_integer = true

      redis_connection = proc {
        Redis.new(url: Application.settings[:redis_url])
      }
      self.redis = ConnectionPool.new(size: 5, &redis_connection)
    end
  end
end
