require 'spec_helper'

describe Gesmew::RubricAssessment do
  context "callbacks" do
    let(:assessment){Gesmew::RubricAssessment.create}

    it { expect(assessment).to callback(:update_artifact_assessed).after(:create) }
  end
end
