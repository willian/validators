module ActiveModel
  module Validations
    class IpAddressValidator < EachValidator
      def validate_each(record, attribute, value)
        return if value.blank? && options[:allow_blank]
        return if value.nil? && options[:allow_nil]

        valid = false

        case options[:only]
        when :v4
          valid = Validators::Ip.v4?(value.to_s)
          scope = :invalid_ipv4_address
        when :v6
          valid = Validators::Ip.v6?(value.to_s)
          scope = :invalid_ipv6_address
        else
          valid = Validators::Ip.valid?(value.to_s)
          scope = :invalid_ip_address
        end

        unless valid
          record.errors.add(
            attribute, scope,
            :message => options[:message], :value => value
          )
        end
      end

      def check_validity!
        raise ArgumentError, ":only accepts a symbol that can be either :v6 or :v4" if options.key?(:only) && ![:v4, :v6].include?(options[:only])
      end
    end

    module ClassMethods
      # Validates weather or not the specified URL is valid.
      #
      #   validates_ip_address :ip  #=> accepts both v4 and v6
      #   validates_ip_address :ip, :only => :v4
      #   validates_ip_address :ip, :only => :v6
      #
      def validates_ip_address(*attr_names)
        validates_with IpAddressValidator, _merge_attributes(attr_names)
      end
    end
  end
end
