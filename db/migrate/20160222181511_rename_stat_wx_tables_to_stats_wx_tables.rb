class RenameStatWxTablesToStatsWxTables < ActiveRecord::Migration
  def change
  	rename_table :stat_wx_articles, :stats_wx_articles
  	rename_table :stat_wx_hour_articles, :stats_wx_hour_articles
  	rename_table :stat_wx_msgs, :stats_wx_msgs
  	rename_table :stat_wx_hour_msgs, :stats_wx_hour_msgs
  	rename_table :stat_wx_users, :stats_wx_users
  end
end
