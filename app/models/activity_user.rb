class ActivityUser < ActiveRecord::Base

  has_many :aid_results, class_name: 'Aid::Result'
  has_many :survey_answers
  has_many :guess_participations, class_name: 'Guess::Participation'
  has_many :red_packet_releases, class_name: 'RedPacket::Release'
  has_many :activity_user_vote_items
  belongs_to :activity
  belongs_to :user
  has_one :activity_feedback

  accepts_nested_attributes_for :guess_participations

  alias feedback activity_feedback

  enum_attr :status, :in => [
    ['normal',    0, '正常'],
    ['survey_pending',  1, '已答完微调研部分题目'],
    ['survey_finish',   2, '已答完微调研所有题目']
  ]

  def wx_user
    user.wx_user
  end

  def vote_options(activity_vote_item_ids)
    return '' unless activity
    # activity_user_vote_items.pluck(:activity_vote_item_id).each_with_object([]) do |vote_item_id, arr|
    vote_item_ids.to_s.split(',').map!(&:to_i).each_with_object([]) do |vote_item_id, arr|
      index = activity_vote_item_ids.index(vote_item_id)
      arr << "投票项#{index+1}" if index
    end.join('、')
  end

  def survey_options
    return '' unless activity
    arr = []
    questions = activity.survey_questions.order(:position)
    answers = survey_answers.order('survey_answers.survey_question_id')
    questions.collect(&:id).each{|m| arr << answers.select{|f| f.survey_question_id == m }.flatten.collect(&:answer).join(',')}
    arr.each_with_index{|m, index| arr[index] = "第#{index+1}题:#{m}"}.join(' | ')
  end

  def can_answer_guess_question?(activity, guess_question)
    activity.xxxx_limit < guess_participations.where(activity_id: activity.id, question: guess_question.id).count
    activity.xxxx_limit < guess_participations.where(guess_activity_question_id: guess_activity_question.id).count
  end

end
