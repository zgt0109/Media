class Pro::CollegePhotosController < Pro::CollegesBaseController
  def index
    @photos = @college.photos.order('id DESC')
    @photo  = CollegePhoto.new
  end
  
  def create
    @photo = @college.photos.new(params[:college_photo])
    @photo.save
    render :partial => "pro/college_photos/photo", :locals => {photo: @photo}
  end

  def edit
    @photo = @college.photos.where(id: params[:id]).first
    render layout: "application_pop"
  end

  def update
    @photo = @college.photos.where(id: params[:id]).first
    if @photo.update_attributes(params[:college_photo])
      flash[:notice] = '保存成功'
      render inline: "<script>window.parent.document.getElementById('weisiteModal').style.display='none';window.parent.location.reload();</script>"
    else
      message = @photo.error_messages.join("\n")
      flash[:alert] = "保存失败: #{message}"
      render inline: "<script>window.parent.document.getElementById('weisiteModal').style.display='none';window.parent.location.reload();</script>"
    end
  end
  
  def destroy
    photo = @college.photos.where(id: params[:id]).first 
    photo.destroy
    render js: <<-eos 
      $('#delete'+#{photo.id}).closest('.photo-li').slideUp( function() { 
        $(this).remove(); 
      });
    eos
  end
end
