module ActiveModel
  module SecurePassword

    module ClassMethods
      def has_secure_password( options = {} )
        # Load bcrypt-ruby only when has_secure_password is used.
        # This is to avoid ActiveModel (and by extension the entire framework) being dependent on a binary library.
        gem 'bcrypt-ruby', '~> 3.0.0'
        require 'bcrypt'

        attr_reader :password

        if options[:validations] != false
          validates_confirmation_of :password
          validates_presence_of     :password_digest
        end

        include InstanceMethodsOnActivation

        if respond_to?(:attributes_protected_by_default)
          def self.attributes_protected_by_default
            super + ['password_digest']
          end
        end
      end
    end

    module InstanceMethodsOnActivation
      # Returns self if the password is correct, otherwise false.
      def authenticate(unencrypted_password)
        return false if password_digest.blank? || unencrypted_password.blank?
        if BCrypt::Password.new(password_digest) == unencrypted_password
          self
        else
          false
        end
      end
    end

  end
end
