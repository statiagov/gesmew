# coding: UTF-8
require 'spec_helper'

describe Gesmew::Admin::NavigationHelper, type: :helper do

  describe "#tab" do
    before do
      allow(helper).to receive(:cannot?).and_return false
    end

    context "creating an admin tab" do
      it "should capitalize the first letter of each word in the tab's label" do
        admin_tab = helper.tab(:inspection)
        expect(admin_tab).to include("Inspections")
      end
    end

    it "should accept options with label and capitalize each word of it" do
      admin_tab = helper.tab(:inspection, label: "delivered inspections")
      expect(admin_tab).to include("Delivered Orders")
    end

    it "should capitalize words with unicode characters" do
      # overview
      admin_tab = helper.tab(:inspection, label: "přehled")
      expect(admin_tab).to include("Přehled")
    end

    describe "selection" do
      context "when match_path option is not supplied" do
        subject(:tab) { helper.tab(:inspection) }

        it "should be selected if the controller matches" do
          allow(controller).to receive(:controller_name).and_return("inspections")
          expect(subject).to include('selected')
        end

        it "should not be selected if the controller does not match" do
          allow(controller).to receive(:controller_name).and_return("bonobos")
          expect(subject).not_to include('selected')
        end

      end

      context "when match_path option is supplied" do
        before do
          allow(helper).to receive(:request).and_return(double(ActionDispatch::Request, fullpath: "/admin/inspections/edit/1"))
        end

        it "should be selected if the fullpath matches" do
          allow(controller).to receive(:controller_name).and_return("bonobos")
          tab = helper.tab(:inspection, label: "delivered inspections", match_path: '/inspections')
          expect(tab).to include('selected')
        end

        it "should be selected if the fullpath matches a regular expression" do
          allow(controller).to receive(:controller_name).and_return("bonobos")
          tab = helper.tab(:inspection, label: "delivered inspections", match_path: /inspections$|inspections\//)
          expect(tab).to include('selected')
        end

        it "should not be selected if the fullpath does not match" do
          allow(controller).to receive(:controller_name).and_return("bonobos")
          tab = helper.tab(:inspection, label: "delivered inspections", match_path: '/shady')
          expect(tab).not_to include('selected')
        end

        it "should not be selected if the fullpath does not match a regular expression" do
          allow(controller).to receive(:controller_name).and_return("bonobos")
          tab = helper.tab(:inspection, label: "delivered inspections", match_path: /shady$|shady\//)
          expect(tab).not_to include('selected')
        end
      end
    end
  end

  describe '#klass_for' do

    it 'returns correct klass for Gesmew model' do
      expect(klass_for(:inspection)).to eq(Gesmew::Inspection)
      expect(klass_for(:establishments)).to eq(Gesmew::Establishment)
    end

    it 'returns correct klass for non-gesmew model' do
      class MyUser
      end
      expect(klass_for(:my_users)).to eq(MyUser)

      Object.send(:remove_const, 'MyUser')
    end

    it 'returns correct namespaced klass for non-gesmew model' do
      module My
        class User
        end
      end

      expect(klass_for(:my_users)).to eq(My::User)

      My.send(:remove_const, 'User')
      Object.send(:remove_const, 'My')
    end

  end

end
