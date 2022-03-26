# frozen_string_literal: true

# @copyright Copyright (C) 2021 Bistox. All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
require './lib/cached'
module Application
  # no doc
  class << self
    attr_accessor :cache

    def set_cache
      self.cache = Application::Cached.new(sync: true)
    end
  end
end
