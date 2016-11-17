# Filter for front
module Bold
  class InvoiceFilter

    def self.build
      new()
    end

    #                                                                   Class Method
    # ==============================================================================
    class << self

      def search(arg)
        invoices = Invoice.where(build.initial_query(arg)).desc(:updated_at)
        # Run more filters
        return build.filter(arg, invoices)
      end

    end


    #                                                                Instance Method
    # ==============================================================================
    # All additional/complex filter goes here
    def filter(arg, invoices)
      total_invoices = 0
      begin

        if arg[:status].present?
          invoices = invoices.where(status: InvoiceStatus.find_by(cname: arg[:status]))
        end

        total_invoices = invoices.count

        if invoices.kind_of?(Array)
          invoices = Kaminari.paginate_array(invoices).page(arg[:page]).per(arg[:per])
        else
          invoices = invoices.page(arg[:page]).per(arg[:per])
        end

      rescue
        invoices = []
        total_invoices = 0
      end

      return invoices, total_invoices
    end

    # Boost query, anything can filter first goes here
    def initial_query(arg)
      query = Hash.new
      query[:contest_id] = arg[:contest_id] if arg[:contest_id].present?
      query[:owner_id] = arg[:owner_id] if arg[:owner_id].present?
      return query
    end
    
  end
end
