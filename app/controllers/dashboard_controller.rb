class DashboardController < ApplicationController
	before_action :authenticate_user!
	def show
		@ch = Member.where(member_type_id: "4fac049959aa92040e000418")
		@designer = Member.where(member_type_id: "4fac049959aa92040e000419")
		@contest = Contest.all
		@agreement = Agreement.all
		@invoices = Invoice.all
    @lead = Lead.all
		
		date_from = "2016-09-01"
    date_to = "2016-09-30"

		@ch_last_month_count = @ch.where(:created_at => date_from..date_to).count
    @lead_last_month_count = @lead.where(:created_at => date_from..date_to).count
		@designers_last_month_count = @designer.where(:created_at => date_from..date_to).count
		@contests_last_month_count = @contest.where(:created_at => date_from..date_to).count

    @yesterday_ch_lead = @ch_last_month_count + @lead_last_month_count

	end

  def ajax_data
    @ch = Member.where(member_type_id: "4fac049959aa92040e000418")
    @designer = Member.where(member_type_id: "4fac049959aa92040e000419")
    @contest = Contest.all
    @lead = Lead.all
    @followup = TicketFollowUp.all
    # @agreement = Agreement.all
    # @invoices = Invoice.all
    
    date_from = "2016-10-01"
    date_to = "2016-10-31"

    ch_fu_count = 0
    lead_fu_count = 0
    @ticket_register_this_month = Ticket.where(:_type => "RegisterTicket", :created_at => date_from..date_to)
    @ticket_lead_this_month = Ticket.where(:_type => "LeadTicket", :created_at => date_from..date_to)
    @ch_this_month = @ch.where(:created_at => date_from..date_to)
    @lead_this_month = @lead.where(:created_at => date_from..date_to)
    @followup_this_month = @followup.where(:created_at => date_from..date_to)

    @ticket_register_this_month.each do |tr|
      tr.events.each do |tre|
        if tre._type == "TicketFollowUp"
          ch_fu_count+=1
          break
        end
      end
    end

    @ticket_lead_this_month.each do |tr|
      tr.events.each do |tre|
        if tre._type == "TicketFollowUp"
          lead_fu_count+=1
          break
        end
      end
    end

    total_fu_count = ch_fu_count + lead_fu_count

    @ch_this_month_count = @ch_this_month.count
    @lead_this_month_count = @lead_this_month.count
    # @designers_this_month_count = @designer.where(:created_at => date_from..date_to).count
    @contests_this_month_count = @contest.where(:created_at => date_from..date_to).count

    data_count, hash_counts = [], {}

    hash_counts = {
      ch_lead: @ch_this_month_count+@lead_this_month_count,
      ch_lead_fu: total_fu_count,
      contest: @contests_this_month_count,
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
