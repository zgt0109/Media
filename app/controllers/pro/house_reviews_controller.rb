class Pro::HouseReviewsController < Pro::HousesBaseController
  def index
    @reviews = current_site.house.reviews.order("created_at desc").page(params[:page])
  end

  def new
    #@review = HouseReview.new
    @review = current_site.house.reviews.new
  end

  def activity
    @activity = current_site.create_activity_for_house_review
  end

  def update_activity
    @activity = current_site.create_activity_for_house_review
    if @activity.update_attributes(params[:activity])
      #redirect_to activity_house_reviews_path, notice: '保存成功'
      redirect_to house_reviews_path, notice: '保存成功'
    else
      render :activity
    end
  end

  def create
    @review = current_site.house.reviews.build params[:house_review]

    if @review.save
      redirect_to house_reviews_path, notice: "保存成功"
    else
      flash[:alert] = "保存失败"
      #redirect_to house_reviews_path, notice: "保存失败"
      render :new
    end
  end

  def edit
    @review = current_site.house.reviews.find params[:id]
  end

  def update
    @review = current_site.house.reviews.find params[:id]
    if @review.update_attributes(params[:house_review])
      redirect_to house_reviews_path, notice: "更新成功"
    else
      redirect_to house_reviews_path, alert: "更新失败"
    end
  end

  def destroy
    @review = current_site.house.reviews.find params[:id]
    @review.destroy
    redirect_to house_reviews_path, notice: "操作成功"
  end
end
