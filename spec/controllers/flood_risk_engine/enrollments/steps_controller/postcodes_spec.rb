require "rails_helper"
module FloodRiskEngine
  describe Enrollments::StepsController, type: :controller do
    routes { Engine.routes }
    render_views

    let(:enrollment) { FactoryGirl.create(:page_local_authority_postcode) }

    let(:reform_class) { Steps::LocalAuthorityPostcodeForm }

    def put_update(params)
      VCR.use_cassette("postcode_validation_requires_check_on_addresses_returned") do
        put(:update, params, session)
      end
    end

    context "LocalAuthorityPostcodeForm" do
      let(:step) { :local_authority_postcode }

      before do
        get :show, id: step, enrollment_id: enrollment
      end

      it "uses LocalAuthorityPostcodeForm" do
        expect(controller.send(:form)).to be_a(reform_class)
      end

      it "diplays header" do
        header_text = t("#{reform_class.locale_key}.heading")
        expect(response.body).to have_tag :h1, text: /#{header_text}/
      end

      let(:valid_attributes) { { local_authority_postcode: { postcode: "BS1 5AH" } } }

      let(:match_initial_url_step) { /You are being <a href=\"\S+local_authority_postcode/ }

      context "with valid params" do
        it "steps to next page when valid UK postcode supplied on rendering show" do
          params = { id: step, enrollment_id: enrollment }.merge valid_attributes

          put_update(params)

          expect(response).to redirect_to(enrollment_step_path(enrollment, enrollment.next_step))
        end

        it "redirects when when Postcode lookup service is NOT available", duff: true do
          params = { id: step, enrollment_id: enrollment }.merge valid_attributes

          allow_any_instance_of(AddressServices::FindByPostcode).to receive("success?").and_return(false)

          put_update(params)

          expected_regexp = /#{match_initial_url_step}\?check_for_error=true">redirected/
          expect(response.body).to match expected_regexp
        end
      end

      context "with invalid params" do
        let(:invalid_attributes) { { postcode: "BS1 " } }

        it "assigns the enrollment as @enrollment" do
          put_update(id: step, enrollment_id: enrollment)
          expect(assigns(:enrollment)).to eq(enrollment)
        end

        it "redirects when invalid postcode supplied on update" do
          params = { id: step, enrollment_id: enrollment, local_authority_postcode: invalid_attributes }

          put_update(params)

          expected_regexp = /#{match_initial_url_step}\?check_for_error=true">redirected/

          expect(response.body).to match expected_regexp
        end

        it "does not change the state" do
          put_update(id: step, enrollment_id: enrollment)
          expect(assigns(:enrollment).step).to eq(step.to_s)
        end

        it "redirects back to show with check for errors" do
          put(:update, id: step, enrollment_id: enrollment, step => invalid_attributes)
          expect(response).to redirect_to(
            enrollment_step_path(enrollment, step, check_for_error: true)
          )
        end

        it "displays blank error when no postcode supplied on rendering show" do
          params = { id: step, enrollment_id: enrollment, check_for_error: true }
          session = { error_params: { step => { postcode: "" } } }
          expected_error = I18n.t("flood_risk_engine.validation_errors.postcode.blank")

          get(:show, params, session)
          expect(response.body).to have_tag :a, text: expected_error
        end

        it "displays enter valid postcode error when non full UK postcode supplied" do
          params = { id: step, enrollment_id: enrollment, check_for_error: true }
          session = { error_params: { step => { postcode: "BS6 " } } }
          expected_error = I18n.t("flood_risk_engine.validation_errors.postcode.enter_a_valid_postcode")

          get(:show, params, session)
          expect(response.body).to have_tag :a, text: expected_error
        end

        it "displays enter service not working error when Postcode lookup service is NOT available" do
          params = { id: step, enrollment_id: enrollment, check_for_error: true }
          session = {
            error_params: {
              step => { postcode: "BS1 5AH" } # Postcode must be valid to trigger the lookup error
            }
          }

          expected_error = I18n.t("flood_risk_engine.validation_errors.postcode.service_unavailable")

          allow_any_instance_of(AddressServices::FindByPostcode).to receive("success?").and_return(false)

          get(:show, params, session)

          expect(response.body).to have_tag :a, text: expected_error
        end
      end
    end
  end
end