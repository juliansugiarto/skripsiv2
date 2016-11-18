class Indexer::FreelancerMember
  include Sidekiq::Worker
  sidekiq_options retry: false

  Logger = Sidekiq.logger.level == Logger::DEBUG ? Sidekiq.logger : nil
  Client = Elasticsearch::Client.new(host: StaticData.get_elasticsearch_url, logger: Logger)

  def perform(operation, freelancer_member_id)
    logger.debug [operation, "ID: #{freelancer_member_id}"]
    freelancer_member = FreelancerMember.find(freelancer_member_id)
    
    case operation.to_s
      when /index/
        Client.index(index: 'freelancer_members', type: 'freelancer_member', id: freelancer_member.id, body: freelancer_member.as_indexed_json)
      when /destroy/
        Client.delete(index: 'freelancer_members', type: 'freelancer_member', id: freelancer_member.id, body: freelancer_member.as_indexed_json)

      else raise ArgumentError, "FreelancerMember: Unknown operation '#{operation}'"
    end
  end
end
