class Pro::WeddingWishesController < Pro::WeddingsBaseController

  def index
    conn = WeddingWish.get_conditions params
    @wedding_wishes = @wedding.wishes.where(conn).page(params[:page])
    respond_to do |format|
      #format.html { render layout: 'application_pop' }
      format.html {}
      format.xls do
        @all_wishes = @wedding.wishes.where(conn)
        filename = "宾客-#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
        options = {
          header_columns: ['祝福人姓名', '手机号码', '内容'],
          only: [:username, :mobile, :content],
          column_width: [25,25,55]
        }
        #send_data(@all_guests.to_xls(options), filename: filename)
        send_data(@all_wishes.to_xls(options), type: "text/xls; charset=utf-8; header=present", filename: filename)
      end
    end
  end

  def destroy
    @wedding.wishes.find(params[:id]).destroy
    redirect_to wedding_wishes_path(@wedding), notice: '删除祝福成功'
  end
  
end
