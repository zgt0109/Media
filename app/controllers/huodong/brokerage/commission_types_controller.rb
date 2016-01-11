class Huodong::Brokerage::CommissionTypesController < Huodong::Brokerage::BaseController
    before_filter :find_commission_type, only: [ :show, :edit, :update, :edit_status ]

    def index
        @commission_types = current_site.brokerage_commission_types.page(params[:page])
    end

    def show
        render json: {title: @commission_type.commission_type_name, text: @commission_type.commission_value_text, commission_type: @commission_type.commission_type, commission_value: @commission_type.commission_value }
    end

    def edit
        render :form, layout: 'application_pop'
    end

    def update
        if @commission_type.update_attributes(params[:brokerage_commission_type])
            flash[:notice] = "更新成功"
            render inline: "<script>window.parent.location.reload();</script>"
        else
            redirect_to :back, alert: "更新失败，#{@commission_type.errors.full_messages.join('\n')}"
        end
    end

    def edit_status
        if @commission_type.update_attributes(status: @commission_type.enabled? ? -1 : 1)
            redirect_to :back, notice: '操作成功'
        else
            redirect_to :back, alert: "操作失败，#{@commission_type.errors.full_messages.join('\n')}"
        end
    end

    private

        def find_commission_type
            @commission_type = current_site.brokerage_commission_types.find(params[:id])
        end
end
