# Filter for backoffice
module Bold
  class VoucherFilter

    def self.build
      new()
    end

    #                                                                   Class Method
    # ==============================================================================
    class << self

      def search(arg)
        vouchers = Voucher.where(build.initial_query(arg)).desc(:updated_at)
        # Run more filters
        return build.filter(arg, vouchers)
      end

    end


    #                                                                Instance Method
    # ==============================================================================
    # All additional/complex filter goes here
    def filter(arg, vouchers)
      total_vouchers = 0
      begin
        if arg[:promotion_id].present?
          vouchers = Promotion.find(arg[:promotion_id]).vouchers
        end

        total_vouchers = vouchers.count

        if vouchers.kind_of?(Array)
          vouchers = Kaminari.paginate_array(vouchers).page(arg[:page]).per(arg[:per])
        else
          vouchers = vouchers.page(arg[:page]).per(arg[:per])
        end

      rescue
        vouchers = []
        total_vouchers = 0
      end

      return vouchers, total_vouchers
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
