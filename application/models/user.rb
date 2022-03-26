# frozen_string_literal: true

require 'digest'

module Application
  # no doc
  module Models
    # no doc
    class User < Sequel::Model
      plugin :many_through_many
      plugin :secure_password
      plugin :async_thread_pool
      # Require dependencies
      require_relative 'user/states'

      many_to_many :posts, left_key: :user_id, right_key: :post_id

      # Validations using Sequel
      def validate
        super
        errors.add(:email, 'cannot_be_empty') unless !(!email || email.empty?)
        errors.add(:email, 'is_not_a_valid_email') unless email =~ VALID_EMAIL_REGEX

        errors.add(:username, 'cannot_be_empty') if !username || username.empty?
        selects = [
          Application.db[:users].select(:email).where(email: values[:email]).as(:e),
          Application.db[:users].select(:username).where(username: values[:username]).as(:u)
        ]
        hash = Application.db.select {selects}.first
        errors.add(:email, 'is_already_taken') if email && new? && !hash[:e].nil?
        errors.add(:username, 'is_already_taken') if username && new? && !hash[:u].nil?
      end

      def toggle_ban!
        update(banned_at: banned? ? nil : Time.now)
      end

      # Assign user as author. This method called by api request.
      def toggle_author_role!
        update(role: author? ? CUSTOMER_ROLE : AUTHOR_ROLE)
        true
      end

      # Assign user as moderator. This method called by api request.
      def toggle_moderator_role!
        update(role: moderator? ? CUSTOMER_ROLE : MODERATOR_ROLE)
        true
      end
    end
  end
end
