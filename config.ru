# frozen_string_literal: true

# config.ru is Rack configuration file.
#
# Rack is an interface for developing web applications in Ruby.
# It provides the API for interaction between web servers and web frameworks.

require_relative 'config/environment'
require_relative 'api/base'
require_relative 'api/post'


# The .freeze.app at the end is optional. Freezing the app makes modifying app-level settings raise an error,
# alerting you to possible thread-safety issues in application. It is recommended to freeze the app in production
# and during testing. The .app is an optimization, which saves a few method calls for every request.
run Application::Api::Base.freeze.app
