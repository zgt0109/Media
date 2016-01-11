class Huodong::GuessQuestionsController < FightQuestionsController         #  guess_questions  from  fight_questions
  before_filter :set_help_anchor
  def destroy
    @guess_question = scoped_questions.find(params[:id])
      if @guess_question.delete!
        redirect_to :back, notice: '删除成功'
      else
        redirect_to :back, alert: "删除失败,#{@guess_question.errors.full_messages.join(',')}"
      end
  end

  private
    def set_help_anchor
      @help_anchor = '#nav_180'
    end

    def index_path
      guess_questions_path
    end

    def scoped_questions
      current_site.guess_questions
    end

    def model_name
      :guess_question
    end
end