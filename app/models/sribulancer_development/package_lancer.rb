# represent a package offered by sribulancer
class PackageLancer

  include ActionView::Helpers::NumberHelper

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in database: 'sribulancer_development', collection: 'packages'
  field :price, type: Float, default: 0
  field :cname
  field :group_cname
  field :freelancer_fee, type: Integer, default: 0
  field :recurring, type: Boolean, default: false
  field :voffice_fee, type: Float, default: 0

  SMM = 'social_media'
  ECOMM = 'e_commerce'
  ARTICLE = 'article_writing'

  belongs_to :currency
  belongs_to :online_category

  has_and_belongs_to_many :skills, inverse_of: nil

  before_save :set_skills

  def title
    group = I18n.t("packages.#{self.group_cname}.title")
    type = I18n.t("packages.index.label.#{self.cname}")
    I18n.t("packages.index.label.title_display", package: self.title_short)
  end

  def title_short
    group = I18n.t("packages.#{self.group_cname}.title")
    type = I18n.t("packages.index.label.#{self.cname}")
    "#{group} - #{type}"
  end

  def price_voffice
    self.price + self.voffice_fee
  end

  def is_smm?
    self.group_cname == SMM
  end

  def is_ecomm?
    self.group_cname == ECOMM
  end

  def is_article?
    self.group_cname == ARTICLE
  end

  def set_skills
    self.skills = self.online_category.skills unless self.online_category.blank?
  end
  
end
