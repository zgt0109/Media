class PagesController < ApplicationController
  skip_before_filter *ADMIN_FILTERS, :verify_authenticity_token

  TEL_REG   = /\A[0-9\-]{7,16}\z/
  EMAIL_REG = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  layout 'home'

  def newbusiness
    return if request.get?

    contact_info = params[:contact_info].to_s.strip
    return render js: "alert('请填写正确的电话号码或邮箱地址！');" unless valid_contact_info?(contact_info)
    attrs = {name: '商站意向用户', contact: '商站意向用户', tel: contact_info}
    attrs[:email] = contact_info if EMAIL_REG =~ contact_info
    attrs.merge!(status: -1, product_agent_type: 5, apply_type: 2, business_type: 2)
    if SupplierApply.where(attrs).exists?
      render js: "alert('您已经加盟过了！');"
    else
      SupplierApply.new(attrs).save(validate: false)
      render js: "$('#contact_info').val(''); alert('加盟成功！');"
    end
  end

  private

    def valid_contact_info?(contact_info)
      contact_info =~ TEL_REG || contact_info =~ EMAIL_REG
    end
  
end