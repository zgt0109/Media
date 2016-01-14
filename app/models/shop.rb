class Shop < ActiveRecord::Base

  enum_attr :shop_type, :in => [['micro_store', 1, '微门店'],['book_dinner', 2, '订餐订座'],['take_out', 3, '外卖']]

  validates :name, presence: true

  belongs_to :site
  has_many :shop_branches, dependent: :destroy
  has_many :shop_categories, dependent: :destroy
  has_many :shop_products, dependent: :destroy
  has_many :shop_menus, dependent: :destroy
  has_many :shop_order_reports, dependent: :destroy
  has_many :activities, as: :activityable, order: :activity_type_id, dependent: :destroy
  has_one :micro_shop_activity, class_name: 'Activity', as: :activityable, conditions: {activity_type_id: ActivityType::MICRO_STORE}
  # has_one :book_dinner_activity, through: :activityable, source: :activityable, conditions: { activity_type_id: 6 }
  accepts_nested_attributes_for :shop_categories, reject_if: proc { |attributes| attributes['name'] == '' }

  after_create :create_default_activities

  def logo_url
    qiniu_image_url(logo)
  end

  def check_activities_exist?
    return activities.where("activity_type_id in (?)", [6,7]).count > 0 if book_dinner?
    return activities.where("activity_type_id = ?", 9).count > 0 if take_out?
  end

  def create_default_activities
    now = Time.now

    new_activities = []

    if book_dinner?
      new_activities = [
        {
          site_id: site_id,
          activity_type_id: 6,
          activityable: self,
          status: 1,
          name: "微订餐",
          keyword: "微订餐",
          pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
          ready_at: now+1.seconds,
          start_at: now+1.seconds,
          end_at: now+100.years
        },
        {
          site_id: site_id,
          activity_type_id: 7,
          activityable: self,
          status: 1,
          name: "微订座",
          keyword: "微订座",
          pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
          ready_at: now+2.seconds,
          start_at: now+2.seconds,
          end_at: now+100.years
        }
      ]

      update_attributes(shop_type: BOOK_DINNER)
    elsif take_out?
      new_activities = [
        {
          site_id: site_id,
          activity_type_id: 9,
          activityable: self,
          status: 1,
          name: "微外卖",
          keyword: "微外卖",
          pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
          ready_at: now+1.seconds,
          start_at: now+1.seconds,
          end_at: now+100.years
        }
      ]

      update_attributes(shop_type: TAKE_OUT)
    end

    new_activities << {
      site_id: site_id,
      activity_type_id: 11,
      activityable: self,
      status: 1,
      name: "微门店",
      keyword: "微门店",
      pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
      ready_at: now,
      start_at: now,
      end_at: now+100.years
    }

    new_activities.each do |attrs|
      Activity.where(site_id: attrs[:site_id], activity_type_id: attrs[:activity_type_id]).first_or_create(attrs)
    end
  end
end
