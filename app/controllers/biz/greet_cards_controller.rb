class Biz::GreetCardsController < ApplicationController
  
  skip_before_filter :verify_authenticity_token, only: [:upload]
  before_filter :find_greet, except: [:help]
  before_filter :check_activity, except: [:help]


  def index
    @cards = @greet.greet_cards.order('id ASC').page(params[:page]).per(17)
    @card  = GreetCard.new
  end

  def create
    @card = @greet.greet_cards.new(params[:greet_card])
    if @card.save
      flash[:notice] = "保存成功"
      redirect_to "/greet_cards"
    end
  end

  def update
    @card = @greet.greet_cards.find params[:id]
    if @card.update_attributes(params[:greet_card])
      flash[:notice] = "更新成功"
      redirect_to "/greet_cards"
    end
  end

  def set_recommand_pic
    greet_id, recommand_pic = params[:greet_id].to_i, params[:recommand_pic]
    greet = greet_id > 0 && Greet.find_by_id(greet_id)
    greet.update_attribute(:recommand_pic, recommand_pic) if greet && recommand_pic.present?
    render :json => greet
  end

  def upload
    @card = @greet.greet_cards.new
    @card.pic = params[:pic]
    @card.save
    @cards = @greet.greet_cards.order('id ASC')
  end

  def view
    @card = @greet.greet_cards.find params[:id]
    @card.view!
  end

  def hidden
    @card = @greet.greet_cards.find params[:id]
    @card.hidden!
  end

  def destroy
    card = @greet.greet_cards.find params[:id]
    card.delete!
    render json: {}
  end

  def new
    @card = @greet.greet_cards.new
    render "edit"
  end

  def edit
    @card = @greet.greet_cards.find(params[:id])    
  end

  def find_greet
    @greet = current_user.greets.first
  end

  def check_activity
    return redirect_to activity_greets_url, notice: '请先填写活动信息' unless current_user.greet_activity
  end

  def help

  end

end
