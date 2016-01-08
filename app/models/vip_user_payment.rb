class VipUserPayment < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :vip_user
  attr_accessor :password

  enum_attr :status, :in => [
    ['ready', 0, '初始化'],
    ['confirm_paid', 1, '确认支付'],
    ['transfer_success', 2, '转帐成功'],
    ['transfer_failure', 3, '转帐失败'],
    ['success', 4, '成功'],
    ['expired', 5, '过期']
  ]

  validates_uniqueness_of :out_trade_no
  validates :amount, numericality: { greater_than_or_equal_to: 0.01 }
  validates :wx_mp_user_id, :open_id, :out_trade_no, :subject, presence: true

  def transfer_params
    transfer_fields = %w(wx_mp_user_id supplier_id open_id out_trade_no subject body source)
    attributes.slice(*transfer_fields).merge(trade_token: vip_user.trade_token, amount: amount.to_f) if confirm_paid?
  end

  def pay_status
    case
      when transfer_success? || success?
        "1"
      when transfer_failure?
        "-1"
    end
  end

  def callback_url_with_trade_result
    uri = URI("#{callback_url}")
    uri.query = trade_result.to_param
    "#{uri}"
  end

  def trade_result
    {
      supplier_id: supplier_id,
      out_trade_no: out_trade_no,
      status: "#{pay_status}",
      amount: amount,
      subject: subject,
      body: body
    }
  end

  def confirm_paid!
    update_attributes!(status: 1) if ready?
  end

  def transfer_success!
    if confirm_paid?
      update_attributes!(status: 2)
    end
  end

  def transfer_failure!
    update_attributes!(status: 3) if confirm_paid?
  end

  def success!
    if transfer_success?
      update_attributes!(status: 4)
    end
  end

  def notify_push
    Thread.new {

      fiber = Fiber.new do
        uri = URI.parse("#{notify_url}")
        Net::HTTP.post_form(uri, trade_result.as_json)
        self.success! if res.body.eql?("success")
      end

      fiber.resume
    }
  end

  class << self
    def build_and_validate(vip_user, params)
      trade_data = HashWithIndifferentAccess.new({
        vip_user_id: vip_user.id,
        wx_user_id: vip_user.wx_user_id,
        open_id: vip_user.wx_user.openid,
        wx_mp_user_id: vip_user.wx_mp_user_id,
        raw_data: params.to_json,
        status: 0
      })

      vip_user_payment = self.new(trade_data.reverse_merge(params))
      vip_user_payment.valid?
      vip_user_payment
    end

    def detected_vip_user(wx_mp_user_id, open_id)
      supplier = WxMpUser.where(id: wx_mp_user_id).first.try(:supplier)
      wx_user = supplier.wx_users.where(uid: open_id).first

      return if supplier.nil? and wx_user.nil?

      supplier.vip_users.visible.where(wx_user_id: wx_user.id).first rescue nil
      #has_many :vip_users
    end

  end
end
