# Filter for front
module Italic
  class InvoiceFilter

    def self.build
      new()
    end

    #                                                                   Class Method
    # ==============================================================================
    class << self

      def search(arg)

        invoices = Invoice.where(owner: arg[:owner])
        invoices = invoices.where(build.initial_query(arg)).desc(:updated_at)
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
      query[:status_id] = arg[:status_id] if arg[:status_id].present?
      return query
    end
  end
end
