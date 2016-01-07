class HouseLayoutPanorama < ActiveRecord::Base
  belongs_to :house_layout

  validates_presence_of :house_layout_id#, :tile0, :tile1, :tile2, :tile3, :tile4, :tile5, :name

  (0..5).each do |i|
    define_method "tile#{i}_url" do
      current_tile = self.send "tile#{i}".to_sym
      current_tile.present? ?  qiniu_image_url(current_tile) : ""
    end
  end
end
