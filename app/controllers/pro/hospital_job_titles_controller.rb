class Pro::HospitalJobTitlesController < Pro::HospitalBaseController
  
  def create
    @hospital_job_title = HospitalJobTitle.new(params[:hospital_job_title])
    respond_to do |format|
      format.js   
    end
  end

  def destroy
    @hospital_job_title = HospitalJobTitle.find(params[:id])
    @hospital_job_title.delete!
    respond_to do |format|
      format.js   
    end
  end
  
end
