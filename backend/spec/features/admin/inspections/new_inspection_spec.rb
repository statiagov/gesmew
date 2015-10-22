require 'spec_helper'

describe "New Inspection", :type => :feature, js:true do
  let!(:establishment) { create(:establishment, name:'Duggins Shopping Center N.V.', firstname: 'Louise', lastname: 'Gumbs') }
  let!(:user_1) { create(:admin_user,email: 'user_1@example.com', firstname:'Ingrid', lastname:'Houtman') }
  let!(:user_2) { create(:admin_user,email: 'user_2@example.com', firstname:'Bernadine', lastname:'Woodley') }
  let!(:scope){create(:inspection_scope, name:'Containers', description:'Grading container inspections')}
  let!(:rubric){create(:rubric, context:scope)}
  let(:rubric_params) do
      {
        id:rubric.id,
        title:rubric.title,
        criteria: [
          {
            points:9,
            description:"Some description",
            name:"Temperature",
          },
          {
            points:10,
            description:"Some description",
            name:'Floors',
          }
        ]
      }
  end
  before do
    rubric.update_criteria(rubric_params)
    allow_any_instance_of(Gesmew::Admin::InspectionsController).to receive_messages(:try_gesmew_current_user => user_1)
  end
  stub_authorization!

  describe "Going from pending state to grade and assess state" do
    before do
      visit gesmew.new_admin_inspection_path
    end
    context "Invalid input" do
      it "does not go to the next step"  do
        click_button('Next Step')
        sleep 2.second
        expect(find('.sweet-alert')).to have_content('Yes, proceed to to next step.')
        click_button('Yes, proceed to to next step.')
        expect(page).to have_content('errors')
      end
    end

    context "Valid input" do
      it "goes to the next step" do
        select2_search establishment.name, from: Gesmew.t(:establishment_name_select)
        click_button('Select')
        wait_for_ajax
        expect(page).to have_content(establishment.name)
        select2_search user_1.firstname, from: Gesmew.t(:first_or_lastname)
        click_icon :add
        wait_for_ajax
        expect(page).to have_content(user_1.fullname)
        select2_search user_2.firstname, from: Gesmew.t(:first_or_lastname)
        click_icon :add
        wait_for_ajax
        expect(page).to have_content(user_2.fullname)
        select2_search scope.name, from: Gesmew.t(:inspection_scope_name_select)
        click_button('Select')
        wait_for_ajax
        expect(page).to have_content(scope.name)
        click_button('Next Step')
        sleep 2.seconds
        expect(find('.sweet-alert')).to have_content('Yes, proceed to to next step.')
        click_button('Yes, proceed to to next step.')
        inspection = Gesmew::Inspection.first
        expect(current_path).to eq gesmew.grade_and_comment_admin_inspection_path(inspection)
      end
    end
  end

  describe "Going from the grade and assess state to" do
    let!(:inspection){create(:inspection, establishment:establishment, scope:scope)}
    before do
      array = [user_1, user_2]
      inspection.add_inspector(array)
      rubric.associate_with(inspection, scope)
    end

    describe "Showing the rubric" do
      context "when the current user is not part of the inspection" do
        let(:user_3){create(:admin_user)}
        before do
          allow_any_instance_of(Gesmew::Admin::InspectionsController).to receive_messages(:try_gesmew_current_user => user_3)
          visit gesmew.grade_and_comment_admin_inspection_path(inspection)
        end
        it "rubric does not show" do
          expect(page).to_not have_content('Rubric')
          expect(page).to have_content Gesmew.t(:you_are_not_part_of_this_inspection)
        end
      end

      context "when the current user is part of the inspection" do
        let(:user_3){create(:admin_user)}
        before do
          visit gesmew.grade_and_comment_admin_inspection_path(inspection)
          sleep 60.minutes
        end
        it "rubric does show" do
          expect(page).to have_content('Rubric')
          expect(page).to_not have_content Gesmew.t(:you_are_not_part_of_this_inspection)
        end
      end
    end
  end
end
