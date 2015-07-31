require 'spec_helper'

module Gesmew
  module Admin
    describe StockLocationsController, :type => :controller do
      stub_authorization!

      # Regression for #4272
      context "with no countries present" do
        it "cannot create a new stock location" do
          gesmew_get :new
          expect(flash[:error]).to eq(Gesmew.t(:stock_locations_need_a_default_country))
          expect(response).to redirect_to(gesmew.admin_stock_locations_path)
        end
      end

      context "with a default country present" do
        before do
          country = FactoryGirl.create(:country)
          Gesmew::Config[:default_country_id] = country.id
        end

        it "can create a new stock location" do
          gesmew_get :new
          expect(response).to be_success
        end
      end

      context "with a country with the ISO code of 'US' existing" do
        before do
          FactoryGirl.create(:country, iso: 'US')
        end

        it "can create a new stock location" do
          gesmew_get :new
          expect(response).to be_success
        end
      end
    end
  end
end
