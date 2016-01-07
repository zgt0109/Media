class TripTicketCategory < ActiveRecord::Base
  belongs_to :supplier
  has_many :trip_tickets, dependent: :nullify
  belongs_to :parent, class_name: 'TripTicketCategory', counter_cache: 'children_count'
  has_many :children, class_name: 'TripTicketCategory', foreign_key: 'parent_id'

  acts_as_list scope: :parent_id

  acts_as_tree order: "position", foreign_key: :parent_id, counter_cache: false

  scope :root, -> { where(parent_id: 0) }
  scope :unroot, -> { where("parent_id > 0") }

  validates :name, presence: true

  
  def has_children?
    children_count > 0
  end

  def parent?
    parent_id.to_i.zero?
  end

  def series(n = 1)
    if parent
      parent.series(n + 1)
    else
      return n
    end
  end

  def to_s
    self_and_ancestors.map(&:name).reverse.join("/")
  end
end