require 'spec_helper'

describe Gesmew::Rubric, type: :model do
  let(:scope){build(:inspection_scope)}
  let(:rubric){Gesmew::Rubric.new(context: scope)}

  describe "#update_criteria" do
    let(:rubric_params) do
      {
        id:rubric.id,
        title:rubric.title,
        criteria: [
          {
            points:9,
            description:"Some description",
          },
          {
            points:10,
            description:"Some description",
          }
        ]
      }
    end

    it "should should save or update the rubric criteria to the database" do
      expect(rubric.points_possible).to eq(nil)
      rubric.update_criteria(rubric_params)
      expect(rubric.points_possible).to eq(19)
    end
  end

  describe "#associate_with" do
    let(:inspection){create(:inspection)}
    it "should associate an object with the rubric" do
      expect(rubric.associate_with(inspection, scope)).to be_a(Gesmew::RubricAssociation)
    end
  end
end
