# frozen_string_literal: true

module Application
  module Api
    # no doc
    class Posts < Application::Api::Base
      route do |r|
        # /posts branch
        r.is do
          # GET /posts request
          r.get do
            options = {
              show_post_plain_body: true, show_post_author: true,
              offset: r.params['offset'], limit: r.params['limit']
            }
            Application::Utils.sanitize_options(options)
            dataset = Application::Models::Post.published.exclude(verified_at: nil)
            options.merge!(show_post_author: true)
            dataset = dataset.where(lang: r.params['language']) if %w[en es ru ua].include?(r.params['language'])
            if r.params['query']
              dataset = dataset.full_text_search(
                Sequel.lit('posts.title'), r.params['query'],
                { to_tsquery: :plain, plain: false, rank: true }
              )
            end
            posts = dataset.order(Sequel.desc(Sequel.lit('posts.verified_at')))
                           .offset(options[:offset]).limit(options[:limit])
            hash = Application::Models::Post.to_hash_collection(posts.all, options)
            paginate = {
              count: dataset.count, offset: options[:offset], limit: options[:limit]
            }
            data = { paginate: paginate, posts: hash }
            response.status = 200
            request.halt(data.to_json)
          end
        end


        # GET '/api/v0/posts/unique/:field/:value'
        r.get 'unique', String, String do |field, value|
          return bad_request_error if field.nil? || value.nil?

          dataset = Application::Models::Post
          dataset = dataset.exclude(token: r.params['exclude_token']) if r.params['exclude_token']
          unique = dataset.where { |o| { o.lower(field.to_sym) => o.lower(value) } }.to_a.any?
          data = { field: unique ? 'not unique' : 'unique' }
          response.status = 200
          request.halt(data.to_json)
        end
      end
    end
  end
end
