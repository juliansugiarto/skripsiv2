class DashboardController < ApplicationController
	before_action :authenticate_user!
	def show
    ############### SRIBU #####################################
		@ch = Member.where(member_type_id: "4fac049959aa92040e000418")
		@designer = Member.where(member_type_id: "4fac049959aa92040e000419")
		@contest = Contest.all
		@agreement = Agreement.all
		@invoices = Invoice.all
    @lead = Lead.all
		
		date_from = "2016-09-01"
    date_to = "2016-10-01"

    #CH LAST MONTH
    @ch_last_month = @ch.where(:created_at => date_from..date_to)
    @ch_last_month_ids  = @ch_last_month.map(&:id);

    #CH+LEAD COUNT
		@ch_last_month_count = @ch_last_month.count
    @lead_last_month_count = @lead.where(:created_at => date_from..date_to).count

    #CH + LEAD FU COUNT
    @contests_last_month = @contest.where(:created_at => date_from..date_to)

    #CONTEST STATUS
    @contests_open_last_month_count = @contests_last_month.where(:status => ContestStatus.open).count
    @contests_wp_last_month_count = @contests_last_month.where(:status => ContestStatus.winner_pending).count
    @contests_ft_last_month_count = @contests_last_month.where(:status => ContestStatus.file_transfer).count
    @contests_closed_last_month_count = @contests_last_month.where(:status => ContestStatus.closed).count
    @contests_new_ch_last_month_count = @contests_last_month.where(:owner.in => @ch_last_month_ids).count

    #CONTEST PACKAGE
    @saver_last_month_count, @bronze_last_month_count, @silver_last_month_count, @gold_last_month_count = 0,0,0,0
    @saver_sales_last_month, @bronze_sales_last_month, @silver_sales_last_month, @gold_sales_last_month = 0,0,0,0
    @contests_last_month.each do |c|
      if c.package.cname == "saver"
        @saver_last_month_count+=1
      elsif c.package.cname == "bronze"
        @bronze_last_month_count+=1
      elsif c.package.cname == "silver"
        @silver_last_month_count+=1
      else
        @gold_last_month_count+=1
      end
    end
    #PACKAGE SALES
    contest_sales = @contests_last_month.where(:status_id.ne => ContestStatus.not_active._id)
    contest_sales.each do |c|
      if c.package.cname == "saver"
        @saver_sales_last_month+=c.invoices.sum(&:calculate_total)
      elsif c.package.cname == "bronze"
        @bronze_sales_last_month+=c.invoices.sum(&:calculate_total)
      elsif c.package.cname == "silver"
        @silver_sales_last_month+=c.invoices.sum(&:calculate_total)
      else
        @gold_sales_last_month+=c.invoices.sum(&:calculate_total)
      end
    end
 
    @saver_sales_last_month_count = number_with_delimiter(@saver_sales_last_month, delimiter: ".")
    @bronze_sales_last_month_count = number_with_delimiter(@bronze_sales_last_month, delimiter: ".")
    @silver_sales_last_month_count = number_with_delimiter(@silver_sales_last_month, delimiter: ".")
    @gold_sales_last_month_count = number_with_delimiter(@gold_sales_last_month, delimiter: ".")

    #COUNTER
    yesterday_ch_fu_count = 0
    yesterday_lead_fu_count = 0
    contest_paid_last_month = 0
    contest_less_participate_count = 0

    #TICKET
    @ticket_register_this_month = Ticket.where(:_type => "RegisterTicket", :created_at => date_from..date_to)
    @ticket_lead_this_month = Ticket.where(:_type => "LeadTicket", :created_at => date_from..date_to)

    #FOLLOWED UP REGISTER
    @ticket_register_this_month.each do |tr|
      tr.events.each do |tre|
        if tre._type == "TicketFollowUp"
          yesterday_ch_fu_count+=1
          break
        end
      end
    end
    #FOLLOWED UP LEAD
    @ticket_lead_this_month.each do |tr|
      tr.events.each do |tre|
        if tre._type == "TicketFollowUp"
          yesterday_lead_fu_count+=1
          break
        end
      end
    end

    #contest paid
    @contests_last_month.each do |c|
      if c.invoices.first.paid_at.present?
        contest_paid_last_month += 1
      end
    end

    total_yesterday_fu_count = yesterday_ch_fu_count + yesterday_lead_fu_count

		# @designers_last_month_count = @designer.where(:created_at => date_from..date_to).count
    #CONTEST YESTERDAY
		@contests_last_month_count = @contests_last_month.count
    @contest_paid_last_month_count = contest_paid_last_month
    #CH+lead YESTERDAY
    @yesterday_ch_lead = @ch_last_month_count + @lead_last_month_count
    @yesterday_ch_lead_fu = total_yesterday_fu_count
    ################################### END SRIBU ####################################

    ######################## SRIBULANCER ##################################
    #COMPONENTS
    @leads = LeadLancer.all
    @employer = EmployerMember.all
    @jobs = Job.all
    @job_order = JobOrder.all
    @jobs_public = @jobs.public_only
    @jobs_private = @jobs.private_only
    #for lead
    @fu = FollowUp.all

    #VARIABLE
    @jobs_public_last_month = @jobs_public.where(:created_at => date_from..date_to)
    @jobs_private_last_month = @jobs_private.where(:created_at => date_from..date_to)
    @employer_last_month = @employer.where(:created_at => date_from..date_to)
    @job_order_last_month = @job_order.where(:created_at => date_from..date_to)
    @leads_last_month = @leads.where(:created_at => date_from..date_to)

    #FU
    @employer_already_fu = @employer_last_month.where(:fu => true)
    public_not_rejected = @jobs_public_last_month.where(:status.ne => StatusLancer::REJECTED ) #JOB PUBLIC YG NO REJECT
    public_already_fu = public_not_rejected.where(:fu => true)
    private_not_rejected = @jobs_private_last_month.where(:status.ne => StatusLancer::REJECTED ) #JOB PRIVATE YG NO REJECT
    private_already_fu = private_not_rejected.where(:fu => true)
    job_order_already_fu = @job_order_last_month.where(:fu => true)

    #COUNTER
    @yesterday_potential_leads = @leads_last_month.count
    @yesterday_potential_employer = @employer_already_fu.count
    @yesterday_potential_jobs = public_already_fu.count
    @yesterday_potential_private = private_already_fu.count
    @yesterday_potential_job_order = job_order_already_fu.count
    ######################## END SRIBULANCER ##################################

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
    date_to = "2016-11-01"
    #VARIABLES
    @contests_last_month = @contest.where(:created_at => date_from..date_to)
    @contests_open_this_month = @contests_this_month.where(:status => ContestStatus.open)
    @ticket_register_this_month = Ticket.where(:_type => "RegisterTicket", :created_at => date_from..date_to)
    @ticket_lead_this_month = Ticket.where(:_type => "LeadTicket", :created_at => date_from..date_to)
    @ch_this_month = @ch.where(:created_at => date_from..date_to)
    @lead_this_month = @lead.where(:created_at => date_from..date_to)
    @followup_this_month = @followup.where(:created_at => date_from..date_to)

    ch_fu_count = 0
    lead_fu_count = 0
    contest_fu_count = @contests_this_month.count
    contest_paid_count = 0
    contest_less_participate_count = 0
    #FOLLOWED UP REGISTER
    @ticket_register_this_month.each do |tr|
      tr.events.each do |tre|
        if tre._type == "TicketFollowUp"
          ch_fu_count+=1
          break
        end
      end
    end
    #FOLLOWED UP LEAD
    @ticket_lead_this_month.each do |tr|
      tr.events.each do |tre|
        if tre._type == "TicketFollowUp"
          lead_fu_count+=1
          break
        end
      end
    end
    #CONTEST NEED FU
    @contests_this_month.each do |c|
      ticket = ContestUnpaidTicket.find_by(contest: c)
      if ticket.present?
        ticket.events.each do |tre|
          if tre._type == "TicketFollowUp"
            contest_fu_count -= 1
            break
          end
        end
      else
        contest_fu_count -= 1
      end
    end
    #CONTEST PAID
    @contests_this_month.each do |c|
      if c.invoices.first.paid_at.present?
        contest_paid_count +=1
      end
    end
    #Contest LESS PARTICIPATE
    @contests_open_this_month.each do |c|
      #duration left
      duration_left = (DateTime.now - c.end_date).to_i
      entries_limit = 20
      duration_limit = 3
      if duration_limit > 0
        if (duration_left <= duration_limit) and (c.entries.count <= entries_limit)
          contest_less_participate_count += 1
        end
      end
    end


    total_fu_count = ch_fu_count + lead_fu_count

    @ch_this_month_count = @ch_this_month.count
    @lead_this_month_count = @lead_this_month.count
    # @designers_this_month_count = @designer.where(:created_at => date_from..date_to).count
    # @contests_this_month_count = @contests_this_month.count

    data_count, hash_counts = [], {}

    hash_counts = {
      ch_lead: @ch_this_month_count+@lead_this_month_count,
      ch_lead_fu: total_fu_count,
      contest_need_fu: contest_fu_count,
      contest_paid: contest_paid_count,
      contest_less_participate: contest_less_participate_count
    }

    data_count << hash_counts

    render status: :ok, json: { :result => data_count}

  end

  def new_ch_contest
    @ch = Member.where(member_type_id: "4fac049959aa92040e000418")
    @designer = Member.where(member_type_id: "4fac049959aa92040e000419")
    @contest = Contest.all

    date_from = "2016-10-01"
    date_to = "2016-11-01"

    @contests_this_month = @contest.where(:created_at => date_from..date_to)
    #NEW CH CONTEST THIS MONTH
    @ch_create_contest_ids = @ch.where(:created_at => date_from..date_to).map(&:id)
    @contest_create_count = @contests_this_month.where(:owner.in => @ch_create_contest_ids).count

    data_count, hash_counts = [], {}
    hash_counts = {
      new_ch_contest: @contest_create_count,
      all_contest: @contests_this_month.count
    }

    data_count << hash_counts


    render status: :ok, json: { :result => data_count}


  end

  def contest_status
    @contest = Contest.all
    date_from = "2016-10-01"
    date_to = "2016-11-01"
    #Declare contest
    @contests_this_month = @contest.where(:created_at => date_from..date_to)
    @contests_open_this_month = @contests_this_month.where(:status => ContestStatus.open)
    @contests_wp_this_month = @contests_this_month.where(:status => ContestStatus.winner_pending)
    @contests_ft_this_month = @contests_this_month.where(:status => ContestStatus.file_transfer)
    @contests_closed_this_month = @contests_this_month.where(:status => ContestStatus.closed)

    contest_open_count = @contests_open_this_month.count
    contest_wp_count = @contests_wp_this_month.count
    contest_ft_count = @contests_ft_this_month.count
    contest_closed_count = @contests_closed_this_month.count

    data_count, hash_counts = [], {}
    hash_counts = {
      open: contest_open_count,
      wp: contest_wp_count,
      ft: contest_ft_count,
      closed: contest_closed_count
    }

    data_count << hash_counts

    render status: :ok, json: {:result => data_count}

  end

  def contest_package
    @contest = Contest.all

    date_from = "2016-10-01"
    date_to = "2016-11-01"
    #Declare contest
    @contests_this_month = @contest.where(:created_at => date_from..date_to)
    saver,bronze,silver,gold = 0,0,0,0
    #SAVER
    @contests_this_month.each do |c|
      if c.package.cname == "saver"
        saver+=1
      elsif c.package.cname == "bronze"
        bronze+=1
      elsif c.package.cname == "silver"
        silver+=1
      else
        gold+=1
      end
    end

    data_count, hash_counts = [], {}
    hash_counts = {
      saver: saver,
      bronze: bronze,
      silver: silver,
      gold: gold
    }

    data_count << hash_counts

    render status: :ok, json: {:result => data_count}

  end

  def contest_package_sales
    @contest = Contest.all

    date_from = "2016-10-01"
    date_to = "2016-11-01"
    #Declare contest
    @contests_this_month = @contest.where(:created_at => date_from..date_to)
    saver_sales,bronze_sales,silver_sales,gold_sales = 0,0,0,0
    contest_sales = @contests_this_month.where(:status_id.ne => ContestStatus.not_active._id)
    #SAVER
    contest_sales.each do |c|
      if c.package.cname == "saver"
        saver_sales+=c.invoices.sum(&:calculate_total)
      elsif c.package.cname == "bronze"
        bronze_sales+=c.invoices.sum(&:calculate_total)
      elsif c.package.cname == "silver"
        silver_sales+=c.invoices.sum(&:calculate_total)
      else
        gold_sales+=c.invoices.sum(&:calculate_total)
      end
    end

    data_count, hash_counts = [], {}
    hash_counts = {
      saver_sales: saver_sales,
      bronze_sales: bronze_sales,
      silver_sales: silver_sales,
      gold_sales: gold_sales
    }

    data_count << hash_counts

    render status: :ok, json: {:result => data_count}

  end

  def potential
    #COMPONENTS
    @leads = LeadLancer.all
    @employer = EmployerMember.all
    @jobs = Job.all
    @job_order = JobOrder.all
    @jobs_public = @jobs.public_only
    @jobs_private = @jobs.private_only
    #for lead
    @fu = FollowUp.all

    #DATE
    date_from = "2016-10-01"
    date_to = "2016-11-01"

    #VARIABLE
    @jobs_public_this_month = @jobs_public.where(:created_at => date_from..date_to)
    @jobs_private_this_month = @jobs_private.where(:created_at => date_from..date_to)
    @employer_this_month = @employer.where(:created_at => date_from..date_to)
    @job_order_this_month = @job_order.where(:created_at => date_from..date_to)
    @leads_this_month = @leads.where(:created_at => date_from..date_to)

    #FU
    @employer_need_fu = @employer_this_month.where(:fu => false)
    @fu_this_month = @fu.where(:created_at => date_from..date_to)
    @fu_lead_this_month = @fu_this_month.select{|d| d.lead_id != nil}
    #MENCOCOKAN LEADS FOLLOWEDUP DENGAN ALL LEADS THIS MONTH
    # lead_followed_up = 0
    # fu_lead_ids = @fu_lead_this_month.map(&:lead_id)
    # @leads_this_month.each do |leads|
    #   fu_lead_ids.each do |lead_fu|
    #     if leads.id == lead_fu
    #       lead_followed_up +=1
    #     end
    #   end
    # end 

    public_not_rejected = @jobs_public_this_month.where(:status.ne => StatusLancer::REJECTED ) #JOB PUBLIC YG NO REJECT
    public_no_fu = public_not_rejected.where(:fu => false)
    private_not_rejected = @jobs_private_this_month.where(:status.ne => StatusLancer::REJECTED ) #JOB PRIVATE YG NO REJECT
    private_no_fu = private_not_rejected.where(:fu => false)
    job_order_no_fu = @job_order_this_month.where(:paid_at => nil, :fu => false)

    leads_need_fu = @leads_this_month.count - @fu_lead_this_month.count
    employer_need_fu = @employer_need_fu.count
    public_need_fu = public_no_fu.count
    private_need_fu = private_no_fu.count
    job_order_need_fu = job_order_no_fu.count


    #AJAX
    data_count, hash_counts = [], {}
    hash_counts = {
      leads: leads_need_fu,
      employer: employer_need_fu,
      jobs: public_need_fu,
      private: private_need_fu,
      job_order: job_order_need_fu
    }

    data_count << hash_counts

    render status: :ok, json: {:result => data_count}
  end 

	def ga
		
	end
end
