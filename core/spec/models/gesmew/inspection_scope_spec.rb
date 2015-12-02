require 'spec_helper'

describe Gesmew::Inspection, type: :model do
  context "callbackes" do
   let(:scope) {create(:inspection_scope)}

   it {expect(scope).to callback(:update_rubric_assessment_criteria).after(:update)}
  end
end
