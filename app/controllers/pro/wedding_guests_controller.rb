class Pro::WeddingGuestsController < Pro::WeddingsBaseController

  def index
    conn = WeddingGuest.get_conditions params
    @wedding_guests = @wedding.guests.where(conn).page(params[:page])
    respond_to do |format|
      #format.html { render layout: 'application_pop' }
      format.html {}
      format.xls do
        @all_guests = @wedding.guests.where(conn)
        filename = "宾客-#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
        options = {
          header_columns: ['姓名', '电话', '出席人数'],
          only: [:username, :phone, :people_count],
          column_width: [25,25,15]
        }
        #send_data(@all_guests.to_xls(options), filename: filename)
        send_data(@all_guests.to_xls(options), type: "text/xls; charset=utf-8; header=present", filename: filename)
      end
    end
  end

  def destroy
    wedding_guest = @wedding.guests.find params[:id]
    wedding_guest.destroy
    render js: "$('#guest-row-#{wedding_guest.id}').remove();"
  end
end
