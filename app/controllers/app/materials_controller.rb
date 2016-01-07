module App
  class MaterialsController < BaseController
    skip_before_filter :load_data, :auth
  
    before_filter :find_material, only: [:show, :blue]

    def show
      render layout: false
    end

    def blue
      render layout: false
    end
    
    private
    def find_material
      @material = Material.where(id: params[:id]).first
      return render text: '素材不存在' unless @material
      @share_image = @material.pic_url
    end

  end
end