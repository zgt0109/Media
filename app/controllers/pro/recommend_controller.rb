class Pro::RecommendController < ApplicationController

  def index
    @partialLeftNav = "/layouts/partialLeftSys"
    @wx_mp_user = current_site.wx_mp_user
  end
end
