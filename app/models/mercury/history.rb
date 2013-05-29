module Mercury
  class History < ActiveRecord::Base
    self.table_name = :mercury_history
    belongs_to :user, class_name: User
    belongs_to :page, class_name: Mercury::Page
    belongs_to :region, class_name: Mercury::Region
    serialize :region_changes
    attr_accessible :user, :page, :region, :region_changes
  end
end