class WebsiteArticleCategory < ActiveRecord::Base

  belongs_to :website
  belongs_to :parent, class_name: 'WebsiteArticleCategory', counter_cache: 'children_count'
  has_many :children, class_name: 'WebsiteArticleCategory', foreign_key: 'parent_id'
  has_many :website_articles, dependent: :nullify
  has_many :taggings, as: :taggable
  has_many :tags, through: :taggings, dependent: :destroy

  belongs_to :copy, class_name: 'WebsiteArticleCategory', foreign_key: 'copy_id', counter_cache: 'copy_count'
  has_many :copys, class_name: 'WebsiteArticleCategory', foreign_key: 'copy_id'

  acts_as_enum :category_type, in: [
    ['as_article', 1, '文章分类'],
    ['as_product', 2, '展示内容分类']
  ]

  acts_as_list scope: [:parent_id, :category_type]

  acts_as_tree order: "position", foreign_key: :parent_id, counter_cache: false

  scope :root, -> { where(parent_id: 0) }

  validates :name, presence: true

  def has_children?
    children.count > 0
  end

  def series(n = 1)
    if parent
      parent.series(n + 1)
    else
      return n
    end
  end

  def to_s(join_by = ">")
    self_and_ancestors.map(&:name).reverse.join(join_by)
  end

  def copy_self
    index = copys.collect(&:name).map{|f| f.split("#{name}副本").last }.compact.max.to_i + 1
    new_category = WebsiteArticleCategory.new(website_id: website_id, category_type: category_type, name: "#{name}副本#{index}", parent_id: parent_id, copy_id: id)
    copy_tags(new_category)
    copy_articles(new_category)
    copy_children(new_category)
    new_category.save
  end

  def copy_children(new_category)
    children.order(:position).each do |child|
      new_child = WebsiteArticleCategory.new(website_id: child.website_id, category_type: child.category_type, name: child.name)
      new_category.children << new_child
      child.copy_articles(new_child)
      child.copy_children(new_child)
    end
  end

  def copy_articles(new_category)
    website_articles.each do |article|
      attrs = article.attributes
      attrs.delete("id")
      new_article = WebsiteArticle.new(attrs)
      new_article.content = article.content
      old_tags = root.tags.collect(&:self_and_descendants).flatten
      new_tags = new_category.root.tags.collect(&:self_and_descendants).flatten
      article.taggings.each{|f|
        index = old_tags.collect(&:id).index(f.tag_id)
        new_tags[index].taggings << new_article.taggings.new
      }
      new_category.website_articles << new_article
    end
  end

  def copy_tags(new_category)
    tags.each do |t|
      tag = Tag.new(name: t.name)
      t.children.each{|tc| tag.children << Tag.new(name: tc.name)}
      new_category.tags << tag
    end
  end

  class << self
    def enum_category_type_options(category_type)
      {
      	1 => {
               name: '文章分类',
               call_back_url: '/website_articles?article_type=as_article',
               article_type: 'as_article',
        },
      	2 => {
               name: '展示内容分类',
               call_back_url: '/website_articles?article_type=as_product',
               article_type: 'as_product',
        },
      }[category_type]
    end
  end

end
