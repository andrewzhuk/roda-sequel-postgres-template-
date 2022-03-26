# frozen_string_literal: true

# @copyright Copyright (C) 2021 Bistox. All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
module Application
  module Logging
    # A unique logger for the current class
    def logger
      @logger ||= begin
        logger = Application.logger.dup
        logger.progname = self.class.name
        logger
      end
    end
  end
end
