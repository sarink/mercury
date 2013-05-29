class MercuryCreatePagesRegions < ActiveRecord::Migration
  def change
    create_table :mercury_pages_regions, :id => false do |t|
      t.integer :page_id
      t.integer :region_id
    end
    add_index :mercury_pages_regions, :page_id
    add_index :mercury_pages_regions, :region_id
  end
end
