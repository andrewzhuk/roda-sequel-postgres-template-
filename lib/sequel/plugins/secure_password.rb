# frozen_string_literal: true

require 'sequel'
require 'bcrypt'
# Usage
# Plugin should be used in subclasses of Sequel::Model. Always call super in validate method of your model,
# otherwise password validations won't be executed. It does not set_allowed_columns
# and mass assignment policy must be managed separately.
#
# class User < Sequel::Model
#   plugin :secure_password
# end
#
# # cost option can be used to change computational complexity of BCrypt
# class HighCostUser < Sequel::Model
#   plugin :secure_password, cost: 12
# end
#
# # include_validations option can be used to disable default password
# # presence and confirmation
# class UserWithoutValidations < Sequel::Model
#   plugin :secure_password, include_validations: false
# end
#
# # digest_column option can be used to use an alternate database column.
# # the default column is "password_digest"
# class UserWithAlternateDigestColumn < Sequel::Model
#   plugin :secure_password, digest_column: :password_hash
# end
#
# user = User.new
# user.password = "foo"
# user.password_confirmation = "bar"
# user.valid? # => false
#
# user.password_confirmation = "foo"
# user.valid? # => true
#
# user.authenticate("foo") # => user
# user.authenticate("bar") # => nil

module Sequel
  module Plugins
    module SecurePassword
      def self.blank_string?(string)
        string.nil? or string =~ /\A\s*\z/
      end

      # Configure the plugin by setting the available options. Options:
      # * :cost - the cost factor when creating password hash. Default:
      # BCrypt::Engine::DEFAULT_COST(10)
      # * :include_validations - when set to false, password present and
      # confirmation validations won't be included. Default: true
      def self.configure(model, options = {})
        model.instance_eval do
          @cost = options.fetch(:cost, BCrypt::Engine.cost)
          @include_validations = options.fetch(:include_validations, true)
          @digest_column = options.fetch(:digest_column, :password_digest)
        end
      end

      module ClassMethods
        attr_reader :cost, :include_validations, :digest_column

        # NOTE: nil as a value means that the value of the instance variable
        # will be assigned as is in the subclass.
        Plugins.inherited_instance_variables(self, :@cost => nil, :@include_validations => nil, :@digest_column => nil)
      end

      module InstanceMethods
        attr_accessor :password_confirmation
        attr_reader :password

        def password=(unencrypted)
          @password = unencrypted

          unless SecurePassword.blank_string?(unencrypted)
            self.send "#{model.digest_column}=", BCrypt::Password.create(unencrypted, cost: model.cost)
          end
        end

        def authenticate(unencrypted)
          if BCrypt::Password.new(self.send(model.digest_column)) == unencrypted
            self
          end
        end

        def validate
          super

          if model.include_validations
            errors.add(:password, 'is not present') if SecurePassword.blank_string?(self.send(model.digest_column))
            errors.add(:password, 'doesn\'t match confirmation') if password != password_confirmation
          end
        end
      end
    end
  end
end
