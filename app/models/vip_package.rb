class VipPackage < ActiveRecord::Base
  belongs_to :site
  belongs_to :wx_mp_user
	has_many :vip_package_items_vip_packages
	has_many :vip_packages_vip_users
  has_many :vip_package_item_consumes
  has_and_belongs_to_many :vip_package_items
  has_and_belongs_to_many :shop_branches, conditions: { status: ShopBranch::USED }

	accepts_nested_attributes_for :vip_package_items_vip_packages, allow_destroy: true

  validates :name, :price, :expiry_num, presence: true
  validates :price, numericality: { greater_than: 0 }, on: :create
  validates :expiry_num, numericality: {greater_than: 0, only_integer: true}

  validate :price_max_value, on: :create

  enum_attr :status, :in => [
    ['active',     1, '已开启'],
    ['stopped',   -1, '已停用'],
    ['deleted',   -2, '已删除']
  ]

  scope :show, -> { where('status >= ?', -1) }
  scope :latest, -> { order('id DESC') }

  def items_name_with_count
  	vip_package_items_vip_packages.map do |asso|
  		"#{asso.vip_package_item.name}#{asso.items_count == -1 ? '不限' : asso.items_count}次"
  	end.join("</br>")
  end

  def get_shop_html
    package_shop_branches = shop_branch_limited ? supplier.shop_branches.used.where(id: shop_branch_ids) : supplier.shop_branches.used
    html = ""
    package_shop_branches.each_with_index do |shop_branch,index|
      checked = "checked='checked'" if index == 0
      html << "<tr>"
      html << "<td><input name='shop_branch_id' type='radio' value='#{shop_branch.id}' #{checked}></td>"
      html << "<td>#{shop_branch.name}</td>"
      html << "</tr>"
    end
    return html
  end

  def old_price
    vip_package_items_vip_packages.map{|vpivp| vpivp.vip_package_item.price * vpivp.items_count }.sum
  end

  def basic_info
    attributes.slice('id', 'name', 'price')
  end

  def release(vip_user_id: nil, shop_branch_id: nil, payment_type: nil, description: nil)
    VipPackageItemConsume.transaction do
      vip_packages_vip_users = vip_packages_vip_users.new(supplier_id: supplier_id,
                                                                        wx_mp_user_id: wx_mp_user_id,
                                                                        vip_user_id: vip_user_id,
                                                                        shop_branch_id: shop_branch_id,
                                                                        description: description,
                                                                        expired_at: Time.now+expiry_num.month,
                                                                        package_name: name,
                                                                        package_price: price,
                                                                        payment_type: payment_type)
      if vip_packages_vip_users.update_vip_user_amount(VipUserTransaction::SHOP_PAY_DOWN)
        vip_package_items_vip_packages.each do |vp|
          vp.items_count.times{vip_package_item_consumes.create(supplier_id: supplier_id,
                                                                    wx_mp_user_id: wx_mp_user_id,
                                                                    vip_user_id: vip_user_id,
                                                                    vip_packages_vip_user_id: vip_packages_vip_users.id,
                                                                    vip_package_item_id: vp.vip_package_item_id,
                                                                    status: VipPackageItemConsume::UNUSED,
                                                                    package_item_name: vp.vip_package_item.name,
                                                                    package_item_price: vp.vip_package_item.price)}
        end
        return true
      else
        return false
      end
    end
  end

  def price_max_value
    total_items_price = vip_package_items_vip_packages.to_a.sum { |v| v.items_count * v.vip_package_item.price }
    if price > total_items_price
      errors.add :price, '不能超过服务项目价格之和'
    end
  end
end
