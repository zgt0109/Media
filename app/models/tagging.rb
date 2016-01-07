class Tagging < ActiveRecord::Base
  belongs_to :tag, counter_cache: true
  belongs_to :taggable, polymorphic: true

  acts_as_list scope: [:taggable_type, :taggable_id]


  accepts_nested_attributes_for :taggable

  delegate :name, to: :tag, allow_nil: true

  # after_save :save_parent_tag

  # def save_parent_tag
  # 	if tag.root?
  # 		create(tag_id: tag.parent_id, taggable: taggable)
  # 	end
  # end

end
