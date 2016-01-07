# == Schema Information
#
# Table name: dev_logs
#
#  id            :integer          not null, primary key
#  content_type  :integer          default(1), not null
#  admin_user_id :integer
#  title         :string(255)
#  content       :text             default(""), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe DevLog do
  it "is valid with a title content content_type " do
    dev_log = DevLog.new(title:"第一版发布", content:"修复了很多 bug", content_type:1)
    expect(dev_log).to be_valid
  end

  it "is invalid with a nil title" do
    dev_log = DevLog.new(title:nil, content:"修复了很多 bug", content_type:1)
    expect(dev_log).to have(1).errors_on(:title)
  end

  it "is invalid with a nil content" do
    dev_log = DevLog.new(title:"第一版发布", content:nil, content_type:1)
    expect(dev_log).to have(1).errors_on(:content)
  end

  it "is invalid with a nil content_type" do
    dev_log = DevLog.new(title:"第一版发布", content:"修复了很多 bug", content_type:nil)
    expect(dev_log).to have(1).errors_on(:content_type)
  end
end
