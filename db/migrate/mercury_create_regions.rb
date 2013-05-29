class MercuryCreateRegions < ActiveRecord::Migration
  def change
    create_table :mercury_regions do |t|
      t.string :region_name
      t.string :region_type
      t.text :attrs
      t.text :snippets
      t.text :value
      
      t.timestamps
    end
  end
end
