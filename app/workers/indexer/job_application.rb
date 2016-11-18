class Indexer::JobApplication
  include Sidekiq::Worker
  # sidekiq_options queue: 'elasticsearch', retry: false
  sidekiq_options retry: false

  Logger = Sidekiq.logger.level == Logger::DEBUG ? Sidekiq.logger : nil
  Client = Elasticsearch::Client.new(host: StaticData.get_elasticsearch_url, logger: Logger)

  def perform(operation, freelancer_member_id)
    logger.debug [operation, "ID: #{freelancer_member_id}"]
    case operation.to_s
      # This operation will update every Job Application, because Freelancer Member update their profile
      # This process used for browse Job Applciant @employer_dashboard
      when /save/
        f = FreelancerMember.find(freelancer_member_id)
        Client.index(index: 'freelancer_members', type: 'freelancer_member', id: f.id, body: f.as_indexed_json)

        opened_job = Rails.cache.fetch("opened_job-#{Date.today}-#{Job.opened_only.count}") do
          Job.opened_only.map(&:id)
        end

        JobApplication.any_in(job: opened_job).where(member: f).each do |ja|
          Client.index(index: 'job_applications', type: 'job_application', id: ja.id, body: ja.as_indexed_json)
        end

      else raise ArgumentError, "JobApplication: Unknown operation '#{operation}'"
    end
  end
end