# module Mercury
  class Upload < ActiveRecord::Base
    self.table_name = :mercury_uploads
    attr_accessible :upload
    has_attached_file :upload,
      :styles => {
        :thumb => "100x100>"
      }

    include Rails.application.routes.url_helpers

    def to_jq_upload
      return {
        "id" => read_attribute(:id),
        "name" => read_attribute(:upload_file_name),
        "size" => read_attribute(:upload_file_size),
        "url" => upload.url(:original),
        "thumbnail_url" => upload.url(:thumb),
        "delete_url" => upload_path(self),
        "delete_type" => "DELETE"
      }
    end
  end
# end