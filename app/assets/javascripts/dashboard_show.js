$(document).ready(function() {

  //SRIBU
  (function worker() {
    $.ajax({
      url: '/dashboard/ajax_data', 
      success: function(data) {
        $("h4.hl__count.ch-lead").html("");
        $("h4.hl__count.ch-lead-fu").html("");
        $("h4.hl__count.contest-need-fu").html("");
        $("h4.hl__count.contest-paid").html("");
        $("h4.hl__count.less-participate").html("");
        // Now that we've completed the request schedule the next one.
        var ch_lead = data.result[0].ch_lead;
        var ch_lead_fu = data.result[0].ch_lead_fu;
        var contest_need_fu = data.result[0].contest_need_fu;
        var contest_paid = data.result[0].contest_paid;
        var contest_less_participate = data.result[0].contest_less_participate;

        $("h4.hl__count.ch-lead").append(ch_lead).hide().fadeIn("slow");
        $("h4.hl__count.ch-lead-fu").append(ch_lead_fu).hide().fadeIn("slow");
        $("h4.hl__count.contest-need-fu").append(contest_need_fu).hide().fadeIn("slow");
        $("h4.hl__count.contest-paid").append(contest_paid).hide().fadeIn("slow");
        $("h4.hl__count.less-participate").append(contest_less_participate).hide().fadeIn("slow");
      },
      complete: function() {
        // Schedule the next request when the current one's complete
        setTimeout(worker, 3000);
      }
    });
  })();

  (function worker() {
    $.ajax({
      url: '/dashboard/new_ch_contest', 
      success: function(data) {
        $("h4.hl__count.new-ch-contest").html("");
        $("h6.hl__percentage.new-ch-contest").html("");
        // Now that we've completed the request schedule the next one.
        var new_ch_contest = data.result[0].new_ch_contest;
        var all_contest = data.result[0].all_contest;
        var percentage = Math.round((new_ch_contest/all_contest)*100);
        $("h4.hl__count.new-ch-contest").append(new_ch_contest+'/'+all_contest).hide().fadeIn("slow");
        $("h6.hl__percentage.new-ch-contest").append('('+percentage+'%'+')').hide().fadeIn("slow");
      },
      complete: function() {
        // Schedule the next request when the current one's complete
        setTimeout(worker, 5000);
      }
    });
  })();

  (function worker() {
    $.ajax({
      url: '/dashboard/contest_status', 
      success: function(data) {
        $("h4.hl__count.contest-open").html("");
        $("h4.hl__count.contest-wp").html("");
        $("h4.hl__count.contest-ft").html("");
        $("h4.hl__count.contest-closed").html("");
        // Now that we've completed the request schedule the next one.
        var open = data.result[0].open;
        var wp = data.result[0].wp;
        var ft = data.result[0].ft;
        var closed = data.result[0].closed;

        $("h4.hl__count.contest-open").append(open).hide().fadeIn("slow");
        $("h4.hl__count.contest-wp").append(wp).hide().fadeIn("slow");
        $("h4.hl__count.contest-ft").append(ft).hide().fadeIn("slow");
        $("h4.hl__count.contest-closed").append(closed).hide().fadeIn("slow");
      },
      complete: function() {
        // Schedule the next request when the current one's complete
        setTimeout(worker, 5000);
      }
    });
  })();

  (function worker() {
    $.ajax({
      url: '/dashboard/contest_package', 
      success: function(data) {
        $("h4.hl__count.saver").html("");
        $("h4.hl__count.bronze").html("");
        $("h4.hl__count.silver").html("");
        $("h4.hl__count.gold").html("");
        $("h4.hl__count.store-sold").html("");
        // Now that we've completed the request schedule the next one.
        var saver = data.result[0].saver;
        var bronze = data.result[0].bronze;
        var silver = data.result[0].silver;
        var gold = data.result[0].gold;
        var store_sold = data.result[0].store_sold;

        $("h4.hl__count.saver").append(saver).hide().fadeIn("slow");
        $("h4.hl__count.bronze").append(bronze).hide().fadeIn("slow");
        $("h4.hl__count.silver").append(silver).hide().fadeIn("slow");
        $("h4.hl__count.gold").append(gold).hide().fadeIn("slow");
        $("h4.hl__count.store-sold").append(store_sold).hide().fadeIn("slow");
      },
      complete: function() {
        // Schedule the next request when the current one's complete
        setTimeout(worker, 5000);
      }
    });
  })();


  Number.prototype.number_with_delimiter = function(delimiter) {
      var number = this + '', delimiter = delimiter || '.';
      var split = number.split('.');
      split[0] = split[0].replace(
          /(\d)(?=(\d\d\d)+(?!\d))/g,
          '$1' + delimiter
      );
      return split.join('.');    
  };

  (function worker() {
    $.ajax({
      url: '/dashboard/contest_package_sales', 
      success: function(data) {
        $("h4.hl__sales.saver-sales").html("");
        $("h4.hl__sales.bronze-sales").html("");
        $("h4.hl__sales.silver-sales").html("");
        $("h4.hl__sales.gold-sales").html("");
        $("h4.hl__sales.store-sales").html("");
        $("h4.hl__sales--recap.today-sales").html("");
        $("h6.hl__percentage.today-sales").html("");
        $("h4.hl__sales--recap.month-sales").html("");
        $("h6.hl__percentage.month-sales").html("");


        // Now that we've completed the request schedule the next one.
        var saver_sales = data.result[0].saver_sales.number_with_delimiter();
        var bronze_sales = data.result[0].bronze_sales.number_with_delimiter();
        var silver_sales = data.result[0].silver_sales.number_with_delimiter();
        var gold_sales = data.result[0].gold_sales.number_with_delimiter();
        var store_sales = data.result[0].store_sales.number_with_delimiter();
        var today_sales = data.result[0].today_sales.number_with_delimiter();
        var month_sales = data.result[0].month_sales.number_with_delimiter();
        var target_sales = (650000000);
        var target_sales_month = (1000000000);
        var percentage = Math.round((data.result[0].today_sales/target_sales)*100);
        var percentage_month = Math.round((data.result[0].month_sales/target_sales_month)*100);
        var target_sales_tidy = target_sales.number_with_delimiter();
        var target_sales_month_tidy = target_sales_month.number_with_delimiter();

        $("h4.hl__sales.saver-sales").append(saver_sales).hide().fadeIn("slow");
        $("h4.hl__sales.bronze-sales").append(bronze_sales).hide().fadeIn("slow");
        $("h4.hl__sales.silver-sales").append(silver_sales).hide().fadeIn("slow");
        $("h4.hl__sales.gold-sales").append(gold_sales).hide().fadeIn("slow");
        $("h4.hl__sales.store-sales").append(store_sales).hide().fadeIn("slow");
        $("h4.hl__sales--recap.today-sales").append(today_sales+"<br>"+'/'+target_sales_tidy).hide().fadeIn("slow");
        $("h6.hl__percentage.today-sales").append('('+percentage+'%'+')').hide().fadeIn("slow");
        $("h4.hl__sales--recap.month-sales").append(month_sales+"<br>"+'/'+target_sales_month_tidy).hide().fadeIn("slow");
        $("h6.hl__percentage.month-sales").append('('+percentage_month+'%'+')').hide().fadeIn("slow");
      },
      complete: function() {
        // Schedule the next request when the current one's complete
        setTimeout(worker, 5000);
      }
    });
  })();



  //SRIBULANCER
  (function worker() {
    $.ajax({
      url: '/dashboard/potential', 
      success: function(data) {
        $("h4.hl__count.potential-leads").html("");
        $("h4.hl__count.potential-employer").html("");
        $("h4.hl__count.potential-jobs").html("");
        $("h4.hl__count.potential-private").html("");
        $("h4.hl__count.potential-jo").html("");
        // Now that we've completed the request schedule the next one.
        var leads = data.result[0].leads;
        var employer = data.result[0].employer;
        var jobs = data.result[0].jobs;
        var private = data.result[0].private;
        var job_order = data.result[0].job_order;

        $("h4.hl__count.potential-leads").append(leads).hide().fadeIn("slow");
        $("h4.hl__count.potential-employer").append(employer).hide().fadeIn("slow");
        $("h4.hl__count.potential-jobs").append(jobs).hide().fadeIn("slow");
        $("h4.hl__count.potential-private").append(private).hide().fadeIn("slow");
        $("h4.hl__count.potential-jo").append(job_order).hide().fadeIn("slow");
      },
      complete: function() {
        // Schedule the next request when the current one's complete
        setTimeout(worker, 5000);
      }
    });
  })();

  (function worker() {
    $.ajax({
      url: '/dashboard/lancer_data', 
      success: function(data) {
        $("h4.hl__count.urgent-workspace").html("");
        $("h4.hl__count.employer-register").html("");
        $("h4.hl__count.job-posted").html("");
        $("h4.hl__count.job-approved").html("");
        $("h4.hl__count.package-order").html("");
        // Now that we've completed the request schedule the next one.
        var urgent = data.result[0].urgent;
        var employer_register = data.result[0].employer_register;
        var jobs_posted = data.result[0].jobs_posted;
        var jobs_approved = data.result[0].jobs_approved;
        var package_order = data.result[0].package_order;

        $("h4.hl__count.urgent-workspace").append(urgent).hide().fadeIn("slow");
        $("h4.hl__count.employer-register").append(employer_register).hide().fadeIn("slow");
        $("h4.hl__count.job-posted").append(jobs_posted).hide().fadeIn("slow");
        $("h4.hl__count.job-approved").append(jobs_approved).hide().fadeIn("slow");
        $("h4.hl__count.package-order").append(package_order).hide().fadeIn("slow");
      },
      complete: function() {
        // Schedule the next request when the current one's complete
        setTimeout(worker, 5000);
      }
    });
  })();

  (function worker() {
    $.ajax({
      url: '/dashboard/lancer_paid', 
      success: function(data) {
        $("h4.hl__count.private-paid").html("");
        $("h4.hl__count.public-paid").html("");
        $("h4.hl__count.package-paid").html("");

        // Now that we've completed the request schedule the next one.
        var private_paid = data.result[0].private_paid;
        var public_paid = data.result[0].public_paid;
        var package_paid = data.result[0].package_paid;


        $("h4.hl__count.private-paid").append(private_paid).hide().fadeIn("slow");
        $("h4.hl__count.public-paid").append(public_paid).hide().fadeIn("slow");
        $("h4.hl__count.package-paid").append(package_paid).hide().fadeIn("slow");

      },
      complete: function() {
        // Schedule the next request when the current one's complete
        setTimeout(worker, 5000);
      }
    });
  })();

  (function worker() {
    $.ajax({
      url: '/dashboard/lancer_sales', 
      success: function(data) {
        $("h4.hl__sales.private-sales").html("");
        $("h4.hl__sales.public-sales").html("");
        $("h4.hl__sales.package-sales").html("");
        $("h4.hl__sales--recap.today-sales-lancer").html("");
        $("h6.hl__percentage.today-sales-lancer").html("");
        $("h4.hl__sales--recap.month-sales-lancer").html("");
        $("h6.hl__percentage.month-sales-lancer").html("");

        // Now that we've completed the request schedule the next one.
        var private_sales = data.result[0].private_sales.number_with_delimiter();
        var public_sales = data.result[0].public_sales.number_with_delimiter();
        var package_sales = data.result[0].package_sales.number_with_delimiter();
        var today_sales = data.result[0].today_sales.number_with_delimiter();
        var month_sales = data.result[0].month_sales.number_with_delimiter();
        var target_sales = (650000000);
        var target_sales_month = (1000000000);
        var percentage = Math.round((data.result[0].today_sales/target_sales)*100);
        var percentage_month = Math.round((data.result[0].month_sales/target_sales_month)*100);
        var target_sales_tidy = target_sales.number_with_delimiter();
        var target_sales_month_tidy = target_sales_month.number_with_delimiter();

        $("h4.hl__sales.private-sales").append(private_sales).hide().fadeIn("slow");
        $("h4.hl__sales.public-sales").append(public_sales).hide().fadeIn("slow");
        $("h4.hl__sales.package-sales").append(package_sales).hide().fadeIn("slow");
        $("h4.hl__sales--recap.today-sales-lancer").append(today_sales+"<br>"+'/'+target_sales_tidy).hide().fadeIn("slow");
        $("h6.hl__percentage.today-sales-lancer").append('('+percentage+'%'+')').hide().fadeIn("slow");
        $("h4.hl__sales--recap.month-sales-lancer").append(month_sales+"<br>"+'/'+target_sales_month_tidy).hide().fadeIn("slow");
        $("h6.hl__percentage.month-sales-lancer").append('('+percentage_month+'%'+')').hide().fadeIn("slow");

      },
      complete: function() {
        // Schedule the next request when the current one's complete
        setTimeout(worker, 5000);
      }
    });
  })();


});
