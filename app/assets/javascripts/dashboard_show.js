$(document).ready(function() {
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
        // Now that we've completed the request schedule the next one.
        var saver = data.result[0].saver;
        var bronze = data.result[0].bronze;
        var silver = data.result[0].silver;
        var gold = data.result[0].gold;

        $("h4.hl__count.saver").append(saver).hide().fadeIn("slow");
        $("h4.hl__count.bronze").append(bronze).hide().fadeIn("slow");
        $("h4.hl__count.silver").append(silver).hide().fadeIn("slow");
        $("h4.hl__count.gold").append(gold).hide().fadeIn("slow");
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
        // Now that we've completed the request schedule the next one.
        var saver_sales = data.result[0].saver_sales.number_with_delimiter();;
        var bronze_sales = data.result[0].bronze_sales.number_with_delimiter();;
        var silver_sales = data.result[0].silver_sales.number_with_delimiter();;
        var gold_sales = data.result[0].gold_sales.number_with_delimiter();;

        $("h4.hl__sales.saver-sales").append(saver_sales).hide().fadeIn("slow");
        $("h4.hl__sales.bronze-sales").append(bronze_sales).hide().fadeIn("slow");
        $("h4.hl__sales.silver-sales").append(silver_sales).hide().fadeIn("slow");
        $("h4.hl__sales.gold-sales").append(gold_sales).hide().fadeIn("slow");
      },
      complete: function() {
        // Schedule the next request when the current one's complete
        setTimeout(worker, 5000);
      }
    });
  })();

});
