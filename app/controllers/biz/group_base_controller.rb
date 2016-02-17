class Biz::GroupBaseController < ApplicationController
  layout 'biz/group'
  before_filter :require_group, :set_seo

  private

  def require_group
    @group = current_site.group
    redirect_to groups_path, notice: "请先设置微团购" unless @group
  end

  def set_seo(titles = nil)
    @current_titles = titles || %w(微团购支付版)
  end
end
