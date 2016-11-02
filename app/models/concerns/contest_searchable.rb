module ContestSearchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    # include Elasticsearch::Model::Callbacks

    mapping do
      indexes :id, index: :not_analyzed
      indexes :title
    end

    def as_indexed_json(options = {})
      self.as_json(only: [:id, :title],
        include: {
          owner: {only: [:id, :username]},
          category: {only: [:id, :name]},
          package: {only: [:id, :name]},
          status: {only: [:id, :name]}
      })
    end

  end
end
