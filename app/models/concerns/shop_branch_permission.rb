module ShopBranchPermission
  extend ActiveSupport::Concern

  PERMISSIONS_HASH = {
      'vip'      => {
          'manage_vip_consume'           => '会员消费',
          'manage_vip_recharge'          => '会员充值',
          'manage_vip_point'             => '积分调节',
          'manage_vip_gift_exchange'     => '礼品兑换',
          'view_vip_transactions'        => '消费统计',
          'manage_vip_money_adjustment'  => '金额调节',
          'manage_vip_package_release'   => '套餐发放',
          'manage_vip_package_write_off' => '套餐核销'
      },
      'activity' => { 'manage_marketing_sncode' => '活动核销' },
      'hotel'    => {
          'manage_hotel_branches'  => '分店管理',
          'manage_hotel_roomtypes' => '房型管理',
          'manage_hotel_comments'  => '评论管理',
          'manage_hotel_orders'    => '订单管理',
          'manage_hotel_marketing' => '营销管理'
      },
      'catering' => {
          'manage_catering_book_rules'      => '规则设定',
          'manage_catering_menus'           => '菜单管理',
          'manage_catering_book_dinner'     => '订餐管理',
          'manage_catering_book_table'      => '订座管理',
          'manage_catering_reports'         => '销售日报表',
          'manage_catering_reports_graphic' => '下单时间分析',
      },
      'takeout' => {
          'manage_takeout_book_rules'      => '规则设定',
          'manage_takeout_menus'           => '菜单管理',
          'manage_takeout_orders'          => '外卖管理',
          'manage_takeout_reports'         => '销售日报表',
          'manage_takeout_reports_graphic' => '下单时间分析',
      }
  }

  PERMISSION_NAMES = {
      'vip'      => '会员卡',
      'activity' => '微活动',
      'hotel'    => '微酒店',
      'catering' => '微餐饮',
      'takeout'  => '微外卖',
  }

  module ClassMethods

    def permission_names
      PERMISSION_NAMES
    end

    def permission_name(key)
      PERMISSION_NAMES[key]
    end

    def permissions_hash
      PERMISSIONS_HASH
    end

    def all_permissions
      PERMISSIONS_HASH.values.map(&:keys).flatten!
    end

    PERMISSIONS_HASH.each do |key, hash|
      define_method "#{key}_permissions" do
        hash.keys
      end
    end

  end

  def all_permissions?(key)
    return false unless SubAccount.respond_to?("#{key}_permissions")
    related_permissions = SubAccount.public_send("#{key}_permissions")
    related_permissions & permissions.to_a == related_permissions
  end

  def has_permission?(permission)
    permissions.to_a.include?(permission)
  end

  alias can? has_permission?

  def can_not?(do_action)
    !can?(do_action)
  end

  def can_any?(*actions)
    actions.flatten.any? { |action| can?(action) }
  end

  def can_manage_any_vip?
    can_any?(PERMISSIONS_HASH['vip'].keys)
  end

  def can_manage_marketing_sncode?
    can?('manage_marketing_sncode')
  end

  def can_manage_hotel?
    can_any?(PERMISSIONS_HASH['hotel'].keys)
  end

  def can_manage_catering?
    can_any?(PERMISSIONS_HASH['catering'].keys)
  end

  def can_manage_takeout?
    can_any?(PERMISSIONS_HASH['takeout'].keys)
  end

end