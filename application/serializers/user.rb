# frozen_string_literal: true

module Application
  # no doc
  module Serializers
    # no doc
    class User
      def to_hash(options = {})
        self.class.to_hash_collection([self], options).first
      end

      def self.to_hash_collection(records, options = {})
        collection = []
        records.each do |record|
          hash = {}
          hash[:username] = record.username
          hash[:first_name] = record.first_name
          hash[:last_name] = record.last_name
          hash[:username] = record.username
          hash[:language] = record.language
          hash[:banned] = record.banned?
          if options[:show_private]
            hash[:email] = record.email
            hash[:updated_at] = Time.at(record.updated_at).utc.iso8601
          end
          if options[:admin_list] || options[:admin_show]
            hash[:email] = record.email
            hash[:role] = record.role_name
          end
          hash[:created_at] = Time.at(record.created_at).utc.iso8601
          collection << hash
        end
        collection
      end
    end
  end
end
