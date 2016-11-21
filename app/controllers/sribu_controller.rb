class SribuController < ApplicationController
	before_action :authenticate_user!
	def less_participate
    #COMPONENT
    @contest = Contest.all

    #DATE
    date_from = "2016-10-01"
    date_to = "2016-11-01"

    #VARIABLE
    @contest_this_month = @contest.where(:created_at => date_from..date_to)
    @contest_less_participate_count = 0
    @contests_open_this_month = @contest_this_month.where(:status => ContestStatus.open)
    @contest_search = @contest_this_month.where(:end_date.nin => [nil])
    
    #Contest LESS PARTICIPATE
    @contest_search.each do |c|
      #duration left
      duration_left = (DateTime.now - c.end_date).to_i
      entries_limit = 20
      duration_limit = 3
      if duration_limit > 0
        if (duration_left <= duration_limit) and (c.entries.count <= entries_limit)
          @contest_less_participate_count += 1
        end
      end
    end

  end

end
