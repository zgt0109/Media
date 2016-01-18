class UserCloner
  attr_accessor :from_user, :user, :wx_mp_user, :cloned

  def initialize(from_nickname = 'winwemedia')
    self.from_user = Account.where(nickname: from_nickname).first || Account.first
    self.cloned    = Hash.new { |h, key| h[key] = {} if key.present? }
  end

  def run!
    create_assistants_sites
    clone_materials

    clone_marketing_activities
    clone_website
    clone_vip_card
    #clone_shops
    clone_activity_forms
    clone_votes
    clone_surveys
    clone_groups
    clone_albums

    clone_replies

    clone_college
    clone_car_shop
    clone_hotel
    clone_house
    clone_weddings
  rescue => e
    puts "error: #{e.message}"
    puts e.backtrace
  end

  # 初始化优惠券，并不是复制
  def init_activities
    init_activity_by_coupon
    init_activity_by_fans_game
  end

  def init_activity_by_coupon
    return puts "activity coupon existed" if user.activities.coupon.show.first
    user.wx_mp_user.create_activity_for_coupon
  end

  def init_activity_by_fans_game
    # return puts "activity fans_game existed" if user.activities.fans_game.first
    user.wx_mp_user.create_activity_for_fans_game
  end

  def clone_to(nickname: 'foogee')
    self.user = Account.where(nickname: nickname).first
    return puts "user not exists" unless user
    return puts "wx_mp_user not exists" unless user.wx_mp_user

    self.wx_mp_user = user.wx_mp_user

    run!
  end

  def create_assistants_sites
    return puts "assistant_sites existed" if AssistantsSite.where(supplier_id: user.id).exists?
    Assistant.pluck(:id).each do |assistant_id|
      next if cloned["AssistantsSite"][assistant_id]
      new_record = AssistantsSite.create! assistant_id: assistant_id, supplier_id: user.id
      cloned["AssistantsSite"][assistant_id] = new_record.id
    end
  end

  def clone_materials
    from_user.materials.root.where(material_type: [1,2]).each { |root|
      new_root = clone_record(root)
      root.children.each do |child|
        clone_record(child, parent_id: new_root.id)
      end if new_root
    }
  end

  def clone_replies
    wx_mp_user.replies.map &:destroy
    from_user.wx_mp_user.replies.each do |reply|
      options = { wx_mp_user_id: wx_mp_user.id }
      if reply.replyable.is_a?(Activity)
        new_activity = clone_activity(reply.replyable)
        clone_activity_associations(reply.replyable, new_activity) if new_activity
      end
      options[:replyable_id] = cloned_id(reply.replyable)
      new_record = clone_record(reply, options)
    end

    set_or_create_first_follow_reply
    set_or_create_text_reply
  end

  def set_or_create_first_follow_reply
    reply = wx_mp_user.first_follow_reply || wx_mp_user.replies.new(event_type: Reply::CLICK_EVENT)
    reply.reply_type = Reply::ACTIVITY
    reply.save!
    reply.update_column :replyable_id, user.website.activity_id
  end

  def set_or_create_text_reply
    # 设置智能客服
    reply = wx_mp_user.text_reply || wx_mp_user.replies.new(event_type: Reply::TEXT_EVENT)
    content = "尊敬的客户，感谢您的互动，我们会尽快回复您的留言！
查找导航栏请回复“微会员卡”或“微官网”"
    reply.attributes = { replyable_id: nil, replyable_type: nil, reply_type: Reply::TEXT, content: content }
    reply.save!
  end

  def clone_marketing_activities
    # clone_activity_by_marketing(:old_coupon)
    clone_activity_by_marketing(:gua)
    clone_activity_by_marketing(:wheel)
    clone_activity_by_fight
  end

  def clone_activity_by_marketing(name = :gua, options = {})
    return puts "activity #{name} existed" if user.activities.starting.__send__(name).exists?
    activity = from_user.activities.starting.__send__(name).first
    now = Time.now
    attrs = { ready_at: now, start_at: now, end_at: now + 7.days }
    new_activity = clone_activity(activity, attrs.merge(options))
    return false unless activity && new_activity
    clone_activity_associations(activity, new_activity)
  end

  def clone_activity_by_fight
    return puts "activity fight existed" if user.activities.fight.starting.exists?
    activity     = from_user.activities.fight.starting.first
    new_activity = clone_activity(activity)
    return false unless activity && new_activity
    clone_fight_activity_associations(activity, new_activity)
  end

  def clone_fight_activity_associations(activity, new_activity)
    clone_activity_associations(activity, new_activity)
    activity.fight_papers.each { |paper|
      new_paper = clone_record(paper, activity_id: new_activity.id)
      paper.fight_questions.each do |question|
        new_question = clone_record(question)
        paper.fight_paper_questions.where(fight_question_id: question.id).each { |paper_question|
          clone_record(paper_question, fight_paper_id: new_paper.id, fight_question_id: new_question.id)
        } if new_question
      end
    }
  end

  def clear_activity_associations(new_activity)
    return false unless new_activity

    new_activity.activity_property.try(:delete)
    new_activity.activity_notices.map(&:delete)
    new_activity.activity_prizes.map(&:delete)
  end

  def clone_activity_associations(activity, new_activity)
    return false unless activity && new_activity

    clear_activity_associations(new_activity)

    clone_record(activity.activity_property, activity_id: new_activity.id)

    activity.activity_notices.each do |notice|
      if cloned?(notice)
        new_notice = ActivityNotice.where(id: cloned_id(notice)).first
        copy_record(notice, new_notice, activity_id: new_activity.id)
      else
        clone_record(notice, activity_id: new_activity.id)
      end
    end

    clone_activity_prizes(activity, new_activity)
  end

  def clone_activity_prizes(activity, new_activity)
    clone_associations(activity, :activity_prizes, activity_id: new_activity.id)
  end


  #***** Clone Website *****
  def clone_website
    user.website.try(:activity).try(:destroy)
    user.website.try :destroy

    website, activity  = from_user.website, from_user.website.activity
    return false unless website && activity
    new_activity = clone_activity(activity)
    return false unless new_activity
    new_activity.activity_notices.delete_all

    Website.micro_site.where(supplier_id: new_activity.supplier_id).map &:destroy
    # new_activity.website.destroy
    clone_activity_associations(activity, new_activity)
    new_website = clone_record(website, activity_id: new_activity.id)
    new_website.update_attributes(domain: nil)

    clone_website_setting(website, new_website)
    clone_website_menus(website, new_website)
    clone_website_popup_menus(website, new_website)
    clone_website_pictures(website, new_website)
  end

  def clone_website_menus(website, new_website)
    website.website_menus.root.each { |menu|
      clone_menu_children(menu, new_website)
    }
  end

  def clone_menu_children(menu, new_website, options = {})
    new_menu = clone_menu(menu, new_website, options)
    menu.children.each do |child|
      clone_menu_children(child, new_website, parent_id: new_menu.id)
    end
  end

  def clone_menu(menu, new_website, options = {})
    menuable = menu.menuable
    if menuable.is_a?(Activity)
      new_activity = clone_activity(menuable)
      clone_activity_associations(menuable, new_activity) if new_activity
    end
    attrs = { website_id: new_website.id }.merge!(options)
    new_menu = clone_record(menu, attrs)
    new_menu.update_column :menuable_id, cloned_id(menuable) if menuable
    new_menu
  end

  def clone_activity(activity, options={})
    clone_record(activity, options={})
  end

  def clone_website_popup_menus(website, new_website)
    website.website_popup_menus.each do |pop_menu|
      clone_menu(pop_menu, new_website)
    end
  end

  def clone_website_pictures(website, new_website)
    website.website_pictures.each do |picture|
      clone_record(picture, website_id: new_website.id)
    end
  end

  def clone_website_setting(website, new_website)
    if new_website.website_setting
      attrs = website.website_setting.attributes
      attrs.delete('id')
      attrs.delete('website_id')
      new_website.website_setting.update_attributes(attrs)
    else
      clone_record(website.website_setting, website_id: new_website.id)
    end
  end





  def clone_vip_card
    VipCard.where(supplier_id: user.id).each do |card|
      card.activity.try :destroy
      card.destroy
    end

    new_vip_card = clone_record(from_user.vip_card)
    new_activity = clone_record(from_user.vip_card.activity, force: true, vip_card: new_vip_card)

    clone_activity_associations(from_user.vip_card.activity, new_activity)

    from_user.vip_card.vip_privileges.each do |privilege|
      clone_record(privilege, vip_card_id: new_vip_card.id)
    end
  end

  def clone_shops
    from_shop = from_user.wx_mp_user.shop
    return if from_shop.blank? || cloned?(from_shop)
    Shop.where(supplier_id: user.id).map &:destroy

    new_shop = clone_record(from_shop)

    Activity.where(supplier_id: user.id, activityable_type: 'Shop').each do |activity|
      activity.update_attributes(activityable_id: new_shop.id)
    end

    # new_shop.activities.map &:destroy
    # from_shop.activities.each do |activity|
    #   new_activity = clone_record(activity, activityable_id: new_shop.id)
    #   destroy_activity_associations(new_activity)
    #   clone_activity_associations(activity, new_activity)
    # end

    from_shop.shop_branches.each do |branch|
      new_branch = clone_record(branch, shop_id: new_shop.id)
      branch.shop_categories.each { |category|
        new_category = clone_record(category, shop_id: new_shop.id, shop_branch_id: new_branch.id)
        clone_associations(category, :shop_products, shop_id: new_shop.id, shop_branch_id: new_branch.id, shop_category_id: new_category.id)
      }
      clone_associations(branch, :shop_images,         shop_id: new_shop.id, shop_branch_id: new_branch.id)
      clone_associations(branch, :shop_table_settings, shop_id: new_shop.id, shop_branch_id: new_branch.id)
    end
  end

  def clone_activity_forms
    from_user.activities.show.where(activity_type_id: 10).each { |activity|
      new_activity = cloned?(activity) ? Activity.find(cloned_id(activity)) : clone_record(activity)
      clone_activity_associations(activity, new_activity)
      clone_associations(activity, :activity_forms, activity_id: new_activity.id)
    }
  end

  def clone_votes
    return puts "votes existed" if user.activities.show.where(activity_type_id: 12).exists?
    from_user.activities.show.where(activity_type_id: 12).each { |activity|
      new_activity = clone_record(activity) || Activity.find(cloned_id(activity))
      clone_associations(activity, :activity_vote_items, activity_id: new_activity.id)
    }
  end

  def clone_surveys
    return puts "surveys existed" if user.activities.show.where(activity_type_id: 15).exists?
    from_user.activities.show.where(activity_type_id: 15).each { |activity|
      new_activity = clone_record(activity) || Activity.find(cloned_id(activity))
      activity.survey_questions.each do |question|
        new_question = clone_record(question, activity_id: new_activity.id)
        clone_associations(question, :survey_answers, activity_id: new_activity.id, survey_question_id: new_question.id)
      end
    }
  end

  def clone_groups
    return puts "groups existed" if user.activities.show.where(activity_type_id: 14).exists?
    from_user.activities.show.where(activity_type_id: 14).each { |activity|
      clone_record(activity)
    }
  end

  def clone_albums
    return puts "albums existed" if user.album_activity
    new_activity = clone_record(from_user.album_activity)
    from_user.albums.each { |album|
      new_album = clone_record(album, activity_id: new_activity.id)
      clone_associations(album, :photos, album_id: new_album.id)
    }
  end






  def clone_weddings
    return if user.weddings.exists?
    from_user.weddings.each do |from_wedding|
      new_wedding = clone_record(from_wedding)
      clone_record(from_wedding.activity, activityable: new_wedding)

      clone_associations(from_wedding, :pictures, wedding_id: new_wedding.id)
      clone_associations(from_wedding, :seats, wedding_id: new_wedding.id)
    end
  end

  def clone_college
    return unless (from_college = from_user.college)
    user.college.try :destroy
    new_college = clone_record(from_college)
    clone_record(from_college.activity, activityable: new_college)
    [:majors, :teachers, :photos, :branches].each { |associations_name|
      clone_associations(from_college, associations_name, college_id: new_college.id)
    }
  end

  def clone_car_shop
    return unless (from_car_shop = from_user.car_shop)
    user.car_shop.try :destroy
    new_car_shop = clone_record(from_car_shop)
    clone_associations(from_car_shop, :car_articles, car_shop_id: new_car_shop.id)
    clone_associations(from_car_shop, :car_sellers,  car_shop_id: new_car_shop.id)
    from_car_shop.car_brands.each { |brand|
      new_brand = clone_record(brand, car_shop_id: new_car_shop.id)
      brand.car_catenas.each do |catena|
        new_catena = clone_record(catena, car_shop_id: new_car_shop.id, car_brand_id: new_brand.id)
        clone_associations(catena, :car_pictures, car_shop_id: new_car_shop.id, car_catena_id: new_catena.id)
        clone_associations(catena, :car_types,    car_shop_id: new_car_shop.id, car_catena_id: new_catena.id, car_brand_id: new_brand.id)
      end
    }
    from_car_shop.car_activity_notices.each { |notice|
      new_activity = clone_record(notice.activity)
      clone_record(notice, car_shop_id: new_car_shop.id, activity: new_activity)
    }
  end

  def clone_hotel
    return unless (from_hotel = from_user.hotel)
    user.hotel.try :destroy
    new_activity = clone_record(from_hotel.activity)
    new_hotel    = clone_record(from_hotel, activity: new_activity)
    from_hotel.hotel_branches.each { |branch|
      new_branch = clone_record(branch, hotel_id: new_hotel.id)
      clone_associations(branch, :hotel_pictures, hotel_id: new_hotel.id, hotel_branch_id: new_branch.id)
      branch.hotel_room_types.each do |room_type|
        new_type = clone_record(room_type, hotel_id: new_hotel.id, hotel_branch_id: new_branch.id, has_defaults: true)
        clone_associations(room_type, :hotel_room_settings, hotel_id: new_hotel.id, hotel_branch_id: new_branch.id, hotel_room_type_id: new_type.id)
      end
    }
  end

  def clone_house
    return unless (from_house = from_user.house)
    user.house.try :destroy
    new_activity = clone_record(from_house.activity)
    new_house    = clone_record(from_house, activity: new_activity)
    clone_record(from_house.house_property, house_id: new_house.id)
    destroy_activity_associations(new_activity)
    clone_activity_associations(from_house.activity, new_activity)
    clone_associations(from_house, :house_experts, house_id: new_house.id)
    clone_associations(from_house, :house_pictures, house_id: new_house.id)
    from_house.house_layouts.each { |layout|
      clone_record(layout, house_id: new_house.id, house_picture_id: cloned_id(layout.house_picture))
    }
  end






  def clone_associations(record, associations_name, options = {})
    record.__send__(associations_name).each do |association|
      clone_record(association, options)
    end
  end

  def cloned?(record)
    cloned[record.class.name].key?(record.id)
  end

  def destroy_cloned
    cloned.each do |class_name, hash|
      class_name.constantize.where(id: hash.values).map &:destroy
    end
  end

  def cloned_id(record)
    return unless record.is_a?(ActiveRecord::Base) && record.persisted?
    cloned[record.class.name][record.id]
  end

  def copy_record(src, dest, options = {})
    return unless src && dest
    attrs = src.attributes.merge(default_record_attrs(src)).merge(options)
    attrs.delete 'id'
    clone_file_columns(src, dest)
    dest.attributes = attrs
    dest.save
  rescue => e
    puts "in method: #{__method__}"
    puts e.message
    puts e.backtrace
  end

  def destroy_activity_associations(activity)
    activity.activity_notices.each do |notice|
      notice.destroy
      cloned["ActivityNotice"].delete_if { |k, v| v == notice.id}
    end if activity
  end




  def user
    @user && Account.find(@user.id)
  end

  def wx_mp_user
    @wx_mp_user && WxMpUser.find(@wx_mp_user.id)
  end

  %w(init_activity_by_coupon init_activity_by_fans_game create_assistants_sites clone_materials clone_marketing_activities clone_website clone_vip_card clone_shops clone_activity_forms clone_votes
    clone_surveys clone_groups clone_albums clone_replies clone_weddings clone_college clone_car_shop clone_hotel clone_house).each do |method_name|
    define_method "#{method_name}_with_puts" do
      puts "*********************************doing #{method_name}"
      __send__ "#{method_name}_without_puts"
    end
    alias_method_chain method_name, :puts
  end

  private
  def clone_record(record, options = {})
    return false unless record
    force = options.delete(:force)
    attrs = options.merge(default_record_attrs(record))
    new_record = record.class.new record.attributes.merge(attrs)
    do_clone(record, new_record, force)
  end

  def default_record_attrs(record)
    attrs = {"id" => nil}
    attrs["supplier_id"]   = user.id       if record.respond_to?(:supplier_id)
    attrs["wx_mp_user_id"] = wx_mp_user.id if record.respond_to?(:wx_mp_user_id)
    attrs
  end

  def do_clone(record, new_record, force = false)
    return false if !force && cloned?(record)
    clone_file_columns(record, new_record)
    new_record.save(validate: false)
    add_to_cloned(record, new_record) if new_record.persisted?
    new_record if new_record.persisted?
  end

  def clone_file_columns(src, dest)
    src.attributes.each do |attr_name, _value|
      next if _value.blank?
      attr_value = src.__send__(attr_name)
      if dest && attr_value.is_a?(CarrierWave::Uploader::Base)
        file = attr_value.file
        file = File.open("#{Rails.root}/app/assets/images/bg_fm.jpg") unless file && file.exists?
        dest.__send__("#{attr_name}=", file)
      end
    end
  end

  def add_to_cloned(record, new_record)
    cloned[record.class.name][record.id] = new_record.id
  end

end
