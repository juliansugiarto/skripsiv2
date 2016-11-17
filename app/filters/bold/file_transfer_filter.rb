# Filter for backoffice
module Bold
  class FileTransferFilter

    def self.build
      new()
    end

    #                                                                   Class Method
    # ==============================================================================
    class << self

      def search(arg)
        contest = Contest.find(arg[:contest_id])
        workspaces = ContestWorkspace.where(contest: contest)

        file_transfers = []

        workspaces.each do |w|
          file_transfers = file_transfers + w.events.where(build.initial_query(arg))
        end

        file_transfers = file_transfers.sort_by {|f| f.updated_at}.reverse

        # Run more filters
        return build.filter(arg, file_transfers)
      end

    end


    #                                                                Instance Method
    # ==============================================================================
    # All additional/complex filter goes here
    def filter(arg, file_transfers)
      total_file_transfers = 0
      begin

        total_file_transfers = file_transfers.count

        if file_transfers.kind_of?(Array)
          file_transfers = Kaminari.paginate_array(file_transfers).page(arg[:page]).per(arg[:per])
        else
          file_transfers = file_transfers.page(arg[:page]).per(arg[:per])
        end

      rescue
        file_transfers = []
        total_file_transfers = 0
      end

      return file_transfers, total_file_transfers
    end

    # Boost query, anything can filter first goes here
    def initial_query(arg)
      query = Hash.new

      query[:_type] = 'WorkspaceEventContestFileTransfer'

      if arg[:from].present? and arg[:to].present?
        from = Time.parse(arg[:from])
        to = Time.parse(arg[:to]).end_of_day
        query[:created_at] = from..to
      end

      return query
    end
  end
end
