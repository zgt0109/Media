class Account < ActiveRecord::Base
  has_secure_password

  store :metadata, accessors: [:auth_mobile]

  attr_accessor :current_password

  validates :nickname, presence: true, uniqueness: { case_sensitive: false }, length: { within: 2..20, too_short: '太短了，最少3位', too_long: "太长了，最多20位" }
  validates :email, email: true, presence: true#, uniqueness: { case_sensitive: false }
  validates :mobile, presence: true, format: { with: /^\d{11}$/, message: '手机格式不正确' }
  validates :password, presence: { message: '不能为空', on: :create }, length: { within: 6..20, too_short: '太短了，最少6位', too_long: "太长了，最多20位" }, allow_blank: true
  validates_confirmation_of :password, message: '确认不一致'

  enum_attr :account_type, :in => [
    ['normal_account', 1, '正式帐号'],
    ['trial_account',  2, '试用帐号'],
    ['free_account',  3, '免费帐号'],
  ]

  enum_attr :status, :in => [
    ['pending', 0, '待审核'],
    ['active',  1, '正常'],
    ['froze',  -1, '已冻结']
  ]

  has_one :print
  has_one :pay_account
  has_many :payments

  has_one :site
  has_many :sites

  after_create :init_site

  def self.current
    Thread.current[:account]
  end

  def self.current=(account)
    Thread.current[:account] = account
  end

  def self.authenticated(nickname, password)
    #where("lower(nickname) = ?", nickname.to_s.downcase).first.try(:authenticate, password)
    where("lower(nickname) LIKE ?", nickname.to_s.downcase).first.try(:authenticate, password)
  end

  def update_all_system_messages
    if system_messages.unread.update_all(is_read: true) > 0
      uri = URI.parse("http://#{FAYE_HOST}/faye")
      Net::HTTP.post_form(uri, message: {channel: "/system_messages/change/#{id}", data: {operate: 'delete_all'}}.to_json)
    end
  end

  def update_sign_in_attrs_with(sign_in_ip)
    update_attributes(
      sign_in_count: sign_in_count.next,
      last_sign_in_at: current_sign_in_at,
      last_sign_in_ip: current_sign_in_ip,
      current_sign_in_at: Time.now,
      current_sign_in_ip: sign_in_ip
    )
  end

  def expired?
    expired_at.nil? || expired_at < Time.now
  end

  def need_auth_mobile?
    auth_mobile.to_i != 1
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    AccountMailer.password_reset(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while Account.exists?(column => self[column])
  end

  private

  def init_site
    sites.create(name: nickname, password: 'mUc3m00RsqyRf', password_confirmation: 'mUc3m00RsqyRf')
  end

end
