class Wx::UserGroupsController < ApplicationController
  PAGE_SIZE = 24

  before_filter :require_wx_mp_user
  before_filter :fetch_groups, only: :index

  before_filter do
    @partialLeftNav = "/layouts/partialLeftWeixin"
    @groups = @wx_mp_user.wx_user_groups
    @users = @wx_mp_user.wx_users.page(params[:page]).per(PAGE_SIZE)
  end

  def index
    @groups = @wx_mp_user.wx_user_groups
    @users = @wx_mp_user.wx_users.page(params[:page]).per(PAGE_SIZE)
  end

  def update
    if params[:id].to_i > 2
      @wx_mp_user.change_group_name ({:id=>params[:id],:name=>params[:name]})
      @group = WxUserGroup.find_by_groupid(params[:id])
      @group.update_attributes(:name => params[:name])
    end
  end

  def destroy
    @users = @wx_mp_user.wx_users
    @wx_mp_user.delete_wx_group(params[:id])
    @group =WxUserGroup.find_by_groupid(params[:id])
    @wx_mp_user.wx_users.where(groupid:params[:id]).each do |u|
      u.update_attributes(:groupid => 0)
    end
    @unname_group = WxUserGroup.find_by_groupid(0)
    @unname_group.update_attributes(:count=>@unname_group.count+@group.count)
    @group.destroy
  end

  def choose
    if params[:id]=="-1"
      @users = @wx_mp_user.wx_users.page(params[:page]).per(PAGE_SIZE)
    else
      @users = @wx_mp_user.wx_users.where(groupid: params[:id]).page(params[:page]).per(PAGE_SIZE)
    end
  end

  def add_to_group
    @users = WxUser.find_all_by_id(params[:ids])
    length  = params[:ids].length

    origin_id = params[:origin_group]=="-1"  ? 0 : params[:origin_group]
    if origin_id !=params[:group]
      origin_group = WxUserGroup.find_by_groupid(origin_id)
      to_group     = WxUserGroup.find_by_groupid(params[:group])
      origin_group.update_attributes(count:origin_group.count-length.to_i)
      to_group.update_attributes(count: to_group.count+length.to_i)
      @users.each do |u|
        @wx_mp_user.move_wx_user({:openid=>u.openid,:to_groupid=>params[:group]})
        u.update_attributes(groupid: params[:group])
      end
    end
    @users = @wx_mp_user.wx_users.where(groupid: origin_id).page(params[:page]).per(PAGE_SIZE)
  end

  def create
    group = @wx_mp_user.create_user_group(params[:name])["group"]
    groupid = group["id"]
    name = group["name"]
    wx_user_group = WxUserGroup.create(wx_mp_user_id: @wx_mp_user.id,groupid:groupid,name:name)
    wx_user_group.save
    @group = wx_user_group
  end

  def show
    @user = @wx_mp_user.wx_users.find_by_id(params[:id])

    render layout: 'application_pop'
  end

  def search_user
    if params[:group]!= "-1"
      @users = @wx_mp_user.wx_users.where(groupid:params[:group]).where('nickname like ?',params[:name]).page(params[:page]).per(PAGE_SIZE)
    else
      @users = @wx_mp_user.wx_users.where('nickname like ?',params[:name]).page(params[:page]).per(PAGE_SIZE)
    end
  end

  private

  def fetch_groups
    @wx_mp_user.wx_user_group_list.each do |group_attr|
      attrs = group_attr.merge{ 'wx_mp_user_id' => @wx_mp_user.id }
      @wx_mp_user.wx_user_groups.where(groupid: group_attr[:id]).first_or_create(attrs)
    end
  end

end
