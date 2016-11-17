# Filter for backoffice
module Bold
  class DepositFilter

    def self.build
      new()
    end

    #                                                                   Class Method
    # ==============================================================================
    class << self

      def search(arg)
        deposits = Deposit.where(build.initial_query(arg)).desc(:updated_at)
        # Run more filters
        return build.filter(arg, deposits)
      end

    end


    #                                                                Instance Method
    # ==============================================================================
    # All additional/complex filter goes here
    def filter(arg, deposits)
      total_deposits = 0
      begin

        if arg[:purpose].present?
          case arg[:purpose]
          when "payout"
            requested_status = DepositStatus.find_by(cname: 'requested')
            deposits = WithdrawalDeposit.where(:status.in => [requested_status]).desc(:updated_at)
          when "designer_transaction"
            designer = Member.find(arg[:designer_id])
            deposits = Deposit.where(owner: designer).desc(:created_at)
          end
        end

        total_deposits = deposits.count

        if deposits.kind_of?(Array)
          deposits = Kaminari.paginate_array(deposits).page(arg[:page]).per(arg[:per])
        else
          deposits = deposits.page(arg[:page]).per(arg[:per])
        end

      rescue
        deposits = []
        total_deposits = 0
      end

      return deposits, total_deposits
    end

    # Boost query, anything can filter first goes here
    def initial_query(arg)
      query = Hash.new

      if arg[:from].present? and arg[:to].present?
        from = Time.parse(arg[:from])
        to = Time.parse(arg[:to]).end_of_day
        query[:created_at] = from..to
      end

      return query
    end
  end
end
