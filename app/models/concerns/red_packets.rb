module Concerns::RedPackets
  extend ActiveSupport::Concern

  included do
    has_many :red_packet_activities, class_name: 'Activity', conditions: { activity_type_id: ActivityType::RED_PACKET }
    has_many :red_packet_releases, class_name: '::RedPacket::Release', through: :red_packet_activities
    has_many :red_packet_consumes, class_name: '::Consume', through: :red_packet_releases, source: :consume
  end

  def red_packet_setting
    red_packet_activities.try(:first)
  end
end
