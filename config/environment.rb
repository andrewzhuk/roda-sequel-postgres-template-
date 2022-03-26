# frozen_string_literal: true

require_relative 'application'

# sync stdout to make logging easier
$stdout.sync if Application.env == :development

# Connect to db.
Application.connect_database
# Connect to redis.
Application.connect_redis
Application.set_cache

module Application
  module Models
    require './application/models/post'
    require './application/models/user'
  end

  module Serializers
    require './application/serializers/post'
  end
end
# Finalization Associations and Freeze Model Classes and Database
Application.models.each(&:finalize_associations)
Application.models.each(&:freeze)

Application.serializers.each(&:freeze)
