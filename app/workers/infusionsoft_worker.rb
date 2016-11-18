class InfusionsoftWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(options = {})
    send(options['perform'], options) if respond_to? options['perform'] and Rails.env.production?
  end

  def buy_smm_package_unpaid(options)
    em = EmployerMember.find options['employer_id']
    Infusionsoft::Tag.new(em).buy_smm_package_unpaid
  end

  def buy_smm_package_paid(options)
    em = EmployerMember.find options['employer_id']
    Infusionsoft::Tag.new(em).buy_smm_package_paid
  end

  def buy_ecomm_package_unpaid(options)
    em = EmployerMember.find options['employer_id']
    Infusionsoft::Tag.new(em).buy_ecomm_package_unpaid
  end

  def buy_ecomm_package_paid(options)
    em = EmployerMember.find options['employer_id']
    Infusionsoft::Tag.new(em).buy_ecomm_package_paid
  end

  def buy_article_package_unpaid(options)
    em = EmployerMember.find options['employer_id']
    Infusionsoft::Tag.new(em).buy_article_package_unpaid
  end

  def buy_article_package_paid(options)
    em = EmployerMember.find options['employer_id']
    Infusionsoft::Tag.new(em).buy_article_package_paid
  end

  def tag_employer(options)
    em = EmployerMember.find options['employer_id']
    Infusionsoft::Tag.new(em).tag_employer
  end
end
