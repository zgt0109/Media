class ActivitiesFansGame < ActiveRecord::Base
	belongs_to :activity
	belongs_to :fans_game

	enum_attr :game_status, :in => [
    ['turn_up', 1, '已开启'],
    ['turn_off', -1, '已关闭']
  ]

  scope :latest, -> { order('fans_game_id DESC') }

	def up_status!
		turn_up? ? update_column("game_status", TURN_OFF) : update_column("game_status", TURN_UP)
	end
end
