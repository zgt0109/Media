class Pro::CollegeEnrollsController < Pro::CollegesBaseController
	
	def index
    @search = @college.enrolls.search(params[:search])
		@enrolls = @search.page(params[:page]).order('id DESC')
	end

	def destroy
		@enroll = @college.enrolls.find params[:id]
		@enroll.destroy
		redirect_to college_college_enrolls_path(@college), notice: "删除成功"
	end

end