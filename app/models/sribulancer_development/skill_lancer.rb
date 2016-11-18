# represent skill
class SkillLancer

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'skills'
  include Elasticsearch::Model

  field :name

  validates :name, presence: true, :uniqueness => {:scope => :online_group_category_id}
  validates :online_group_category, presence: true

  belongs_to :online_group_category
  has_and_belongs_to_many :members

  has_many :member_skills

  def as_indexed_json(options={})
    self.as_json(
      only: [:name],
      include: {
        online_group_category: {
          only: [:cname, :name]
        }
      }
    )
  end

  def self.popular_skills
    popular = [ "Article Writing", "Copywriting", 'Blog Writing', 'Creative Writing',
      "Adobe Photoshop", "CorelDRAW", "Logo Design", "Graphic Design", "PHP", "Website Design",
      "HTML", "Website Development", "Microsoft Excel", "MS Word", "E-mail Handling", "Social Media Marketing",
      "Internet Marketing", "Translation Japanese to Indonesian", "Translation Indonesian to Japanese",
      "Mobile Web Development" ]
    SkillLancer.in(name: popular)
  end
end
