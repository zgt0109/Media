class Pro::HouseCommentsController < ApplicationController
  layout "application_gm"

  def index
  	@house = current_site.house
    return redirect_to houses_path, alert: '请先添加楼盘信息' unless @house

    @total_house_comments = @house.house_comments.where("status > ?", -1).order("created_at desc")
	  @search = @total_house_comments.search(params[:search])
		@house_comments = @search.page(params[:page])

  end

  def show
		@house = current_site.house
    return redirect_to houses_path, alert: '请先添加楼盘信息' unless @house
    @house_comment = @house.house_comments.find(params[:id])
  end

  def new
    @house_comment = HouseComment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @house_comment }
    end
  end

  def edit
    @house_comment = HouseComment.find(params[:id])
  end

  def create
    @house_comment = HouseComment.new(params[:house_comment])

    respond_to do |format|
      if @house_comment.save
        format.html { redirect_to @house_comment, notice: 'House comment was successfully created.' }
        format.json { render json: @house_comment, status: :created, location: @house_comment }
      else
        format.html { render action: "new" }
        format.json { render json: @house_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
  	@house = current_site.house
    return redirect_to houses_path, alert: '请先添加楼盘信息' unless @house
    @house_comment = @house.house_comments.find(params[:id])

    respond_to do |format|
      if @house_comment.update_attributes(params[:house_comment])
        format.html { redirect_to house_comments_url, notice: '回复成功' }
      else
        format.html { redirect_to house_comments_url, notice: '回复失败' }
      end
    end
  end

  def destroy
  	@house = current_site.house
  	if @house
    	@house_comment = @house.house_comments.find(params[:id])
    	@house_comment.destroy
    end

    respond_to do |format|
      format.html { redirect_to house_comments_url }
    end
  end

end
