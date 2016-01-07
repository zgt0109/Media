class Huodong::GuessReportsController < ApplicationController
  before_filter :set_help_anchor
  def index
    @activity_type_id = ActivityType::GUESS
    @activities = current_user.activities.guess.pluck(:name, :id)
    if params[:activity_id].present?
      @activity = current_user.activities.guess.find(params[:activity_id])
      @guess_activity_questions = @activity.guess_activity_questions.page(params[:page]).per(10)  rescue[]
    else
      @guess_activity_questions = Guess::ActivityQuestion.where(activity_id: @activities).page(params[:page]).per(10)  rescue[]
    end
  end
  private
    def set_help_anchor
      @help_anchor = '#nav_180'
    end
end
