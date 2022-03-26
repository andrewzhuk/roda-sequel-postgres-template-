# frozen_string_literal: true

module Application
  # no doc
  module Models
    # no doc
    class User < Sequel::Model
      VALID_EMAIL_REGEX = URI::MailTo::EMAIL_REGEXP # /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

      # Roles
      CUSTOMER_ROLE = 1
      ADMIN_ROLE = 100
      AUTHOR_ROLE = 200
      MODERATOR_ROLE = 300

      ROLE_TO_NAME_TABLE = {
        ADMIN_ROLE => 'admin',
        CUSTOMER_ROLE => 'customer',
        AUTHOR_ROLE => 'author',
        MODERATOR_ROLE => 'moderator',
      }.freeze

      ALL_STAFFS_TABLE = {
        ADMIN_ROLE => 'admin',
        MODERATOR_ROLE => 'moderator',
      }.freeze

      def admin?
        role == ADMIN_ROLE
      end

      def author?
        role == AUTHOR_ROLE
      end

      def customer?
        role == CUSTOMER_ROLE
      end

      def moderator?
        role == MODERATOR_ROLE
      end

      def staff?
        ALL_STAFFS_TABLE.keys.include?(role)
      end

      def role_name
        ROLE_TO_NAME_TABLE[role] || 'unknown'
      end

      def locked?
        !locked_at.nil?
      end

      def banned?
        !banned_at.nil?
      end
    end
  end
end
