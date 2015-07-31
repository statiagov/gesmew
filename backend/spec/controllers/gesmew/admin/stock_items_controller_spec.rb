require 'spec_helper'

module Gesmew
  module Admin
    describe StockItemsController, :type => :controller do
      stub_authorization!

      context "formats" do
        let!(:stock_item) { create(:variant).stock_items.first }

        it "destroy stock item via js" do
          expect {
            gesmew_delete :destroy, format: :js, id: stock_item
          }.to change{ StockItem.count }.by(-1)
        end
      end
    end
  end
end
