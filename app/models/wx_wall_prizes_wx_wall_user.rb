class WxWallPrizesWxWallUser < ActiveRecord::Base
  belongs_to :wx_wall
  belongs_to :wx_wall_user, touch: true
  belongs_to :wx_wall_prize

  before_create :generate_code

  enum_attr :status, :in => [
    ['deleted', -1, '已删除'],
    ['pending',  1, '未领奖'],
    ['awarded',  2, '已领奖']
  ]
  scope :show, -> { where(status: [1,2]) }
  scope :free_mode_users, -> { where("wx_wall_prize_id is null") }
  scope :random_mode_users, -> { where("wx_wall_prize_id is not null") }

  def delete!
    update_attributes(status: DELETED)
  end

  def avatar_url
    if avatar.to_s =~ /\Ahttp/
      avatar
    else
      qiniu_image_url(avatar)
    end
  end

  private
    def generate_code
      self.sn_code = ::SnCodeGenerator.generate_code(self,"sn_code")
    end
end
