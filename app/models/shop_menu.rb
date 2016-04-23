class ShopMenu < ActiveRecord::Base
#  belongs_to :shop_branch
  belongs_to :shop
  has_many :shop_products
  has_many :shop_categories, :dependent => :destroy
  has_many :shop_branches
  attr_accessible :menu_no

  before_create :add_default_attrs

  def clone_with_associations
    new_shop_menu = self.dup
    new_shop_menu.save(validate: false)
    self.shop_categories.root.each do |rc|
    	new_rc = rc.dup
    	new_rc.shop_menu_id = new_shop_menu.id
    	new_rc.save(validate: false)
      rc.shop_products.each do |p|
        new_p = p.dup
        unless new_p.shop_category_id
          new_p.shop_menu_id = new_shop_menu.id
          new_p.category_parent_id = new_rc.id
          new_p.save(validate: false)
        end
      end

    	rc.children.each do |c|
    		new_c = c.dup
    		new_c.parent_id = new_rc.id
    		new_c.shop_menu_id = new_shop_menu.id
    		new_c.save(validate: false)
    		c.children_products.each do |p|
    			new_product = p.dup
    			new_product.shop_category_id = new_c.id
          new_product.category_parent_id = new_rc.id
    			new_product.shop_menu_id = new_shop_menu.id
    			new_product.save(validate: false)
    		end
    	end
    end
  end

  private

  def add_default_attrs
    self.menu_no = Concerns::OrderNoGenerator.generate
  end

end
