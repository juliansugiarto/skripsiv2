class DashboardController < ApplicationController
	before_action :authenticate_user!
	def show
		# @ch = Member.where(member_type_id: "4fac049959aa92040e000418")
		# @designer = Member.where(member_type_id: "4fac049959aa92040e000419")
		# @contest = Contest.all
		# @agreement = Agreement.all
		# @invoices = Invoice.all
		
		# date_from = "2016-10-01"
  #   	date_to = "2016-10-31"

		# @ch_this_month = @ch.where(:created_at => date_from..date_to)
		# @designers_this_month = @designer.where(:created_at => date_from..date_to)
		# @contests_this_month = @contest.where(:created_at => date_from..date_to)
	end

  def ajax_data
    @ch = Member.where(member_type_id: "4fac049959aa92040e000418")
    @designer = Member.where(member_type_id: "4fac049959aa92040e000419")
    @contest = Contest.all
    @lead = Lead.all
    # @agreement = Agreement.all
    # @invoices = Invoice.all
    
    date_from = "2016-10-01"
    date_to = "2016-10-31"

    @ch_this_month_count = @ch.where(:created_at => date_from..date_to).count
    @lead_this_month_count = @lead.where(:created_at => date_from..date_to).count
    @designers_this_month_count = @designer.where(:created_at => date_from..date_to).count
    @contests_this_month_count = @contest.where(:created_at => date_from..date_to).count

    data_count, hash_counts = [], {}

    hash_counts = {
      ch_lead: @ch_this_month_count+@lead_this_month_count,
      designer: @designers_this_month_count,
      contest: @contests_this_month_count
    }

    data_count << hash_counts

    
    render status: :ok, json: { :result => data_count}

  end

  def ajax_data_dist
    @ch = Member.where(member_type_id: "4fac049959aa92040e000418")
    @designer = Member.where(member_type_id: "4fac049959aa92040e000419")
    @contest = Contest.all

    date_from = "2016-10-01"
    date_to = "2016-10-31"

    @contests_this_month = @contest.where(:created_at => date_from..date_to)

    @ch_create_contest = @ch.where(:created_at => date_from..date_to).map(&:id)
    @contest_create_count = @contests_this_month.where(:owner.in => @ch_create_contest).count
    @designers_pass_count = @designer.where(:created_at => date_from..date_to, :pass_exams => true).count
    @contest_active_count = @contests_this_month.where(:status => ContestStatus.open).count

    data_count, hash_counts = [], {}
    hash_counts = {
      ch_create: @contest_create_count,
      designer_pass: @designers_pass_count,
      contest_active: @contest_active_count
    }

    data_count << hash_counts


    render status: :ok, json: { :result => data_count}


  end

	def ga
		
	end
end
