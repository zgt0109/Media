class AccountLog < ActiveRecord::Base
  belongs_to :user, polymorphic: true

  def self.logging(user, request)
    create(
      user: user,
      ip: request.remote_ip.to_s,
      referer: request.referer.to_s,
      user_agent: request.user_agent.to_s
    ) if user
  end
end