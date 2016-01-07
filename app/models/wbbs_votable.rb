class WbbsVotable < ActiveRecord::Base
  belongs_to :voter,   polymorphic: true
  belongs_to :votable, polymorphic: true

  enum_attr :vote_type, :in => [
    ['up',     1, '顶'],
    ['down',   2, '踩'],
    ['report', 3, '举报']
  ]
end
