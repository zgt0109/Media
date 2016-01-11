# -*- coding: utf-8 -*-
class Pro::ShopBranchPrintTemplatesController < Pro::ShopBaseController

  skip_before_filter *ADMIN_FILTERS, :require_wx_mp_user, :require_industry, :authorize_shop_branch_account, only: [:recepit, :config_ec_print, :update, :create]

  def index
    template_type = params[:template_type]
    @shop_branch = ShopBranch.find(params[:shop_branch_id])
    @shop_branch_print_template_1 = @shop_branch.shop_branch_print_templates.where(template_type: 1).first || @shop_branch.shop_branch_print_templates.new(:shop_branch_id => @shop_branch.id, :template_type => 1)    
    @shop_branch_print_template_2 = @shop_branch.shop_branch_print_templates.where(template_type: 2).first || @shop_branch.shop_branch_print_templates.new(:shop_branch_id => @shop_branch.id, :template_type => 2)      
  end

  def create
    @shop_branch_print_template = ShopBranchPrintTemplate.new(params[:shop_branch_print_template])
    if @shop_branch_print_template.shop_branch.blank? && @shop_branch_print_template.template_type == 4
      @shop_branch_print_template.save
      flash[:notice] = "保存成功"
      return redirect_to :back 
    end
    if @shop_branch_print_template.shop_branch.shop_branch_print_templates.where(template_type: @shop_branch_print_template.template_type).count >= 1
      @shop_branch_print_template.shop_branch.shop_branch_print_templates.where(template_type: @shop_branch_print_template.template_type).first.update_attributes params[:shop_branch_print_template]
    else
      @shop_branch_print_template.save
    end
    flash[:notice] = "保存成功"
    render inline: "showTip('success', 'update')"
  end

  def update
    @shop_branch_print_template = ShopBranchPrintTemplate.find(params[:id])
    if @shop_branch_print_template.update_attributes params[:shop_branch_print_template]
      flash[:notice] = "更新成功"
    else
      flash[:notice] = "更新失败"
    end
    return redirect_to :back #redirect_to config_print_shop_branch_print_template_url(@shop_branch_print_template.shop_branch)
  end

  def config_print
    @shop_branch = ShopBranch.find(params[:id])
    @shop_branch.take_out_template
    @shop_branch.book_dinner_template
    template_type = params[:template_type] || 1 
    @template = @shop_branch.shop_branch_print_templates.where(:template_type => template_type).first
    if @template.thermal_printers.count == 0
      1.times do 
        @template.thermal_printers.new
      end 
    end
  end

  def config_ec_print
    @template = ShopBranchPrintTemplate.where(template_type: 4).where(open_id: current_site.wx_mp_user.openid).first
    unless @template
      @template = ShopBranchPrintTemplate.new(template_type: 4, open_id: current_site.wx_mp_user.openid)
    end
    if @template.thermal_printers.count == 0
      1.times do
        @template.thermal_printers.new
      end
    end
  end

  # 和小票打印机交互的 action
  def recepit
    if params[:ps]
      if params[:ps] == "1"
        params[:printer] = "ok"
        params[:paper] =  "ok"
        params[:lastprint] = "null"
      elsif params[:ps] == "2"
        params[:printer] = "ok"
        params[:paper] =  "nok"
        params[:lastprint] = "null"
      elsif params[:ps] == "3"
        params[:printer] = "nok"
        params[:paper] =  "null"
        params[:lastprint] = "null"
      elsif params[:ps] == "4"
        params[:printer] = "ok"
        params[:paper] =  "ok"
        params[:lastprint] = "ok"
      elsif params[:ps] == "5"
        params[:printer] = "ok"
        params[:paper] =  "nok"
        params[:lastprint] = "nok"
      elsif params[:ps] == "6"
        params[:printer] = "nok"
        params[:paper] =  "null"
        params[:lastprint] = "nok"
      end
    end

    if (params[:printer] == "ok" && params[:paper] == "ok") #设备和纸张都 ok
      print_no = params[:no]
      @print_order = PrintOrder.where(address: print_no).where(status: -1).first
      if @print_order
        if params[:lastprint] == "null" #&& print_order.stauts == -1 #开始打印
          if @print_order.content.blank?
            str = get_print_text @print_order
          else #电商小票
            str = @print_order.content
          end
          response.headers['Cache-Control'] = 'no-cache'
          remove_keys = %w(X-Powered-By X-Rack-Cache X-Request-Id X-Runtime X-UA-Compatible)
          response.headers.delete_if{|key| remove_keys.include? key}
          return render layout: false, text: "#{str.encode("gb2312", :invalid => :replace, :undef => :replace, :replace => '口')}"
        elsif params[:lastprint] == "ok" 
          @print_order.update_column("status", 1)
          response.headers['Cache-Control'] = 'no-cache'
          response.headers['Content-Length'] = '0'
          render json: ''
        end
      else 
        response.headers['Cache-Control'] = 'no-cache'
        response.headers['Content-Length'] = '0'
        render json: ''
      end
    else 
      response.headers['Cache-Control'] = 'no-cache'
      response.headers['Content-Length'] = '0'
      render json: ''
    end
  end

  def printlog
    address = params[:address]
    @print_orders = PrintOrder.where(address: address).basic_columns.includes(:shop_order).order('id DESC')
  end

  def export_print_data
    respond_to do |format|
      format.xls {
        send_data(PrintOrder.export_excel(current_user.id),
        :type => "text/excel;charset=utf-8; header=present", 
        :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/,'_') + rand(99999).to_s + ".xls")
      }
    end
  end
 
  private

  def get_print_text print_order
    shop_order = print_order.shop_order
    if shop_order.book_dinner?
      difference_string_1, difference_string_2 = "订餐时间：", "#{shop_order.book_at.to_s}" if shop_order.in_normal?
      difference_string_1, difference_string_2 = "排队号：",   "#{shop_order.queue_no}" if shop_order.in_queue?
      difference_string_1, difference_string_2 = "座位号：",   "#{shop_order.desk_no}" if shop_order.in_branch?
    end

    if shop_order.take_out?
      difference_string  = "送餐时间：    #{shop_order.book_at.to_s}\n"    
      difference_string += "外卖地址：    #{shop_order.address.to_s}"    
    end

    text = PrintDsl.new do   
      newline do
        text_left "\x1C\x21\x7C\x1B\x21\x30\x1B\x61\x31 #{print_order.shop_branch_print_template.title} \x1B\x64\x01\x1B\x40", '0'
      end

      newline do 
        text_left "", '0'
      end

      newline do                                                                                                                                                                                   
        text_left "订单编号：", '0'                                                                                                                                                                            
        text_left "#{shop_order.order_no}", '168'                                                                                                                                                                         
      end                                                                                                                                                                                          

      shijiacai = ""
      shijiacai = " #{shop_order.current_price_number}道时价菜" if shop_order.current_price_number > 0

      newline do                                                                                                                                                                                   
        text_left "支付方式：", '0'                                                                                                                                                                             
        text_left "#{shop_order.pay_type_name}#{shijiacai}", '168'                                                                                                                                                                          
      end  

      newline do                                                                                                                                                                                   
        text_left "门店：", '0'                                                                                                                                                                             
        text_left "#{shop_order.shop_branch.name}", '168'                                                                                                                                                                          
      end  

      newline do                                                                                                                                                                                   
        text_left "姓名：", '0'                                                                                                                                                                             
        text_left "#{shop_order.username}", '168'                                                                                                                                                                          
      end  

      newline do                                                                                                                                                                                   
        text_left "手机：", '0'                                                                                                                                                                             
        text_left "#{shop_order.mobile} ", '168'                                                                                                                                                                          
      end  

      newline do                                                                                                                                                                                   
        text_left "下单时间：", '0'                                                                                                                                                                             
        text_left "#{shop_order.created_at.to_s}", '168'                                                                                                                                                                          
      end  

      if shop_order.book_dinner?
        newline do                                                                                                                                                                                   
          text_left "#{difference_string_1}", '0'  
          text_left "#{difference_string_2}", '168'                                                                                                                                                                                      
        end  
      end

      if shop_order.take_out?
        newline do
          text_left "#{difference_string}", '0'
        end
      end

      newline do                                                                                                                                                                                   
        text_left "备注：", '0'                                                                                                                                                                             
        text_left "#{shop_order.description}", '168'                                                                                                                                                                          
      end  

      newline do 
        text_left "--------------------------------", '0'
      end

      newline do
        text_left "名称", '0'   
        text_left "数量", '204'   
        text_right "小计", '384'   
      end

      newline do 
        text_left "--------------------------------", '0'
      end

      shop_order.shop_order_items.each do |item|
        if item.product_name.length > 8
          newline do 
            text_left "#{item.product_name[0..7]}", '0'
            text_left "#{item.qty}", '216'
            text_right "#{item.show_price}", '384'
          end
          newline do 
            text_left "#{item.product_name[7..-1]}", '0'           
          end
        else
          newline do 
            text_left "#{item.product_name}", '0'
            text_left "#{item.qty}", '216'
            text_right "#{item.show_price}", '384'
          end
        end
      end

      newline do 
        text_left "--------------------------------", '0'
      end

      newline do 
        text_left "小计：", '0'
        text_left "#{shop_order.total_qty}", '216'   
        text_right "#{shop_order.print_total_print}", '384'   
      end

      unless shop_order.finish? && !shop_order.cashpay?
        newline do 
          text_left "已付：", '0'
          text_right "0", '384'   
        end

        newline do 
          text_left "待付：", '0'
          text_right "#{shop_order.print_total_print}", '384'   
        end
      else
        newline do 
          text_left "已付：", '0'
          text_right "#{shop_order.print_total_print}", '384'   
        end

        newline do 
          text_left "待付：", '0'
          text_right "0", '384'   
        end
      end

      newline do 
        text_left "--------------------------------", '0'
      end

      newline do 
        text_left "#{shop_order.shop_branch.get_templates(shop_order).try(:description) }", '0'
      end

      newline do 
        text_left "--------------------------------", '0'
      end

      if print_order.shop_branch_print_template.is_print_kitchen
        newline do 
          text_left "", '0'
        end

        newline do 
          text_left "", '0'
        end

        newline do 
          text_left "", '0'
        end

        if shop_order.book_dinner?
          newline do                                                                                                                                                                                   
            text_left "#{difference_string_1}", '0'  
            text_left "#{difference_string_2}", '168'                                                                                                                                                                                      
          end  
        end

        if shop_order.take_out?
          newline do
            text_left "送餐时间：    #{shop_order.book_at.to_s}", '0'
          end
        end

        newline do 
          text_left "", '0'
        end

        newline do
          text_left "品名", '32'
          text_left "数量", '272'
        end

        shop_order.shop_order_items.each do |item|
          if item.product_name.length > 8
            newline do 
              text_left "#{item.product_name[0..7]}", '32'
              text_left "#{item.qty}", '272'
            end
            newline do 
              text_left "#{item.product_name[7..-1]}", '32'      
            end
          else
            newline do 
              text_left "#{item.product_name}", '32'
              text_left "#{item.qty}", '272'
            end
          end
        end
      end
     
    end

    text.result
  end

end

