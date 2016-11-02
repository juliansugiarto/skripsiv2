class DashboardController < ApplicationController
	before_action :authenticate_user!
	def show
		@ch = Member.where(member_type_id: "4fac049959aa92040e000418")
		@designer = Member.where(member_type_id: "4fac049959aa92040e000419")
		@contest = Contest.all
		@agreement = Agreement.all
		@invoices = Invoice.all
		
		date_from = "2016-10-01"
    date_to = "2016-10-31"

		@ch_this_month = @ch.where(:created_at => date_from..date_to)
		@designers_this_month = @designer.where(:created_at => date_from..date_to)
		@contests_this_month = @contest.where(:created_at => date_from..date_to)
	end
end
