# -*- encoding : utf-8 -*-
namespace :activity_setting do

  desc 'initialize vote activity'
  task :initialize_vote_activity => :environment do

    puts 'Starting initialize vote activity'
    Activity.vote.show.find_each do |activity|
      next if activity.activity_setting
      user_type = activity.require_wx_user ? ActivitySetting::ALL_USER : ActivitySetting::WX_USER
      activity_setting = activity.create_activity_setting(user_type: 1)
      puts "activity id: #{activity.id}, activity_setting id: #{activity_setting.id}"
    end
    puts 'Done!'
  end

  desc 'initialize surveys activity'
  task :initialize_surveys_activity => :environment do

    puts 'Starting initialize surveys activity'
    Activity.surveys.show.find_each do |activity|
      next if activity.activity_setting
      activity_setting = activity.create_activity_setting
      puts "activity id: #{activity.id}, activity_setting id: #{activity_setting.id}"
    end
    puts 'Done!'
  end

end

namespace :survey_answer do

  desc 'migration answer options data'
  task :migration_answer_options_data => :environment do

    puts 'Starting migration answer options data'
    SurveyAnswer.where("survey_question_choice_id is null and answer <> '其他'").find_each do |asa|
      asq = asa.survey_question
      next unless asq
      sqc = asq.survey_question_choices.order(:position).limit(asa.answer.to_i).last
      asa.update_column('survey_question_choice_id', sqc.id) if sqc
      puts "activity survey answer id: #{asa.id}"
    end
    puts 'Done!'
  end

end

namespace :survey_question do

  desc 'migration answer options data'
  task :migration_answer_options_data => :environment do

    puts 'Starting migration answer options data'
    SurveyQuestion.where("answer_a is not null and answer_b is not null").find_each do |asq|
      sqc = asq.survey_question_choices.where(position: -2).first
      next if sqc
      asq.survey_question_choices << asq.survey_question_choices.new(name: asq.answer_a, position: -2)
      asq.survey_question_choices << asq.survey_question_choices.new(name: asq.answer_b, position: -1)
      puts "activity survey question id: #{asq.id}"
    end
    puts 'Done!'
  end

  desc 'sort activity survey questions data'
  task :sort_survey_questions_data => :environment do

    puts 'Starting sort activity survey questions data'
    Activity.surveys.show.find_each do |activity|
      survey_questions = activity.survey_questions.order('created_at')
      next unless survey_questions.where(position: 0).first
      survey_questions.each_with_index do |asq, index|
        asq.update_column('position', index + 1)
        puts "activity survey question id: #{asq.id}"
      end
      puts "activity id: #{activity.id}"
    end
    puts 'Done!'
  end

end

namespace :survey do
  desc '部署 staging 需要迁移，调研已提交的 activity_user 的 status 改为 survey_finish'
  task :change_activity_user_status_to_survey_finish => :environment do
    Activity.surveys.find_each do |survey|
      # 老版本调研，答完所有题目才提交，因此只要用户有答题记录代表用户已提交
      survey.activity_users.normal.find_each do |user|
        user.survey_finish! if user.survey_answers.present?
      end
      puts "activity #{survey.id} done!"
    end
  end
end