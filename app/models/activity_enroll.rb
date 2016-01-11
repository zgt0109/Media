# == Schema Information
#
# Table name: activity_enrolls
#
#  id              :integer          not null, primary key
#  activity_id     :integer          not null
#  wx_user_id      :integer          not null
#  username        :string(255)
#  mobile          :string(255)
#  email           :string(255)
#  qq              :string(255)
#  company_tel     :string(255)
#  home_tel        :string(255)
#  province_name   :string(255)
#  city_name       :string(255)
#  company_address :string(255)
#  company_name    :string(255)
#  contact         :string(255)
#  home_address    :string(255)
#  status          :integer          default(1), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ActivityEnroll < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :activity
  belongs_to :wx_user

  after_create :hook_supplier_applies

  include Spread::Spreads

  def attrs(attr)
    if self.has_attribute?(attr)
      self.send(attr)
    else
      unless self.spreads
        nil
      else
        return self.spreads.send(attr)
      end
    end
  end

  def set_attrs(attr, value)
    value = value.to_s
    if self.has_attribute?(attr)
      self.update_attribute(attr, value)
    else
      self.spreads.send("#{attr}=", value)
    end
    value
  end

  def secure_mobile
    secure = mobile || ''
    if secure.length > 10
      secure[4..7] = '****' rescue ''
    end
    secure
  end

  def hook_supplier_applies
    # if self.activity.id == 24792 || self.activity.id == 24783
    if self.activity.id == 10201
      # 微枚迪免费试用申请, 欢迎开通!
      # 姓名,手机,邮箱,qq,公司名称, username, mobile, email, qq, company_name
      supplier_apply = AccountApply.new(apply_type: AccountApply::APPLY_FROM_winwemedia)
      supplier_apply.business_type = 1
      supplier_apply.contact = self.username
      supplier_apply.email = self.email
      supplier_apply.tel = self.mobile
      supplier_apply.qq = self.qq
      supplier_apply.name = self.company_name
      supplier_apply.save(validate: false)
    # elsif self.id == 12903
    elsif self.activity.id == 10202
      # 微动中国—微营销商学院课程
      # 姓名,手机,qq,所在城市,公司名称
      supplier_apply = AccountApply.new(apply_type: AccountApply::APPLY_FROM_winwemedia)
      supplier_apply.business_type = 1
      supplier_apply.contact = self.username
      supplier_apply.tel = self.mobile
      supplier_apply.qq = self.qq
      supplier_apply.name = self.company_name
      #处理城市
      province = Province.where("name like ?", "%#{self.city_name}%").first if self.city_name
      city = City.where("name like ?", "%#{self.city_name}%").first if self.city_name
      district = District.where("name like ?", "%#{self.city_name}%").first if self.city_name
      supplier_apply.city = city if city
      supplier_apply.province = province if province
      supplier_apply.district = district if district
      supplier_apply.save(validate: false)
    end
  end

end
