# frozen_string_literal: true

module Application
  # no doc
  module Serializers
    # no doc
    class Post
      def to_hash(options = {})
        self.class.to_hash_collection([self], options).first
      end

      def self.to_hash_collection(records, options = {})
        return [] unless records.any?

        collection = []
        records.each do |record|
          hash = {}
          hash[:token] = record.token
          hash[:state] = record.state_name
          hash[:author] = record.author_data if options[:show_post_author]
          hash[:body] = record.body if options[:show_post_body]
          hash[:body] = record.plained_body if options[:show_post_plain_body]
          hash[:title] = record.title
          hash[:slug] = record.slug
          hash[:language] = record.lang
          hash[:active] = record.active
          hash[:deleted_at] = record.deleted_at&.utc&.iso8601 if record.deleted?
          hash[:updated_at] = record.updated_at&.utc&.iso8601
          hash[:created_at] = (record.verified_at || record.created_at)&.utc&.iso8601
          if options[:return_selected_attributes].is_a?(Array)
            options[:return_selected_attributes].each do |attribute|
              hash[attribute.to_sym] = record.[](attribute.to_sym)
            end
          end
          collection << hash
        end
        collection
      end
    end
  end
end
