class Pro::WeddingSeatsController < Pro::WeddingsBaseController
  before_filter :find_seat, only: [:show, :update, :destroy]

  def index
    @seats = @wedding.seats.order('id DESC').page(params[:page])
    @seat  = WeddingSeat.new
  end

  def create
    @seat = @wedding.seats.build params[:wedding_seat]
    @seat.guest_names = params[:guest_names]
    if @seat.save
      render js: "showTip('warning','添加桌位成功');location.href='#{wedding_seats_path(@wedding)}'"
    else
      render js: "showTip('warning','#{@seat.full_error_messages}')"
    end
  end

  def show
    render json: { id: @seat.id, name: @seat.name, seats_count: @seat.seats_count, guests: @seat.guest_names }
  end

  def update
    @seat.guest_names = params[:guest_names]
    if @seat.update_attributes(params[:wedding_seat])
      render js: "showTip('warning','更改桌位设置成功');location.href='#{wedding_seats_path(@wedding)}'"
    else
      render js: "showTip('warning','#{@seat.full_error_messages}')"
    end
  end

  def destroy
    @seat.destroy
    render js: "$('#seat-row-#{@seat.id}').remove();"
  end

  private
  def find_seat
    @seat = @wedding.seats.find params[:id]
  end

end