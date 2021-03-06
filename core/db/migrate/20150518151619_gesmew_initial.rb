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
      t.timestamps null: false
    end

    create_table :gesmew_role_users, :id => false do |t|
      t.references :role
      t.references :user
      t.timestamps null: false
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

    create_table :gesmew_contact_information do |t|
      t.string        :email
      t.string        :firstname
      t.string        :lastname
      t.string        :fullname
      t.string        :address
      t.string        :country, :default => "Caribbean Netherlands"
      t.string        :district
      t.string        :phone_number
      t.timestamps    null: false
    end

    add_index :gesmew_contact_information, [:firstname], :name => 'index_contact_information_on_firstname'
    add_index :gesmew_contact_information, [:lastname],  :name => 'index_contact_information_on_lastname'
    add_index :gesmew_contact_information, [:fullname],  :name => 'index_contact_information_on_fullname'


    create_table :gesmew_users do |t|
      t.string     :encrypted_password,     :limit => 128
      t.string     :password_salt,          :limit => 128
      t.string     :email
      t.string     :firstname
      t.string     :lastname
      t.string     :fullname
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

    create_table :gesmew_establishments do |t|
      t.string     :name
      t.string     :number, :limit => 15
      t.references :establishment_type,  :null => false
      t.references :contact_information, :null => false
      t.timestamps null: false
    end

    add_index :gesmew_establishments, [:establishment_type_id], :name => 'index_gesmew_establishments_on_establishment_type_id'
    add_index :gesmew_establishments, [:contact_information_id], :name => 'index_gesmew_establishments_on_contact_information_id'

    create_table :gesmew_establishment_types do |t|
      t.string :name, :null => false
      t.text   :description
      t.timestamps null: false
    end

    create_table :gesmew_state_changes do |t|
      t.string     :name
      t.string     :previous_state
      t.references :stateful
      t.string     :stateful_type
      t.string     :next_state
      t.timestamps null: false
    end

    add_index :gesmew_state_changes, [:stateful_id, :stateful_type]

    create_table :gesmew_inspection_types do |t|
      t.string :name, :null => false
      t.string :description
      t.timestamps null: false
    end

    create_table :gesmew_inspections do |t|
      t.string      :number, :limit => 15
      t.references  :establishment
      t.integer     :scope_id
      t.string      :scope_type
      t.boolean     :assessed, default: false
      t.string      :state
      t.datetime    :completed_at
      t.date        :inspected_at, default: Date.today
      t.boolean     :considered_risky
      t.integer     :state_lock_version, default: 0, null: false
      t.float       :criteria_count
      t.timestamps  null: false
    end

    add_index :gesmew_inspections, [:establishment_id], :name => 'index_gesmew_inspections_on_establishment_id'

    create_table :gesmew_comments do |t|
      t.string      :title, limit: 50, default: ""
      t.text        :comment
      t.references  :commentable, polymorphic: true
      t.references  :user
      t.string      :role, default: "comments"

      t.timestamps null: false
    end

    add_index :gesmew_comments, :commentable_type
    add_index :gesmew_comments, :commentable_id
    add_index :gesmew_comments, :user_id

    create_table :gesmew_inspection_scopes do |t|
      t.string :name
      t.text   :description
    end

    create_table :gesmew_inspection_users do |t|
      t.belongs_to :user
      t.belongs_to :inspection
      t.timestamps null: false
    end

    add_index :gesmew_inspection_users, [:inspection_id], :name => 'index_gesmew_inspection_users_on_inspection_id'
    add_index :gesmew_inspection_users, [:user_id], :name => 'index_gesmew_inspection_users_on_user_id'

    create_table :gesmew_rubrics do |t|
      t.belongs_to :user
      t.integer :context_id
      t.string :context_type
      t.text :data
      t.integer :criteria_count
      t.string :title
      t.text :description
      t.boolean :read_only, default: false
      t.timestamps null: false
    end
    add_index :gesmew_rubrics, [:context_id, :context_type], :name => 'index_gesmew_rubrics_on_context_id_and_context_type'

    create_table :gesmew_rubric_associations do |t|
      t.belongs_to :rubric
      t.integer :association_id
      t.string :association_type
      t.string :context_type
      t.integer :context_id
      t.string :title
      t.text :description
      t.text :summary_data
      t.string :url
      t.timestamps null: false
    end
    add_index :gesmew_rubric_associations,[:association_id, :association_type], :name => 'index_gesmew_rubric_associations_on_ass_id_and_ass_type'

    create_table :gesmew_rubric_assessments do |t|
      t.integer :assessor_id
      t.belongs_to :rubric
      t.belongs_to :rubric_association
      t.integer :criterion_met_count
      t.text :data
      t.integer :artifact_id
      t.string :artifact_type
      t.timestamps null: false
    end
    add_index :gesmew_rubric_assessments,[:artifact_id, :artifact_type], :name => 'index_gesmew_rubric_asessments_on_arti_id_and_arti_type'
  end
end
