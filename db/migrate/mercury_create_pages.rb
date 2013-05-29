class MercuryCreatePages < ActiveRecord::Migration
  def change
    create_table :mercury_pages do |t|
      t.string :name
      t.string :title
      t.string :description

      t.timestamps
    end
  end
end
