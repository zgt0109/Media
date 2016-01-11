class AccountFooter < ActiveRecord::Base
  belongs_to :site

  def self.default_footer
    where(is_default: true).first
  end
end
