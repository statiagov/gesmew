class GesmewInitial < ActiveRecord::Migration
  def up
    create_table :gesmew_assets do |t|
      t.references :viewable,               :polymorphic => true
      t.integer    :attachment_width
      t.integer    :attachment_height
      t.integer    :attachment_file_size
      t.integer    :position
      t.string     :attachment_content_type
      t.string     :attachment_file_name
      t.string     :type,                   :limit => 75
      t.datetime   :attachment_updated_at
      t.text       :alt
    end

    add_index :gesmew_assets, [:viewable_id],          :name => 'index_assets_on_viewable_id'
    add_index :gesmew_assets, [:viewable_type, :type], :name => 'index_assets_on_viewable_type_and_type'

    create_table :gesmew_configurations do |t|
      t.string     :name
      t.string     :type, :limit => 50
      t.timestamps null: false
    end

    add_index :gesmew_configurations, [:name, :type], :name => 'index_gesmew_configurations_on_name_and_type'

    create_table :gesmew_mail_methods do |t|
      t.string     :environment
      t.boolean    :active,     :default => true
      t.timestamps null: false
    end


    create_table :gesmew_roles do |t|
      t.string :name
    end

    create_table :gesmew_role_users, :id => false do |t|
      t.references :role
      t.references :user
    end

    add_index :gesmew_role_users, [:role_id], :name => 'index_gesmew_role_users_on_role_id'
    add_index :gesmew_role_users, [:user_id], :name => 'index_gesmew_role_users_on_user_id'

    create_table :gesmew_trackers do |t|
      t.string     :environment
      t.string     :analytics_id
      t.boolean    :active,       :default => true
      t.timestamps null: false
    end

    create_table :gesmew_preferences do |t|
      t.text       :value
      t.string     :key
      t.string     :value_type
      t.timestamps null: false
    end

    add_index :gesmew_preferences, [:key], :name => 'index_gesmew_preferences_on_key', :unique => true

    create_table :gesmew_districts do |t|
      t.string     :name
      t.string     :abbr
    end

    create_table :gesmew_contact_information do |t|
      t.string        :firstname
      t.string        :lastname
      t.string        :address
      t.references    :district
      t.string        :phone
      t.string        :alternative_phone
      t.timestamps    null: false
    end

    add_index :gesmew_contact_information, [:firstname], :name => 'index_addresses_on_firstname'
    add_index :gesmew_contact_information, [:lastname],  :name => 'index_addresses_on_lastname'


    create_table :gesmew_users do |t|
      t.string     :encrypted_password,     :limit => 128
      t.string     :password_salt,          :limit => 128
      t.string     :email
      t.string     :remember_token
      t.string     :persistence_token
      t.string     :reset_password_token
      t.string     :perishable_token
      t.integer    :sign_in_count,                         :default => 0, :null => false
      t.integer    :failed_attempts,                       :default => 0, :null => false
      t.datetime   :last_request_at
      t.datetime   :current_sign_in_at
      t.datetime   :last_sign_in_at
      t.string     :current_sign_in_ip
      t.string     :last_sign_in_ip
      t.string     :login
      t.string     :authentication_token
      t.string     :unlock_token
      t.datetime   :locked_at
      t.datetime   :remember_created_at
      t.datetime   :reset_password_sent_at
      t.timestamps null: false
    end

    create_table :establishments do |t|
      t.string     :name
      t.references :establishment_type
      t.references :contact_information

      t.timestamps null: false
    end

    create_table :establishment_types do |t|
      t.string :name
      t.string :description
    end


  end
end