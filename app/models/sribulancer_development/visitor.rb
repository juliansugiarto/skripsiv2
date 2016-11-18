class Visitor

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'visitors'
  field :name
  field :email
  field :phone

  # format of this field
  # (location)_(name)
  # ex: (survey)_(job_new_details)
  field :from

  has_one :survey_answer
  belongs_to :country

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :phone, presence: true

  # "Coming from" for UI purpose
  def coming_from
    if self.from.present?
      temp = self.from.split('_')
      val = '[' + temp[0].humanize + '] ' + temp[1..-1].join('_')
    end
  end
end store_in database: 'sribulancer_development', collection: 'task_brief_settings'
