module MemberSearchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    # include Elasticsearch::Model::Callbacks

    mapping do
      indexes :id, index: :not_analyzed
      indexes :username
      indexes :email
      indexes :name
    end

    def as_indexed_json(options = {})
      self.as_json(only: [:id, :username, :email, :name],
        include: {
          member_type: {only: [:id, :name]}
      })
    end

  end
end
