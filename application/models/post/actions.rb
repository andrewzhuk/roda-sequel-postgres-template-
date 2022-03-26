# frozen_string_literal: true

module Application
  # no doc
  module Models
    # no doc
    class Post < Sequel::Model
      def toggle_active!
        update(active: active.!)
      end

      # Mark post as published.
      def publish!
        return true if published?

        update(visible: true, state: PUBLISHED_STATE, verified_by: user.id, verified_at: Time.now)
      end

      # Mark post as declined. This method called by api request.
      def decline!
        return true if declined?

        update(visible: false, state: DECLINED_STATE, declined_by: user.id, declined_at: Time.now)
      end

      # Mark post as deleted. This method called by api request.
      def delete!
        return true if deleted?

        set(visible: false, active: false, deleted_at: Time.now, state: DELETED_STATE)
        save(changed: true)
        deleted?
      end

      # This method called by cron
      def self.flush!
        persisted = 0
        flushed = 0
        ids = []
        dataset = Post.where { Sequel.&({ active: false }, (deleted_at < Time.now)) }
        dataset.use_cursor(rows_per_fetch: 100).each do |post|
          ### code
        end
        Post.where(id: ids).delete if ids.any?
        [persisted, flushed]
      end
    end
  end
end
