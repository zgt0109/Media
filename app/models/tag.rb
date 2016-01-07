class Tag < ActiveRecord::Base
  has_many :taggings, dependent: :destroy
  has_many :children, class_name: 'Tag', foreign_key: 'parent_id', dependent: :destroy
  belongs_to :parent, class_name: 'Tag', counter_cache: 'children_count'

  belongs_to :copy, class_name: 'Tag', foreign_key: 'copy_id', counter_cache: 'copy_count'
  has_many :copys, class_name: 'Tag', foreign_key: 'copy_id'

  scope :tag_root, -> {where(parent_id: nil)}
  scope :tag_children, -> {where("parent_id is not null")}

  acts_as_list scope: :parent_id
  
  acts_as_tree order: "position", foreign_key: :parent_id, counter_cache: false

  accepts_nested_attributes_for :taggings, :children, allow_destroy: true 
end
