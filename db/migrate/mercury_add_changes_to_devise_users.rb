class MercuryAddChangesToDeviseUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :admin, :boolean, :default => false
    add_column :users, :username, :string
  end

  def self.down
    remove_column :users, :username
    remove_column :users, :admin
  end
end