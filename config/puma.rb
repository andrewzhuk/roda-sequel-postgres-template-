# frozen_string_literal: true

workers Integer(ENV['PUMA_WORKERS'] || 0)
threads Integer(ENV['PUMA_MIN_THREADS'] || 1), Integer(ENV['PUMA_MAX_THREADS'] || 16)
port ENV['PORT'] || 5000
preload_app!

# If you are preloading your application and using Redis, it's
# recommended that you close any connections to the database before workers
# are forked to prevent connection leakage.
#
before_fork do
  # QuotesEstimator.redis.shutdown(&:quit)
  Application.cache.remove_all
end

lowlevel_error_handler do |_ex, _env|
  # TODO: Send inform to Grafana.
  # Rack response
  [
    500,
    {},
    ["An error has occurred, and engineers have been informed. Please reload the page.\n If you continue to have problems, contact support@company.com"]
  ]
end
