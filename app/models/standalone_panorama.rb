class StandalonePanorama < ActiveRecord::Base
  belongs_to :panoramic, polymorphic: true

  def file_key
    file_url.to_s.split("/").last
  end
end
