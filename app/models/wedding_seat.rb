# == Schema Information
#
# Table name: wedding_seats
#
#  id          :integer          not null, primary key
#  wedding_id  :integer          not null
#  name        :string(255)      not null
#  seats_count :integer          default(1), not null
#  people      :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class WeddingSeat < ActiveRecord::Base
  belongs_to :wedding

  validates :name, :seats_count, presence: true


  def self.select_seat params, wedding_id
    name = params[:name]
    if name.present?
      seats = WeddingSeat.where(["people like ? and wedding_id = ?", "%#{name.strip}%", wedding_id]).all
      seats.select do |s|
        s.people.split(';').map(&:strip).include?(name)
      end
    end
  end

  def show_seat name
    self.people.split(';').delete_if{|n|  n == name}.join(' , ')
  end

  def guest_names
    people.split(';')
  end

  def guest_names=(guest_names = [])
    self.people = guest_names.map(&:strip).delete_if{ |n| n.blank? }.join(';')
  end

  def full_error_messages
    errors.map do |attr_name, message|
      i18n_name = "activerecord.attributes.#{self.class.to_s.underscore}.#{attr_name}"
      "#{I18n.t(i18n_name)}#{message}"
    end.join("\n")
  end

end
