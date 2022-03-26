# frozen_string_literal: true
l
require 'roda'
# require 'rack'
# require 'rack/contrib'

module Application
  module Api
    # Roda - Roda is a routing tree web toolkit, designed for building fast and maintainable web applications in ruby.
    class Base < Roda
      plugin :all_verbs
      plugin :halt
      plugin :json
      plugin :json_parser, parser: Oj.method(:load)
      plugin :not_found
      plugin :direct_call
      # plugin :caching
      # plugin :common_logger
      plugin :optimized_string_matchers
      plugin :default_headers,
             'Access-Control-Allow-Origin' => %w[application.bistox.loc application.bistox.com],
             'Content-Type' => 'application/json',
             'Acccess-Control-Expose-Headers' => 'x-Total-Count',
             'Access-Control-Allow-Methods' => %w[GET POST PUT DELETE OPTIONS],
             'X-Frame-Options' => 'deny',
             'X-XSS-Protection' => '1; mode=block',
             'Access-Control-Allow-Headers' => %w[
               Origin Accept Content-Type
               X-Requested-With Access-Control-Allow-Origin
             ],
             'Access-Control-Request-Method' => '*'
      # use Rack::JSONBodyParser
      # The route block is called whenever a new request comes in. It is yielded an instance of a subclass of
      # Rack::Request with some additional methods for matching routes. By convention, this argument should be named r.
      # The primary way routes are matched in Roda is by calling r.on, r.is, r.root, r.get, or r.post. Each of these
      # "routing methods" takes a "match block".
      # Each routing method takes each of the arguments (called matchers) that are given and tries to match it to
      # the current request. If the method is able to match all of the arguments,
      # it yields to the match block; otherwise, the block is skipped and execution continues.
      # Api
      route do |r|
        r.root do
          response.status = 200
          request.halt({ status: 'Api health ok' }.to_json)
        end

        r.options do
          r.halt(200)
        end

        r.on 'post' do
          r.run Application::Api::Post
        end
      end

      def not_found_error(table: nil, column: nil, query: nil)
        response.status = 404
        request.halt({ error: "Not Found #{table} with #{column}: #{query}" }.to_json)
      end

      def invalid_format_error
        response.status = 406
        request.halt({ error: 'Response format is not supported' }.to_json)
      end

      def bad_request_error
        response.status = 406
        request.halt({ error: 'Bad Request' }.to_json)
      end

      def not_authorized_error
        response.status = 403
        request.halt({ error: 'Access forbidden' }.to_json)
      end

      not_found do
        { error: 'Not found endpoint' }.to_json
      end


      def authenticate!(*args)
        # code
      end

      def connected_user
        # code
      end

      def json(obj)
        opts = { space: '' }
        Oj.generate(obj, opts)
      end
    end
  end
end
