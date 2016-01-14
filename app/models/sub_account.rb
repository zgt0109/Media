class SubAccount < ActiveRecord::Base
  include ShopBranchPermission
  belongs_to :user, polymorphic: true

  scope :unset, -> { where('sub_accounts.permissions IS NULL')     }
  scope :set,   -> { where('sub_accounts.permissions IS NOT NULL') }
  serialize :permissions, JSON
  has_secure_password validations: false

  before_save :set_auth_token

  acts_as_enum :account_type, in: [
    ['shop_account', 1, '门店子账号']
  ]
  
  acts_as_enum :status, in: [
    ['enabled',  1, '已启用'],
    ['disabled', 2, '已停用'],
    ['deleted', -1, '已删除']
  ]

  def toggle_status!
    update_column :status, (enabled? ? DISABLED : ENABLED)
  end

  def status_toggle_text
    enabled? ? '停用' : '启用'
  end

  def method_missing(m, *args, &block)
    if user.is_a?(ShopBranch)
      account = user.account
      if account.respond_to?(m)
        return account.public_send(m, *args, &block)
      end
    elsif user.respond_to?(m)
      return user.public_send(m, *args, &block)
    end
    super
  end

  def account
    user.account
  end

  def app_permissions
    APP_PERMISSIONS & permissions.to_a
  end

  def app_auth_info
    {
      id:                id,
      username:          username,
      role:              'micro_shop',
      token:             auth_token,
      expired_at:        account.expired_at.try(:strftime, '%F'),
      account_type_name: account.account_type_name,
      permissions:       app_permissions
    }
  end

  def vip_packages
    user.available_vip_packages.latest
  end

  private
    def set_auth_token
      self.auth_token = SecureRandom.uuid if auth_token.blank?
    end
end
