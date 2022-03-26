# frozen_string_literal: true
require 'stringex'

module Application
  # no doc
  module Models
    # no doc
    class Post < Sequel::Model
      plugin :after_initialize

      # Require dependencies
      require_relative 'post/actions'
      require_relative 'post/states'

      many_to_one :user

      dataset_module do
        where :published, visible: true, active: true, deleted_at: nil
      end

      def validate
        super
        errors.add(:title, 'cannot-be-empty') if !title || title.empty?
        errors.add(:title, 'is-already-taken') if title && new? && Post[{ title: title }]
        errors.add(:body, 'cannot-be-empty') if !body || body.empty?
        errors.add(:active, 'is-not-boolean') unless [true, false].include?(active)
      end

      def plained_body
        # r
      end

      def before_validation
        self.active ||= true if new?
        self.lang = 'en'
        self.slug ||= generate_slug if new?
        super
      end

      # Sequel hook.
      def before_create
        self.token = generate_token
        super
      end

      protected

      def generate_slug
        variations = [title.to_url, "#{title.to_url}-#{lang}", "#{title.to_url}-#{token}"]
        variations.each do |variation|
          break variation unless self.class.where(slug: variation).any?
        end
      end

      def generate_token(number = 8)
        return unless token.nil?

        loop do
          charset = Array('a'..'z') + Array('0'..'9')
          random_token = Array.new(number) { charset.sample }.join
          break random_token unless self.class.where(token: random_token).any?
        end
      end
    end
  end
end
