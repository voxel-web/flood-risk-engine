module FloodRiskEngine
  module Steps
    class LimitedCompanyPostcodeForm < BaseAddressSearchForm

      def self.factory(enrollment)
        raise(FormObjectError, "No Organisation set for step #{enrollment.current_step}") unless enrollment.organisation

        enrollment.address_search ||= AddressSearch.new

        new(enrollment.address_search, enrollment)
      end

      def self.params_key
        :limited_company_postcode
      end

      def target_step
        :correspondence_contact_name
      end

    end
  end
end
