require "rails_helper"

module FloodRiskEngine
  RSpec.describe Comment, type: :model do
    let(:comment) { FactoryGirl.create(:comment) }
    it "can be associated with enrollment exemptions" do
      expect(comment.commentable.class).to eq(EnrollmentExemption)
    end
  end
end
