module Mercury
  class Region < ActiveRecord::Base
    self.table_name = :mercury_regions
    has_and_belongs_to_many :pages, :join_table => 'mercury_pages_regions', class_name: Mercury::Page
    has_many :histories, class_name: Mercury::History
    serialize :attrs
    serialize :snippets
    attr_accessible :id, :region_name, :region_type, :attrs, :snippets, :value
  end
end