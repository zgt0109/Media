class Pro::BookingsController < Pro::BookingBaseController
    skip_before_filter :require_booking, only: [:index]

    before_filter :set_booking


    def index

    end

    def new
    end

    def edit
    end

    def create
      if @booking.save
        redirect_to @booking, notice: 'Ec shop was successfully created.'
      else
        render action: "new"
      end
    end

    # PUT /ec_shops/1
    # PUT /ec_shops/1.json
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

    def set_booking
      @booking = current_site.booking
      @booking = current_site.create_booking unless @booking
    end

end
