class VipPackagesVipUser < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :wx_mp_user
  belongs_to :vip_user
  belongs_to :vip_package
  belongs_to :shop_branch
  has_one :vip_user_transaction, as: :transactionable
  has_many :vip_package_item_consumes

  store :metadata, accessors: [ :vip_package_item_ids, :payment_type ]

  scope :latest, -> { order('created_at DESC') }
  scope :unexpired, -> { where("expired_at > ?", Time.now) }
  scope :expired, -> { where("expired_at < ?", Time.now) }

  enum_attr :payment_type, in: [
    ['by_balance', '1', '会员卡余额支付'],
    ['by_cash',    '2', '现金支付'],
  ]

  def self.export_excel(search)
    xls_report = StringIO.new
    book = VipPackagesVipUser.new_excel
    book_excel = book[0]
    book_sheet = book[1]
	  export_title = ['套餐名称', '套餐价格', '支付方式', '会员卡号', '会员姓名', '手机号码', '发放时间', '发放门店', '备注']
    sing_sheet = []
    sing_sheet << export_title

    search.each do |s|
      sing_sheet << [s.vip_package.name, s.vip_package.price, s.payment_type_name, s.vip_user.try(:user_no), s.vip_user.try(:name), s.vip_user.try(:mobile), s.created_at.strftime("%Y-%m-%d %H:%M:%S"), s.shop_branch.try(:name) || '商户总部', s.description].flatten
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
    sheet = book.create_worksheet :name => "发放记录"
    return [book,sheet,bold_heading]
  end

  def unexpired?
    expired_at > Time.now
  end

  def expired?
    expired_at < Time.now
  end

  def update_vip_user_amount(amount_source)
    vip_user.decrease_amount!(vip_package.price,"消费",{able: "vip_packages"}) if by_balance?
    vip_user.wx_user.qrcode_user_amount("vip_amount",vip_package.price) if by_cash?
    vip_user.vip_user_transactions.create(direction_type: VipUserTransaction::PAY_DOWN,
                                  direction: VipUserTransaction::OUT,
                                  amount: vip_package.price,
                                  total_amount: vip_user.total_amount,
                                  usable_amount: vip_user.usable_amount,
                                  supplier_id: supplier.id,
                                  description: description,
                                  payment_type: payment_type,
                                  transactionable: self,
                                  shop_branch_id: shop_branch_id,
                                  amount_source: amount_source)
    self.save!
  end


end
