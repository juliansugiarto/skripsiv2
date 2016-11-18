class KissmetricsWorker

  PRODUCTION_API_KEY = '93213a85211a2e607a51fb18d873357234af9683'
  DEVELOPMENT_API_KEY = '7847f76b58266f070aae82c52acbd177e01956dd'
  
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(options = {})
    # if want to test on development please uncomment below
    # please turn off before commit, so we do not waste our event quota in kissmetrics
    return unless Rails.env.production?
    init_kissmetrics
    send(options['perform'], options) if respond_to? options['perform']
  end

  def alias_identity(options)
    KMTS.alias(options['from_identity'], options['to_identity'])
  end

  def new_member(options)
    identity = options['identity']
    KMTS.record(identity, 'View New Member Form', options['properties'])
  end

  def new_employer(options)
    identity = options['identity']
    KMTS.record(identity, 'View New Employer Member Form', options['properties'])
  end

  def new_freelancer(options)
    identity = options['identity']
    KMTS.record(identity, 'View New Freelancer Member Form', options['properties'])
  end

  def employer_signup(options)
    identity = options['identity']
    KMTS.record(identity, 'Client Signup', options['properties'])
  end

  def freelancer_signup(options)
    identity = options['identity']
    KMTS.record(identity, 'Freelancer Signup', options['properties'])
  end

  def service_provider_signup(options)
    identity = options['identity']
    KMTS.record(identity, 'Service Provider Signup', options['properties'])
  end

  def new_job(options)
    identity = options['identity']
    KMTS.record(identity, 'New Job', options['properties'])
  end

  def job_approved(options)
    identity = options['identity']
    KMTS.record(identity, 'Job Approved', options['properties'])
  end

  def job_paid(options)
    identity = options['identity']
    KMTS.record(identity, 'Job Paid', options['properties'])
  end 

  def task_paid(options)
    identity = options['identity']
    KMTS.record(identity, 'Task Paid', options['properties'])
  end

  def new_service(options)
    identity = options['identity']
    KMTS.record(identity, 'New Service', options['properties'])
  end

  def service_approved(options)
    identity = options['identity']
    KMTS.record(identity, 'Service Approved', options['properties'])
  end

  def service_paid(options)
    identity = options['identity']
    KMTS.record(identity, 'Service Paid', options['properties'])
  end

  def job_form(options)
    identity = options['identity']
    KMTS.record(identity, 'View Post Job Form', options['properties'])
  end

  def job_review(options)
    identity = options['identity']
    KMTS.record(identity, 'View Review Posted Job', options['properties'])
  end

  def service_form(options)
    identity = options['identity']
    KMTS.record(identity, 'View Post Service Form', options['properties'])
  end

  def service_review(options)
    identity = options['identity']
    KMTS.record(identity, 'View Review Service', options['properties'])
  end

  def new_recruitment(options)
    identity = options['identity']
    KMTS.record(identity, 'New Recruitment', options['properties'])
  end

  def recruitment_approved(options)
    identity = options['identity']
    KMTS.record(identity, 'Recruitment Approved', options['properties'])
  end

  def lpage_view(options)
    identity = options['identity']
    category_name = options['properties']['cname']
    KMTS.record(identity, "Lpage view #{category_name}", options['properties'])
  end

  def packages_index(options)
    identity = options['identity']
    KMTS.record(identity, 'View Packages Index', options['properties'])
  end

  def package_brief(options)
    identity = options['identity']
    KMTS.record(identity, 'View Package Brief', options['properties'])
  end

  def package_payment(options)
    identity = options['identity']
    KMTS.record(identity, 'View Package Payment', options['properties'])
  end

  private

  def init_kissmetrics
    api_key_to_use = Rails.env.production? ? PRODUCTION_API_KEY : DEVELOPMENT_API_KEY
    KMTS.init(api_key_to_use, :log_dir => File.join('/www_sribulancer/current', 'log', 'km'))
  end

end
