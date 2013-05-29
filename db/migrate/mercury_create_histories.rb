class MercuryCreateHistories < ActiveRecord::Migration
  def change
    create_table :mercury_history do |t|
      t.integer :user_id
      t.integer :page_id
      t.integer :region_id
      t.text :region_changes
      t.timestamps
    end
    add_index :mercury_history, :user_id
    add_index :mercury_history, :page_id
    add_index :mercury_history, :region_id
  end
end
