class Huodong::GuessActivityQuestionsController < ApplicationController
  before_filter :set_help_anchor
  private
    def set_help_anchor
      @help_anchor = '#nav_180'
    end
end
