require "rails_helper"
module FloodRiskEngine
  module Enrollments

    describe StepsController do
      routes { Engine.routes }
      render_views
      let(:step) { :partnership_details }
      let(:address) { FactoryGirl.create(:address) }
      let(:contact) { FactoryGirl.create(:contact, address: address) }
      let(:enrollment) do
        FactoryGirl.create(:enrollment, :with_partnership, step: step)
      end
      let(:partner) do
        FactoryGirl.create(
          :partner,
          contact: contact,
          organisation: enrollment.organisation
        )
      end

      describe "partnership_details" do
        before do
          set_journey_token
          partner # ensure partner exists before page rendered
          get :show, id: step, enrollment_id: enrollment
        end

        it "should render page successfully" do
          expect(response).to have_http_status(:success)
        end

        it "should display partner address" do
          expect(partner.address.postcode).to eq(address.postcode)
          expect(response.body).to match(address.postcode)
        end

        context "with second partner" do
          let(:address2) { FactoryGirl.create(:address) }
          let(:contact2) { FactoryGirl.create(:contact, address: address2) }
          let(:partner2) do
            FactoryGirl.create(
              :partner,
              contact: contact2,
              organisation: enrollment.organisation
            )
          end
          before do
            partner2 # ensure 2nd partner exists before page rendered
            get :show, id: step, enrollment_id: enrollment
          end

          it "should display partner address" do
            expect(response.body).to match(address.postcode)
          end

          it "should display second partner address" do
            expect(response.body).to match(address2.postcode)
          end
        end
      end
    end
  end
end
