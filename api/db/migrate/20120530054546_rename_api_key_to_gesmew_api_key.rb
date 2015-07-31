class RenameApiKeyToGesmewApiKey < ActiveRecord::Migration
  def change
    unless defined?(User)
      rename_column :gesmew_users, :api_key, :gesmew_api_key
    end
  end
end
