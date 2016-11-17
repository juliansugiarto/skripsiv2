# Filter for backoffice
module Bold
  class TransactionFilter

    def self.build
      new()
    end

    #                                                                   Class Method
    # ==============================================================================
    class << self

      def search(arg)
        transactions = Transaction.where(build.initial_query(arg)).desc(:updated_at)
        # Run more filters
        return build.filter(arg, transactions)
      end

    end


    #                                                                Instance Method
    # ==============================================================================
    # All additional/complex filter goes here
    def filter(arg, transactions)
      total_transactions = 0
      begin

        if arg[:purpose].present?
          case arg[:purpose]
          when "payment_history"
            payout_code = TransactionCode.find_by(cname: 'payout')
            transactions = Transaction.where(:transaction_code.in => [payout_code]).desc(:updated_at)
          else
          end
        end

        total_transactions = transactions.count

        if transactions.kind_of?(Array)
          transactions = Kaminari.paginate_array(transactions).page(arg[:page]).per(arg[:per])
        else
          transactions = transactions.page(arg[:page]).per(arg[:per])
        end

      rescue
        transactions = []
        total_transactions = 0
      end

      return transactions, total_transactions
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
