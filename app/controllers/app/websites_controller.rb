module App
  class WebsitesController < BaseController

    before_filter :find_website, only: [:show, :map]

    def index
      return render :text => "无效的链接！" unless @website
    end

    def show
      redirect_to mobile_root_url(supplier_id: @website.supplier_id)
    end

    def page
      if params[:popup_menu_id]
        @website_popup_menu = WebsitePopupMenu.find(params[:popup_menu_id])
        @website = @website_popup_menu.website

        return redirect_to mobile_channel_url(supplier_id: @website.supplier_id, website_menu_id: params[:website_menu_id], popup_menu_id: params[:popup_menu_id])
      else
        @website_menu = WebsiteMenu.find(params[:id])
        @website = @website_menu.website
        return redirect_to mobile_channel_url(supplier_id: @website.supplier_id, website_menu_id: params[:id])

        if @website_menu.games?
          games = @website.supplier.assistants.games.enabled
          games.each do |game|
            @website_menu.children.build(:name => game.name, :created_at => Time.now)
          end
        end
      end
      @website_popup_menus =  @website.website_popup_menus.order(:sort)
      @website_pictures = @website.website_pictures
      @website_menus = @website.website_menus.root.order(:sort)

    end

    def map
      # return redirect_to mobile_map_url(supplier_id: @website.supplier_id)

      begin
        params = { address: @website.address, output: 'json', ak: '9c72e3ee80443243eb9d61bebeed1735'}
        result = RestClient.get("http://api.map.baidu.com/geocoder/v2/", params: params)
        data = JSON(result)
        @location = data['result']['location']
      rescue
        @location = {}
      end
      render layout: false
    end

    private

    def find_website
      @website = Website.where(id: params[:id]).first
      # @website = @wx_mp_user.website
      return render text: '页面不存在' unless @website

      @website_popup_menus =  @website.website_popup_menus.order(:sort)
      @website_pictures = @website.website_pictures
      @website_menus = @website.website_menus.root.order(:sort)

      # @website.website_menus.each do |menu|
      #   if menu.games?
      #     games = @website.supplier.assistants.games.enabled
      #     games.each do |game|
      #       menu.children.build(:name = game.name)
      #     end
      #   end
      # end
    end

  end
end
