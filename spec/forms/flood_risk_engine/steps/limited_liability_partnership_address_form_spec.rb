require "rails_helper"
require_relative "../../../support/shared_examples/form_objects"
require_relative "../../../support/asserts"

module FloodRiskEngine
  module Steps

    RSpec.describe LimitedLiabilityPartnershipAddressForm, type: :form do
      let(:params_key) { :limited_liability_partnership_address }

      let(:enrollment) { create(:page_limited_liability_partnership_address) }

      let(:model_class) { FloodRiskEngine::Address }

      let(:form) { LimitedLiabilityPartnershipAddressForm.factory(enrollment) }

      let(:valid_post_code) { "BS1 5AH" }

      subject { form }

      it_behaves_like "a form object"

      it { is_expected.to be_a(LimitedLiabilityPartnershipAddressForm) }

      it "is not redirectable" do
        expect(form.redirect?).to_not be_truthy
      end

      context "with valid params" do
        def form_requires_address_no_street_lookup
          VCR.use_cassette("forms_address_form_no_street_from_dropdown") do
            yield
          end
        end

        def form_requires_address_lookup
          VCR.use_cassette("forms_address_form_valid_uprn_from_dropdown") do
            yield
          end
        end

        let(:valid_attributes) {
          {
            "#{form.params_key}": { post_code: valid_post_code, uprn: "340116" }
          }
        }

        it "is valid when valid UK UPRN supplied via drop down rendering process_address" do
          form_requires_address_lookup do
            expect(form.validate(valid_attributes)).to eq true
          end
        end

        let(:valid_but_no_street_address) {
          {
            "#{form.params_key}": { post_code: "HX3 0TD", uprn: "10010175140" }
          }
        }

        it "is valid when valid UK UPRN supplied via drop down but no street_address present" do
          form_requires_address_no_street_lookup do
            expect(form.validate(valid_but_no_street_address)).to eq true
          end
        end

        describe "Save" do
          it "saves a valid address on enrollment" do
            form_requires_address_lookup do
              form.validate(valid_attributes)
              expect(form.save).to eq true
            end

            expect(subject.model.postcode).to eq(valid_attributes[:post_code])

            address = subject.enrollment.reload.organisation.primary_address

            expected_attributes = {
              address_type: "primary",
              premises: "HORIZON HOUSE",
              street_address: "DEANERY ROAD",
              locality: nil,
              city: "BRISTOL",
              postcode: valid_attributes[params_key][:post_code],
              uprn: valid_attributes[params_key][:uprn]
            }

            assert_record_values address, expected_attributes

            expect(address.addressable_id).to eq subject.enrollment.organisation.id
            expect(address.addressable_type).to eq "FloodRiskEngine::Organisation"
          end
        end
      end
    end
  end
end
