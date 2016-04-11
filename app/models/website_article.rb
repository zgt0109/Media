class WebsiteArticle < ActiveRecord::Base

  acts_as_list column: 'sort', scope: [:website_id, :website_menu_id, :website_article_category_id]

  enum_attr :is_recommend, :in => [ ['recommend', true, '是'], ['unrecommend', false, '否'] ]

  acts_as_enum :article_type, in: [
    ['as_default', 1, '默认'],
    ['as_article', 2, '资讯'],
    ['as_product', 3, '产品']
  ]
  acts_as_enum :status, in: [
    ['visible',   1, '显示'],
    ['invisible', 2, '隐藏']
  ]
  acts_as_enum :subtitle_type, in: [
    ['by_updated_at',  1, '更新时间'],
    ['by_created_at',  2, '创建时间'],
    ['hidden',         3, '不显示'],
    ['by_description', 4, '说明']
  ]

  validates :content, :title, presence: true
  validates :sort, presence: true, numericality: { only_integer: true }

  belongs_to :site
  belongs_to :website
  belongs_to :website_menu
  belongs_to :website_article_category

  has_many :website_comments
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :likes, as: :likeable

  belongs_to :copy, class_name: 'WebsiteArticle', foreign_key: 'copy_id', counter_cache: 'copy_count'
  has_many :copys, class_name: 'WebsiteArticle', foreign_key: 'copy_id'

  has_one :website_article_content, dependent: :destroy

  accepts_nested_attributes_for :website_article_content
  accepts_nested_attributes_for :taggings, allow_destroy: true

  scope :latest, -> { order('created_at DESC') }

  delegate :content, to: :website_article_content, allow_nil: true

  def content=(text)
    wac = if new_record?
      build_website_article_content(content: text)
    else
      website_article_content || create_website_article_content(content: text)
    end
    wac.content = text
  end

  def self.categorized(category = nil)
    if category
      joins(:website_article_category).where("website_article_categories.id" => category.self_and_descendants.to_a.map(&:id)).uniq
    else
      includes(:website_article_category)
    end
  end

  def subtitle_content
    case subtitle_type
      when 1
        updated_at.strftime("%Y-%m-%d %H:%M:%S")
      when 2
        created_at.strftime("%Y-%m-%d %H:%M:%S")
      when 3
        nil
      when 4
        subtitle
      else
        nil
    end
  end

  def pic_url
    qiniu_image_url(pic_key)
  end

end
