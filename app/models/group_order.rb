class GroupOrder < ActiveRecord::Base
  belongs_to :site
  belongs_to :user
  belongs_to :group_item
  belongs_to :payment_type
  has_many   :group_comments
  has_many   :payments, as: :paymentable

  scope :today, -> { where("date(created_at) = ?", Date.today) }

  enum_attr :status, :in => [
    ['pending',  1,  '待支付'],
    ['paid',     2,  '已付款'],
    ['canceled', 3,  '已取消'],
    ['expired',  4,  '已过期'],
    ['consumed', 5,  '已消费'],
    ['completed',6,  '已完成']
  ]

  scope :latest, -> { order('group_orders.created_at DESC') }
  scope :paid_or_consumed, -> { where("status = ? or status = ?", 2, 5) }

  before_create :add_default_attrs, :generate_order_no, :generate_sn_code, :count_total_amount

  after_find do |user|
    self.payment_type_id ||= 10003
  end

  def self.export_excel(search)
    name, export_title = get_export_name_and_title
    book_excel, book_sheet = new_excel(name)

    book_sheet.insert_row(0, export_title)
    search.each_with_index do |transaction, i|
      book_sheet.insert_row(i + 1, transaction.exportings)
    end
    StringIO.new.tap { |s| book_excel.write(s) }.string
  end

  def self.get_export_name_and_title
    ['团购订单', %w(订单号 支付流水号 支付方式 SN码 商品名称 订单金额 状态 下单时间)]
  end

  def self.new_excel(name)
    Spreadsheet.client_encoding = "UTF-8"
    book = Spreadsheet::Workbook.new
    bold_heading = Spreadsheet::Format.new(:weight => :bold, :align => :merge)
    sheet = book.create_worksheet :name => name
    [book, sheet, bold_heading]
  end

  def exportings
    [ order_no, payments.success.try(:first).try(:trade_no), payment_type.try(:name), code, group_item.try(:name), total_amount, status_name, created_at.strftime('%F %T') ].flatten
  end

  def payment_request_params(params = {})
    params = HashWithIndifferentAccess.new(params)

    _order_params = {
      payment_type_id: payment_type_id,
      account_id: site.account_id,
      site_id: site_id,
      customer_id: user_id,
      customer_type: 'User',
      paymentable_id: id,
      paymentable_type: 'GroupOrder',
      out_trade_no: order_no,
      amount: total_amount,
      body: "订单 #{order_no}",
      subject: "订单 #{order_no}",
      source: 'group_order'
    }

    params.reverse_merge(_order_params)
  end

  def delete!
    update_attributes!(status: CANCELED, canceled_at: Time.now)
  end

  def pay!
    update_attributes!(status: PAID)
  end

  def consume!
    update_attributes!(status: CONSUMED, consume_at: Time.now)
  end

  def self.get_conditions params
    conn = [[]]
    conn[0] << "wmall_shops.id is not null"
    conn[0] << "group_items.group_type = 2"
    if params[:shop_id].present?
      conn[0] << "wmall_shops.id = ?"
      conn << params[:shop_id]
    end
    if params[:shop_name].present?
      conn[0] << "wmall_shops.name like ?"
      conn << "%#{params[:shop_name]}%"
    end
    conn[0] = conn[0].join(' and ')
    return conn
  end

  def rqrcode
    rqrcode = nil
    1.upto(12) do |size|
      break rqrcode = RQRCode::QRCode.new(code, :size => size, :level => :h ).to_img.resize(258, 258) rescue next
    end
    rqrcode
  end

  private

  def add_default_attrs
    return unless group_item
    self.site_id = group_item.site_id
    self.group_id = group_item.group_id
  end

  def generate_order_no
    self.order_no = Concerns::OrderNoGenerator.generate
  end

  def generate_sn_code
    self.code = rand(10000000...100000000)
  end

  def count_total_amount
    self.total_amount = self.qty * self.price
  end

end
