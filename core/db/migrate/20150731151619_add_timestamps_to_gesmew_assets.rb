class AddTimestampsToGesmewAssets < ActiveRecord::Migration
  def change
    add_column :gesmew_assets, :created_at, :datetime
    add_column :gesmew_assets, :updated_at, :datetime
  end
end
