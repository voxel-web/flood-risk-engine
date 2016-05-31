module FloodRiskEngine
  module Steps

    class LocalAuthorityAddressForm < BaseAddressForm

      def self.factory(enrollment)
        raise(FormObjectError, "No Organisation set for step #{enrollment.current_step}") unless enrollment.organisation

        address = enrollment.organisation.primary_address || FloodRiskEngine::Address.new(address_type: :primary)

        new(address, enrollment)
      end

      def self.params_key
        :local_authority_address
      end

      property :postcode, virtual: true

      # read only param for displaying the Postcode in the view
      def postcode
        return enrollment.address_search.postcode if enrollment.address_search.present?

        return enrollment.organisation.primary_address.postcode if enrollment.organisation.primary_address.present?

        ""
      end

      private

      def initialize(model, enrollment)
        super(model, enrollment)

        # Consensus is that the original drop down list should be displayed when a user clicks Back,
        # If address fields required local_authority_address_back can include partials 'shared/address_fields'
        # or 'shared/display_address'
        partial = "flood_risk_engine/enrollments/steps/local_authority_address_back"

        @partial_to_render = partial if enrollment.organisation.primary_address.present?
      end

    end
  end
end
