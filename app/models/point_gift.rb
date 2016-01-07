# == Schema Information
#
# Table name: point_gifts
#
#  id          :integer          not null, primary key
#  supplier_id :integer
#  gift_no     :string(255)      not null
#  name        :string(255)      not null
#  description :text
#  points      :integer          default(0), not null
#  price       :decimal(12, 2)
#  pic         :string(255)
#  status      :integer          default(1), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class PointGift < ActiveRecord::Base
  mount_uploader :pic, PhotoUploader
  img_is_exist({pic: :qiniu_pic_key})
  has_time_range start_at: :exchange_start_at, end_at: :exchange_end_at

  belongs_to :supplier
  has_many   :point_gift_exchanges
  has_many   :point_transactions, as: :pointable
  has_many   :consumes, through: :point_gift_exchanges
  has_and_belongs_to_many :shop_branches, uniq: true
  has_and_belongs_to_many :vip_grades, conditions: "vip_grades.status IN(0,1)", uniq: true

  validates :pic, presence: true, on: :create, if: "qiniu_pic_key.blank?"
  validates :points, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :name, :exchange_start_at_exchange_end_at, presence: true
  validates :sku, :people_limit_count, presence: true, numericality: { greater_than_or_equal_to: -1, only_integer: true }
  validates :award_in_days, presence: true, numericality: { greater_than: 0, only_integer: true }#, if: :award_time_limited?

  scope :latest, -> { order('created_at DESC') }
  scope :unexpired, -> { where("exchange_end_at >= ?", Time.now) }
  scope :exchangeable, -> { online.where(":time BETWEEN exchange_start_at AND exchange_end_at", time: Time.now) }
  scope :shop_branch_limited, -> { where(shop_branch_limited: true) }
  scope :shop_branch_unlimited, -> { where(shop_branch_limited: false) }

  before_save :clear_vip_grades, if: :all_grades?
  after_save :associate_shop_branches

  enum_attr :status, in: [
    ['online',  1, '有效'],
    ['offline', 2, '无效'],
    ['deleted', 0, '删除'],
  ]

  def state_name
    return status_name unless online?
    return '已过期' if expired?
    return '未生效' unless started?
    '有效'
  end

  def expired?
    exchange_end_at.nil? || exchange_end_at < Time.now
  end

  def unexpired?
    !expired?  
  end

  def deleteable?
    !(online? && started? && unexpired?)
  end

  def exchangeable_for?( vip_user )
    return true if all_grades?
    return true if vip_grades.visible.pluck(:id).include?(vip_user.vip_grade_id)
  end

  def vip_grade_names
    return "所有会员" if all_grades?
    vip_grades.visible.sorted.pluck(:name).join('，')
  end

  def exchangeable_num
    return -1 if sku == -1
    num = sku - point_gift_exchanges.sum(:qty)
    num < 0 ? 0 : num
  end

  def sku_lack?
    exchangeable_num == 0 || exchangeable_num < -1
  end

  def started?
    exchange_start_at.present? && exchange_start_at < Time.now
  end

  def limit_count_for( vip_user )
    count = people_limit_count
    if count != -1
      count -= point_gift_exchanges.where(vip_user_id: vip_user.id).sum(:qty)
      count = 0 if count < 0
    end
    count
  end

  def limited_for?(vip_user)
    limit_count_for(vip_user) == 0
  end

  def limit_count_name( vip_user )
    count = limit_count_for vip_user
    count == -1 ? '无限' : "#{count}次"
  end

  def award_time_end_at
    ( Time.now + award_in_days.to_i.days ).end_of_day if award_time_limited?
  end

  def shop_branches_count
    if shop_branch_limited?
      shop_branch_ids.count
    else
      supplier.shop_branches.used.count
    end
  end

  def self.export_excel(search, options = {})
    xls_report = StringIO.new
    book = PointGift.new_excel
    book_excel, book_sheet = book[0], book[1]
    export_title = %w(序号 姓名 电话 使用时间 使用门店 SN码 状态)
    export_title[1, 0] = '礼品名称' if options[:include_gift]
    sing_sheet = [ export_title ]

    search.to_a.each_with_index do |exchange,index|
      if exchange.used?
        shop_branch = exchange.consume.applicable.name rescue '商户总部'
        code = exchange.consume.code
      end
      values = [(index+1),exchange.vip_user.name,exchange.vip_user.mobile,exchange.updated_at.strftime("%Y-%m-%d %H:%M:%S"),shop_branch,code,exchange.status_name].flatten
      values[1, 0] = exchange.point_gift.name if options[:include_gift]
      sing_sheet << values
    end
    sing_sheet.each_with_index do |new_sheet,index|
      book_sheet.insert_row(index,new_sheet)
    end
    book_excel.write(xls_report)
    return xls_report.string
  end

  def self.new_excel
    Spreadsheet.client_encoding = "UTF-8"
    book = Spreadsheet::Workbook.new
    bold_heading = Spreadsheet::Format.new(weight: :bold, align: :merge)
    name = "礼品兑换"
    sheet = book.create_worksheet name: name
    return [book,sheet,bold_heading]
  end

  def pic_url
    qiniu_image_url(qiniu_pic_key) || pic
  end

  private
    def associate_shop_branches
      self.shop_branch_ids = supplier.shop_branches.used.pluck(:id) unless shop_branch_limited?
    end

    def clear_vip_grades
      self.vip_grade_ids = []
    end

end
