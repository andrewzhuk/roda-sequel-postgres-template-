# frozen_string_literal: true

module Application
  # no doc
  module Models
    # no doc
    class Post < Sequel::Model
      # New state has been created.
      CREATED_STATE = 1
      # Processing attached media files on background.
      PROCESSING_STATE = 2
      # The post is pending verification, waiting for staffing.
      PENDING_VERIFICATION_STATE = 3
      PUBLISHED_STATE = 4
      DECLINED_STATE = 5
      DELETED_STATE = 6

      STATE_TO_NAME_TABLE = {
        CREATED_STATE => 'created',
        PROCESSING_STATE => 'processing',
        PENDING_VERIFICATION_STATE => 'pending',
        PUBLISHED_STATE => 'published',
        DECLINED_STATE => 'declined',
        DELETED_STATE => 'deleted'
      }.freeze

      # Sets the pool created if there is no pool.
      def after_initialize
        self.state = CREATED_STATE if state.nil?
        super
      end

      def state_name
        STATE_TO_NAME_TABLE[state] || 'unknown'
      end

      def active?
        active
      end

      def created?
        state == CREATED_STATE
      end

      def processing?
        state == PROCESSING_STATE
      end

      def published?
        state == PUBLISHED_STATE
      end

      def declined?
        state == DECLINED_STATE && !declined_at.nil?
      end

      def deleted?
        !deleted_at.nil?
      end

      def visible?
        visible
      end
    end
  end
end
