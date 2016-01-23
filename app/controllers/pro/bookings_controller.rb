class Pro::BookingsController < Pro::BookingBaseController
  skip_before_filter :require_booking, only: [:index]

  before_filter :load_booking

  def create
    if @booking.save
      redirect_to @booking, notice: 'Ec shop was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    if @booking.update_attributes(params[:booking])
      redirect_to :back, notice: '保存成功'
    else
      redirect_to :back, alert: "保存失败：#{@booking.errors.full_messages.join('，')}"
    end
  end

  def destroy
    if @booking.clear_menus!
      redirect_to :back
    else
      redirect_to :back, notice: '操作失败'
    end
  end

  private

  def load_booking
    @booking = current_site.booking
    @booking = current_site.create_booking unless @booking
  end

end
