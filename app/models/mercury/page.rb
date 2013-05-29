module Mercury
  class Page < ActiveRecord::Base
    self.table_name = :mercury_pages
    has_many :histories
    attr_accessible :title, :name, :description, :regions
    has_and_belongs_to_many :regions, :join_table => 'mercury_pages_regions', class_name: Mercury::Region
  end
end