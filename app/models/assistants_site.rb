class AssistantsSite < ActiveRecord::Base
  belongs_to :assistant
  belongs_to :site
end
