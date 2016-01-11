class VipPackageItemConsume < ActiveRecord::Base
include HasBarcode

  belongs_to :site
  belongs_to :wx_mp_user
  belongs_to :vip_user
  belongs_to :shop_branch
  belongs_to :vip_package
  belongs_to :vip_package_item
  # belongs_to :vip_package_items_vip_packages
  belongs_to :vip_packages_vip_user

  before_create :generate_code

  enum_attr :status, :in => [
    ['unused',     1, '未使用'],
    ['used',   		 2, '已使用']
  ]

  scope :latest, -> { order('updated_at DESC') }
  scope :unexpired, -> { joins(:vip_packages_vip_user).where("vip_packages_vip_user.expired_at > ?", Time.now) }
  scope :expired, -> { joins(:vip_packages_vip_user).where("vip_packages_vip_user.expired_at < ?", Time.now) }
  scope :by_status, ->(status) { send(status) if status }

  def get_item_html
    "<tr><td>服务项目:</td><td>#{vip_package_item.name}</td></tr>
    <tr><td>SN码:</td><td>#{sn_code}</td></tr>
    <tr><td>会员姓名:</td><td>#{vip_user.name}</td></tr>
    <tr><td>手机号码:</td><td>#{vip_user.mobile}</td></tr>
    <tr><td>发放时间:</td><td>#{created_at.to_date}</td></tr>
    <tr><td>有效期至:</td><td>#{vip_packages_vip_user.expired_at.to_date}</td></tr>
    <tr><td>状态:</td><td>#{human_status_name}</td></tr>"
  end

  def self.export_excel(search)
    xls_report = StringIO.new
    book = VipPackageItemConsume.new_excel
    book_excel = book[0]
    book_sheet = book[1]
    export_title = ['套餐名称', '服务项目', 'SN码', '会员卡号', '会员姓名', '手机号码', '核销时间', '核销门店']
    sing_sheet = []
    sing_sheet << export_title

    search.each do |s|
      sing_sheet << [s.vip_package.name, s.vip_package_item.name, s.sn_code, s.vip_user.try(:user_no), s.vip_user.try(:name), s.vip_user.try(:mobile), s.updated_at.strftime("%Y-%m-%d %H:%M:%S"), s.shop_branch.try(:name)].flatten
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
    bold_heading = Spreadsheet::Format.new(:weight => :bold, :align => :merge)
    sheet = book.create_worksheet :name => "核销记录"
    return [book,sheet,bold_heading]
  end

  def can_use?
    unused? && vip_packages_vip_user.unexpired?
  end

  def human_status_name
    if can_use?
      '可使用'
    elsif used?
      '已使用'
    else
      '已过期'
    end
  end

   def rqrcode
     RQRCode::QRCode.new(sn_code, :size => 4, :level => :h ).to_img.resize(90, 90).to_data_url
  end

  def use_count(count,vip_package_item_id)
    vip_package.vip_package_items_vip_packages.where(vip_package_item_id: vip_package_item_id).first.try(:items_count) == -1 ? "不限次" : "#{count}次"
  end

  def sn_code_type_name
    "套餐券"
  end

  def name
    package_item_name
  end

  def user_type
    "VipUser"
  end

  def user_id
    vip_user_id
  end

  def user_name
    vip_user.name
  end

  def mobile
    vip_user.mobile
  end

  def expired_at
    vip_packages_vip_user.expired_at
  end

  def shop_branch_count
    vip_package.shop_branch_limited? ? vip_package.shop_branch_ids.length : "不限制"
  end

  def validate_shop_branchs(shop_branch_id)
    vip_package.shop_branch_limited? ? vip_package.shop_branch_ids.include?(shop_branch_id) : true
  end

  def use_consume(shop_branch)
    update_attributes(status: VipPackageItemConsume::USED, shop_branch_id: shop_branch.try(:id))
  end

  private
    def generate_code
      self.sn_code = ::SnCodeGenerator.generate_code(self, 'sn_code')
    end
end
