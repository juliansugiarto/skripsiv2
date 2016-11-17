# Filter for front
module Italic
  class MemberFilter

    def self.build
      new()
    end

    #                                                                   Class Method
    # ==============================================================================
    class << self

      def search(arg)
        members = Member.where(build.initial_query(arg)).desc(:updated_at)
        # Run more filters
        return build.filter(arg, members)
      end

    end


    #                                                                Instance Method
    # ==============================================================================
    # All additional/complex filter goes here
    def filter(arg, members)
      begin
      rescue
        members = []
      end

      return members
    end

    # Boost query, anything can filter first goes here
    def initial_query(arg)
      query = Hash.new
      return query
    end
  end
end
