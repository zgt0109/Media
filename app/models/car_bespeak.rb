# == Schema Information
#
# Table name: car_bespeaks
#
#  id            :integer          not null, primary key
#  supplier_id   :integer          not null
#  wx_mp_user_id :integer          not null
#  wx_user_id    :integer          not null
#  car_shop_id   :integer          not null
#  car_brand_id  :integer          not null
#  car_catena_id :integer          not null
#  bespeak_type  :integer          default(1), not null
#  bespeak_date  :date             not null
#  plate_number  :string(255)
#  name          :string(255)      not null
#  mobile        :string(255)      not null
#  description   :text             default(""), not null
#  order_date    :integer          default(1), not null
#  order_budget  :integer          default(1), not null
#  status        :integer          default(1), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class CarBespeak < ActiveRecord::Base

  # validates :bespeak_date, presence: true

  belongs_to :car_shop
  belongs_to :car_brand
  belongs_to :car_catena
  belongs_to :car_type
  belongs_to :wx_mp_user
  belongs_to :site

  has_many :car_bespeak_options, through: :car_bespeak_option_relationships
  has_many :car_bespeak_option_relationships

  enum_attr :status, :in => [
    ['unvisit', 1, '未上门'],
    ['visited', 2, '已上门'],
    ['cancel', 3, '已取消'],
    ['deleted', -1, '已删除'],
  ]

  enum_attr :bespeak_type, :in => [
    ['repair', 1, '保养预约'],
    ['test_drive', 2, '试驾预约'],
  ]

  enum_attr :order_date, :in => [
    ['one_week', 2, '7天内'],
    ['half_month', 3, '15天内'],
    ['one_month', 4, '30天内'],
    ['trimester', 5, '90天内'],
  ]

  enum_attr :order_budget, :in => [
    ['three_hundred_thousand', 2, '30万以内'],
    ['four_hundred_thousands', 3, '30万－40万'],
    ['million', 4, '40万－100万'],
  ]

  scope :show, -> { where("status > 0") }

  after_create :igetui 

	def visit!
		update_attributes(status: VISITED) if unvisit?
	end

	def delete!
		update_attributes(status: DELETED) unless deleted?
	end

  def cancel!
    update_attributes(status: CANCEL) unless cancel?
  end

  def bespeak_status
    if unvisit?
      '未上门'
    elsif visited?
      '已上门'
    elsif cancel?
      '已取消'
    elsif car_brand.try(:deleted?) or car_catena.try(:deleted?)
      '已删除'
    end
  end

  private

    def igetui
      RestClient.post("#{MERCHANT_APP_HOST}/v1/igetuis/igetui_app_message", {role: 'supplier', role_id: supplier_id, token: supplier.try(:auth_token), messageable_id: self.id, messageable_type: 'CarBespeak', source: 'winwemedia_car', message: '您有一个汽车的新预约，请注意查看。'})
    rescue => e
      Rails.logger.info "#{e}" 
    end

end
