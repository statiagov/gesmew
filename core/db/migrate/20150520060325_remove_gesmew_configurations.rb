class RemoveGesmewConfigurations < ActiveRecord::Migration
  def up
    drop_table "gesmew_configurations"
  end

  def down
    create_table "gesmew_configurations", force: true do |t|
      t.string   "name"
      t.string   "type",       limit: 50
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "gesmew_configurations", ["name", "type"], name: "index_gesmew_configurations_on_name_and_type"
  end
end
