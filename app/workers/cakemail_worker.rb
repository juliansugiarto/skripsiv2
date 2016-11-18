class CakemailWorker

  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(options = {})
    # if want to test on development please uncomment below
    # please turn off before commit, so we do not waste our event quota in kissmetrics
    # return unless (Rails.env.staging? || Rails.env.production?)
    send(options['perform'], options) if respond_to? options['perform']
  end

  def new_subscriber(options)
    body = {'list_id' => CAKEMAIL[options['contact_list']], 'email' => options['email']}

    body.merge!("data[Name]" => options['name']) if options['name'].present?
    body.merge!("data[Phone]" => options['phone']) if options['phone'].present?
    
    Cakemail::Connection.new.init(CAKEMAIL["list"]["subscribe_email"], body)
  end

end