# non database class to handle contact us form
class ContactUs
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  EMAIL_MAXIMUM_LENGTH = 100
  CONTACT_NUMBER_MAXIMUM_LENGTH = 100
  DESCRIPTION_MINIMUM_LENGTH = 5
  DESCRIPTION_MAXIMUM_LENGTH = 1000
	DESCRIPTION_MAXIMUM_LENGTH_DB = 1200

  # all field needed for contact form
  attr_accessor :email
  attr_accessor :contact_number
  attr_accessor :description

  # all bulk update form validations
  validates :email, :presence => true, 
    :length => { :maximum => EMAIL_MAXIMUM_LENGTH },
    :format => { :with => /\A[^@][\w.-]+@[\w.-]+[.][a-z]{2,4}\z/i}
  
  validates :contact_number, :presence => true,
    :length => { :maximum => CONTACT_NUMBER_MAXIMUM_LENGTH }

  validates :description, :presence => true,
    :length => { :minimum => DESCRIPTION_MINIMUM_LENGTH, :maximum => DESCRIPTION_MAXIMUM_LENGTH_DB }

  # populate value given for contact us
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
end
