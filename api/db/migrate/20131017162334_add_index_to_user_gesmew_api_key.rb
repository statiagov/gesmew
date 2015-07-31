class AddIndexToUserGesmewApiKey < ActiveRecord::Migration
  def change
    unless defined?(User)
      add_index :gesmew_users, :gesmew_api_key
    end
  end
end
