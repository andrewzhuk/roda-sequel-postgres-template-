# frozen_string_literal: true

module Application
  module Api
    # no doc
    class Post < Application::Api::Base
      route do |r|
        # '/api/v0/post' branch
        # POST '/api/v0/post' request
        r.is do
          r.post do
            authenticate!
            return not_authorized_error

            post = Application::Models::Post.new
            post.set_fields(
              r.params['post'],
              %i[
                title body
              ],
              missing: :skip
            )
            post.set(user: connected_user)
            if post.valid? && post.save(changed: true)
              data = { post: { slug: post.slug } }
              code = 201
            else
              data = { error: 'Bad Request', errors: post.errors }
              code = 422
            end
            response.status = code
            request.halt(data.to_json)
          end
        end

        # '/api/v0/post/:slug' branch
        r.on String do |slug|
          options = { show_post_author: true, show_post_body: true }
          post = Application::Models::Post.first(slug: slug)
          return not_found_error(table: 'post', column: 'slug', query: slug) unless post

          r.is do
            # GET '/api/v0/post/:slug' request
            r.get do
              options.merge!(show_post_visits: true)
              hash = post.to_hash(options)
              data = { post: hash }
              r.etag data.sha1
              response.status = 200
              request.halt(data.to_json)
            end

            # PUT '/api/v0/post/:slug' request
            r.put do
              authenticate!
              return not_authorized_error unless connected_user.id == post.user_id || connected_user.staff?

              post.update_fields(
                r.params['post'],
                %w[title body],
                missing: :skip
              )
              post.set(last_actor_id: connected_user.id, last_action: 'update')
              if post.valid? && post.save(changed: true)
                data = { status: 'success', post: { slug: post.slug } }
                code = 200
              else
                data = { error: 'Bad Request', errors: post.errors }
                code = 422
              end
              response.status = code
              request.halt(data.to_json)
            end

            # DELETE '/api/v0/post/:slug' request
            r.delete do
              # NOTE: needs to authenticate request
              # return not_authorized_error

              if post.delete!
                data = { post: { slug: post.slug, deleted: post.deleted? } }
                code = 200
              else
                data = { error: 'Bad Request', errors: post.errors }
                code = 422
              end
              response.status = code
              request.halt(data.to_json)
            end
          end

          # POST '/post/:slug/toggle' request
          r.post 'toggle' do
            if post.toggle_active!
              data = { slug: slug, active: post.active? }
              code = 200
            else
              data = { error: 'Bad Request', errors: post.errors }
              code = 422
            end
            response.status = code
            request.halt(data.to_json)
          end
        end
      end
    end
  end
end
