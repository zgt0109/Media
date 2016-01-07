# == Schema Information
#
# Table name: supplier_industries
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  sort       :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SupplierIndustry < ActiveRecord::Base
  has_many :suppliers
  has_many :supplier_apps

  scope :visible, -> { where("id NOT IN (?)", [10008]) }

  ENUM_ID_OPTIONS = [
    ['industry_free',        1000, '免费版'],
    ['industry_base',        10000, 'V-领先版'],
    ['industry_food',        10001, '微餐饮'],
    ['industry_takeout',     10002, '微外卖'],
    ['industry_gov',         10003, '微政务'],
    ['industry_car',         10004, '微汽车'],
    ['industry_hotel',       10005, '微酒店'],
    ['industry_trip',        10006, '微旅游'],
    ['industry_commerce',    10007, '微电商'],
    ['industry_house_agent', 10008, '微房产中介'],
    ['industry_house',       10009, '微房产'],
    ['industry_wedding',     10010, '微婚礼'],
    ['industry_education',   10011, '微教育'],
    ['industry_booking',     10012, '微服务'],
    ['industry_hospital',    10013, '微医疗'],
    ['industry_plot',        10014, '微小区'],
    ['industry_bussine',     20001, '微商圈'],
    ['industry_life',        20002, '微生活'],
    ['industry_wmall',       20003, '微客生活圈'],
    ['industry_ec',          20004, '微电商简版'],
    ['industry_shangzhan',   30001, '商站'],
  ]

  enum_attr :id, in: ENUM_ID_OPTIONS
end
