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
    @store_invoice = StoreInvoice.all
    @store_purchase = StorePurchase.all
		
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
    @saver_sales_last_month, @bronze_sales_last_month, @silver_sales_last_month, @gold_sales_last_month, @yesterday_sales = 0,0,0,0,0

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
    store_sold = @store_invoice.where(:paid_at => date_from..date_to)
    @store_sold_last_month_count = store_sold.count
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
    store_sold_ids = @store_invoice.where(:paid_at => date_from..date_to).map(&:id)
    store_sales = @store_purchase.where(:invoice_id.in => store_sold_ids).map(&:prize).reduce(:+)
    @yesterday_sales = @saver_sales_last_month + @bronze_sales_last_month + @silver_sales_last_month + @gold_sales_last_month + store_sales

    @saver_sales_last_month_count = number_with_delimiter(@saver_sales_last_month, delimiter: ".")
    @bronze_sales_last_month_count = number_with_delimiter(@bronze_sales_last_month, delimiter: ".")
    @silver_sales_last_month_count = number_with_delimiter(@silver_sales_last_month, delimiter: ".")
    @gold_sales_last_month_count = number_with_delimiter(@gold_sales_last_month, delimiter: ".")
    @store_sales_last_month_count = number_with_delimiter(store_sales,delimiter: ".")
    @yesterday_sales = number_with_delimiter(@yesterday_sales,delimiter: ".")

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
    @workspace = WorkspaceLancer.all
    @package_order = PackageOrder.all
    @order = Order.all
    #for lead
    @fu = FollowUp.all

    #VARIABLE
    @jobs_last_month = @jobs.where(:created_at => date_from..date_to)
    @jobs_public_last_month = @jobs_public.where(:created_at => date_from..date_to)
    @jobs_private_last_month = @jobs_private.where(:created_at => date_from..date_to)
    @employer_last_month = @employer.where(:created_at => date_from..date_to)
    @job_order_last_month = @job_order.where(:created_at => date_from..date_to)
    @leads_last_month = @leads.where(:created_at => date_from..date_to)
    @po_last_month = @package_order.where(:created_at => date_from..date_to)

    #JOBS POSTED
    job_posted_yesterday = @jobs_public_last_month.count
    #JOBS APPROVED
    job_approved_yesterday = @jobs_last_month.where(:member_id.exists => true, :deleted_at => nil, status: StatusLancer::APPROVED, private: false).count
    #PACKAGE ORDER
    package_order_yesterday = @po_last_month.count

    #PAID
    po_paid_last_month = @package_order.where(:paid_at => date_from..date_to).count
    public_paid_last_month = @jobs_public.paid_by_date(date_from,date_to).count
    private_paid_last_month = @jobs_private.paid_by_date(date_from,date_to).count

    #SALES
    public_paid_ids = @jobs_public.paid_by_date(date_from,date_to).map(&:id)
    private_paid_ids = @jobs_private.paid_by_date(date_from,date_to).map(&:id)

    po_sales_last_month = @package_order.where(:paid_at => date_from..date_to).map(&:budget).reduce(:+)
    public_sales_last_month = Order.where(:job_id.in => public_paid_ids).map(&:budget).reduce(:+)
    private_sales_last_month = Order.where(:job_id.in => private_paid_ids).map(&:budget).reduce(:+)

    #FU
    @employer_already_fu = @employer_last_month.where(:fu => true)
    public_not_rejected = @jobs_public_last_month.where(:status.ne => StatusLancer::REJECTED ) #JOB PUBLIC YG NO REJECT
    public_already_fu = public_not_rejected.where(:fu => true)
    private_not_rejected = @jobs_private_last_month.where(:status.ne => StatusLancer::REJECTED ) #JOB PRIVATE YG NO REJECT
    private_already_fu = private_not_rejected.where(:fu => true)
    job_order_already_fu = @job_order_last_month.where(:fu => true)

    #COUNTER
      #POTENTIAL
    @yesterday_potential_leads = @leads_last_month.count
    @yesterday_potential_employer = @employer_already_fu.count
    @yesterday_potential_jobs = public_already_fu.count
    @yesterday_potential_private = private_already_fu.count
    @yesterday_potential_job_order = job_order_already_fu.count
      #LANCER_DATA
    @yesterday_employer_register = @employer_last_month.count
    @yesterday_jobs_posted = job_posted_yesterday
    @yesterday_jobs_approved = job_approved_yesterday
    @yesterday_package_order = package_order_yesterday
      #LANCER_PAID
    @yesterday_private_paid = private_paid_last_month
    @yesterday_public_paid = public_paid_last_month
    @yesterday_package_paid = po_paid_last_month
      #LANCER_SALES
    @yesterday_private_sales = number_with_delimiter(private_sales_last_month,delimiter: ".")
    @yesterday_public_sales = number_with_delimiter(public_sales_last_month,delimiter: ".")
    @yesterday_package_sales = number_with_delimiter(po_sales_last_month,delimiter: ".")
    @yesterday_sales_lancer = number_with_delimiter((private_sales_last_month + public_sales_last_month + po_sales_last_month),delimiter: ".")
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
    @contests_this_month = @contest.where(:created_at => date_from..date_to)
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
    @store_invoice = StoreInvoice.all

    date_from = "2016-10-01"
    date_to = "2016-11-01"
    #Declare contest
    @contests_this_month = @contest.where(:created_at => date_from..date_to)
    saver,bronze,silver,gold = 0,0,0,0
    #PACKAGE COUNT
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

    store_sold = @store_invoice.where(:paid_at => date_from..date_to)
    store_sold_count = store_sold.count

    data_count, hash_counts = [], {}
    hash_counts = {
      saver: saver,
      bronze: bronze,
      silver: silver,
      gold: gold,
      store_sold: store_sold_count
    }

    data_count << hash_counts

    render status: :ok, json: {:result => data_count}

  end

  def contest_package_sales
    @contest = Contest.all
    @store_invoice = StoreInvoice.all
    @store_purchase = StorePurchase.all

    date_from = "2016-10-01"
    date_to = "2016-11-01"
    #Declare contest
    @contests_this_month = @contest.where(:created_at => date_from..date_to)
    saver_sales,bronze_sales,silver_sales,gold_sales,today_sales = 0,0,0,0,0
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

    store_sold_ids = @store_invoice.where(:paid_at => date_from..date_to).map(&:id)
    store_sales = @store_purchase.where(:invoice_id.in => store_sold_ids).map(&:prize).reduce(:+)
    if store_sales == nil
      store_sales = 0
    end
    today_sales = saver_sales + bronze_sales + silver_sales + gold_sales + store_sales
    month_sales = saver_sales + bronze_sales + silver_sales + gold_sales + store_sales
    #AJAX
    data_count, hash_counts = [], {}
    hash_counts = {
      saver_sales: saver_sales,
      bronze_sales: bronze_sales,
      silver_sales: silver_sales,
      gold_sales: gold_sales,
      store_sales: store_sales,
      today_sales: today_sales,
      month_sales: month_sales
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

  def lancer_data
    #COMPONENTS
    @workspace = WorkspaceLancer.all
    @package_order = PackageOrder.all
    @employer = EmployerMember.all
    @jobs = Job.all
    #DATE
    date_from = "2016-10-01"
    date_to = "2016-11-01"

    #VARIABLE
    @workspace_this_month = @workspace.where(:created_at => date_from..date_to)
    @employer_this_month = @workspace.where(:created_at => date_from..date_to)
    @jobs_this_month = @jobs.where(:created_at => date_from..date_to)
    @po_this_month = @package_order.where(:created_at => date_from..date_to)

    #URGENT
    urgent_workspace_count = 0
    @workspace_this_month.each do |w|
      if w.alert?
        urgent_workspace_count +=1
      end
    end
    #NEW REGIS
    employer_regis = @employer_this_month.count
    #JOBS POSTED
    job_posted= @jobs_this_month.public_only.count
    #JOBS APPROVED
    job_approved = @jobs_this_month.where(:member_id.exists => true, :deleted_at => nil, status: StatusLancer::APPROVED, private: false).count
    #PACKAGE ORDER
    package_order = @po_this_month.count

    #AJAX
    data_count, hash_counts = [], {}
    hash_counts = {
      urgent: urgent_workspace_count,
      employer_register: employer_regis,
      jobs_posted: job_posted,
      jobs_approved: job_approved,
      package_order: package_order
    }

    data_count << hash_counts

    render status: :ok, json: {:result => data_count}

  end

  def lancer_paid
    #COMPONENTS
    @package_order = PackageOrder.all
    @jobs = Job.all
    @jobs_public = @jobs.public_only
    @jobs_private = @jobs.private_only
    #DATE
    date_from = "2016-10-01"
    date_to = "2016-11-01"
    #VARIABLES
    po_paid_this_month = @package_order.where(:paid_at => date_from..date_to).count
    public_paid_this_month = @jobs_public.paid_by_date(date_from,date_to).count
    private_paid_this_month = @jobs_private.paid_by_date(date_from,date_to).count

    #AJAX
    data_count, hash_counts = [], {}
    hash_counts = {
      private_paid: private_paid_this_month,
      public_paid: public_paid_this_month,
      package_paid: po_paid_this_month
    }

    data_count << hash_counts

    render status: :ok, json: {:result => data_count}


  end

  def lancer_sales
    #COMPONENTS
    @package_order = PackageOrder.all
    @order = Order.all
    @jobs = Job.all
    @jobs_public = @jobs.public_only
    @jobs_private = @jobs.private_only
    #DATE
    date_from = "2016-10-01"
    date_to = "2016-11-01"
    #VARIABLES
    po_paid_this_month = @package_order.where(:paid_at => date_from..date_to)
    public_paid_ids = @jobs_public.paid_by_date(date_from,date_to).map(&:id)
    private_paid_ids = @jobs_private.paid_by_date(date_from,date_to).map(&:id)

    po_sales_this_month = po_paid_this_month.map(&:budget).reduce(:+)
    public_sales_this_month = Order.where(:job_id.in => public_paid_ids).map(&:budget).reduce(:+)
    private_sales_this_month = Order.where(:job_id.in => private_paid_ids).map(&:budget).reduce(:+)

    today_sales = private_sales_this_month + public_sales_this_month + po_sales_this_month
    month_sales = private_sales_this_month + public_sales_this_month + po_sales_this_month
    #AJAX
    data_count, hash_counts = [], {}
    hash_counts = {
      private_sales: private_sales_this_month,
      public_sales: public_sales_this_month,
      package_sales: po_sales_this_month,
      today_sales: today_sales,
      month_sales: month_sales
    }

    data_count << hash_counts

    render status: :ok, json: {:result => data_count}

  end

	def ga
		
	end
end
