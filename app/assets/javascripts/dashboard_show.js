$(document).ready(function() {
  (function worker() {
    $.ajax({
      url: '/dashboard/ajax_data', 
      success: function(data) {
        $("h4.hl__count.ch-lead").html("");
        $("h4.hl__count.ch-lead-fu").html("");
        $("h4.hl__count.contest").html("");
        // Now that we've completed the request schedule the next one.
        var ch_lead = data.result[0].ch_lead;
        var ch_lead_fu = data.result[0].ch_lead_fu;
        var contest = data.result[0].contest;
        $("h4.hl__count.ch-lead").append(ch_lead).hide().fadeIn("slow");;
        $("h4.hl__count.ch-lead-fu").append(ch_lead_fu).hide().fadeIn("slow");;
        $("h4.hl__count.contest").append(contest).hide().fadeIn("slow");;
      },
      complete: function() {
        // Schedule the next request when the current one's complete
        setTimeout(worker, 3000);
      }
    });
  })();

  (function worker() {
    $.ajax({
      url: '/dashboard/ajax_data_dist', 
      success: function(data) {
        $("h4.hl__count.ch-contest").html("");
        $("h4.hl__count.designer-pass").html("");
        $("h4.hl__count.contest-active").html("");
        // Now that we've completed the request schedule the next one.
        var ch_create = data.result[0].ch_create;
        var designer_pass = data.result[0].designer_pass;
        var contest_active = data.result[0].contest_active;
        // var contest = data.result[0].contest;
        $("h4.hl__count.ch-contest").append(ch_create).hide().fadeIn("slow");;
        $("h4.hl__count.designer-pass").append(designer_pass).hide().fadeIn("slow");;
        $("h4.hl__count.contest-active").append(contest_active).hide().fadeIn("slow");;
      },
      complete: function() {
        // Schedule the next request when the current one's complete
        setTimeout(worker, 3000);
      }
    });
  })();

});
