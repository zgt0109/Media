module App
  class HouseImpressionsController < BaseController
    layout false
    before_filter :find_house

    def index
    end

    def ugc
      @impression = @house.impressions.create \
        content: params[:content]

      is_added = params[:cmd].eql?("add") ? 0 : -1
      sum = 100
      if @house.impressions.where(predefined: true).count == 0
        @house.impressions.create(predefined: true,content: "度假冠军",ratio: "29")
        @house.impressions.create(predefined: true,content: "媲美三亚",ratio: "25")
        @house.impressions.create(predefined: true,content: "港深都会",ratio: "17")
        @house.impressions.create(predefined: true,content: "成熟配套",ratio: "12")
        @house.impressions.create(predefined: true,content: "铂金物管",ratio: "10")
        @house.impressions.create(predefined: true,content: "常住首选",ratio: "6")
      end
      top = @house.impressions.where(predefined: true).order("ratio desc").inject([]){|a,item| a << {content: item.content.to_s, count: item.ratio.to_i, id: item.id} }
      cnt_user = sum - @house.impressions.where(predefined: true).sum(:ratio)
      render json: {msg: "ok",
                    ret: 0,
                    sum: sum,
                    top: top,
                    user: {content: params[:content].to_s,count: cnt_user,id: is_added}
      }, callback: "reviewResult"
    end

    def pro_list
      @pro_list = @house.reviews.where("display_mode < 3").order("display_mode","position").inject([]){|a,review| a << {name: review.author, photo: review.avatar_url, intro: review.author_description, title: review.author_title, reviewTitle: review.title, reviewDesc: review.content}}
      
      render json: @pro_list, callback: "renderProList"
    end

    private
    def find_house
      @activity = Activity.find(session[:activity_id])
      @house = House.find(@activity.supplier.house.id)
      @house_sellers = @house.sellers.normal
    rescue
      render :text => "参数不正确"
    end

  end
end
