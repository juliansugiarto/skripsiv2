# Extend in Notify class
# List of notification methods
module NotifyMethod

  def request_slot(arg)
    # Create notification
    notif = RequestNotification.create(
      purpose: "request_slot",
      notified: arg[:notified],
      title: "Designer has request to add more design.",
      description: arg[:description],
      read: false,
      contest: arg[:participation].try(:contest),
      participation: arg[:participation],
      designer: arg[:participation].try(:participant)
    )
    build.push(notif)
  end

  def request_slot_approved(arg)
    # Create notification
    notif = RequestNotification.create(
      purpose: "request_slot_approved",
      notified: arg[:notified],
      title: "Contest Holder approved your request.",
      description: arg[:description],
      read: false,
      contest: arg[:participation].try(:contest),
      participation: arg[:participation]
    )

    build.push(notif)
  end

  def ch_give_rating_entry(arg)
    # Create notification
    notif = RatingNotification.create(
      purpose: "ch_give_rating_entry",
      notified: arg[:notified],
      title: "Contest Holder Give Rating Design",
      description: "Contest Holder Give Rating Design",
      read: false,
      entry: arg[:entry],
      contest: arg[:participation].try(:contest),
      participation: arg[:participation]
    )

    build.push(notif)
  end

  def designer_upload_new_design(arg)
    # Create notification
    notif = UploadNotification.create(
      purpose: "designer_upload_new_design",
      notified: arg[:notified],
      title: "Designer upload a new design",
      description: "Designer upload a new design",
      read: false,
      entry: arg[:entry],
      contest: arg[:participation].try(:contest),
      participation: arg[:participation]
    )

    build.push(notif)
  end

  def designer_comment_entry(arg)
    # Create notification
    notif = CommentNotification.create(
      purpose: "designer_comment_entry",
      notified: arg[:notified],
      title: "Designer comment on a design",
      description: "Designer comment on a design",
      read: false,
      entry: arg[:entry],
      comment: arg[:comment]
    )

    build.push(notif)
  end

  def ch_comment_entry(arg)
    # Create notification
    notif = CommentNotification.create(
      purpose: "ch_comment_entry",
      notified: arg[:notified],
      title: "Contest Holder comment on your design",
      description: "Contest Holder comment on your design",
      read: false,
      entry: arg[:entry],
      comment: arg[:comment]
    )

    build.push(notif)
  end

  def designer_design_eliminated(arg)
    # Create notification
    notif = EntryNotification.create(
      purpose: "designer_design_eliminated",
      notified: arg[:notified],
      title: "Your Design has been Eliminated",
      description: "Your Design has been Eliminated",
      read: false,
      entry: arg[:entry]
    )

    build.push(notif)
  end

  def designer_comment_contest(arg)
    # Create notification
    notif = CommentNotification.create(
      purpose: arg[:purpose],
      notified: arg[:notified],
      title: "Designer comment on Contest",
      description: "Designer comment on Contest",
      read: false,
      contest: arg[:contest],
      comment: arg[:comment]
    )

    build.push(notif)
  end

  def ch_comment_contest(arg)
    # Create notification
    notif = CommentNotification.create(
      purpose: arg[:purpose],
      notified: arg[:notified],
      title: "Contest Holder comment on Contest",
      description: "Contest Holder comment on Contest",
      read: false,
      contest: arg[:contest],
      comment: arg[:comment]
    )

    build.push(notif)
  end

  def designer_design_winner(arg)
    notif = EntryNotification.create(
      purpose: "designer_design_winner",
      notified: arg[:notified],
      title: "Congratulation on winning a contest !",
      description: "Congratulation on winning a contest !",
      read: false,
      entry: arg[:entry]
    )

    build.push(notif)
  end

  def ch_winner_selected(arg)
    notif = ContestNotification.create(
      purpose: "ch_winner_selected",
      notified: arg[:notified],
      title: "A winner has been selected in your contest",
      description: "A winner has been selected in your contest",
      read: false,
      contest: arg[:contest],
      entry: arg[:entry]
    )

    build.push(notif)
  end

  def designer_runner_up(arg)
    notif = EntryNotification.create(
      purpose: "designer_runner_up",
      notified: arg[:notified],
      title: "Congratulation for being a runner up",
      description: "Congratulation for being a runner up",
      read: false,
      entry: arg[:entry]      
    )

    build.push(notif)
  end

  def runner_up_approved(arg)
    notif = ContestNotification.create(
      purpose: "runner_up_approved",
      notified: arg[:notified],
      title: "Runner up payment approved",
      description: "Runner up payment approved",
      read: false,
      contest: arg[:contest],
      entry: arg[:entry]     
    )

    build.push(notif)
  end

  def ch_signed_agreement(arg)
    notif = AgreementNotification.create(
      purpose: "ch_signed_agreement",
      notified: arg[:notified],
      title: "Contest Holder Signed the Agreement",
      description: "Contest Holder Signed the Agreement",
      read: false,
      agreement: arg[:agreement],
      workspace: arg[:workspace]
    )

    build.push(notif)
  end

  def designer_signed_agreement(arg)
    notif = AgreementNotification.create(
      purpose: "designer_signed_agreement",
      notified: arg[:notified],
      title: "Designer Signed the Agreement",
      description: "Designer Signed the Agreement",
      read: false,
      agreement: arg[:agreement],
      workspace: arg[:workspace]
    )
    
    build.push(notif)
  end

  def contest_winner_selected(arg)
    notif = ContestNotification.create(
      purpose: "contest_winner_selected",
      notified: arg[:notified],
      title: "A winner has been selected",
      description: "A winner has been selected",
      read: false,
      contest: arg[:contest]
    )

    build.push(notif)
  end

  def designer_comment_file_transfer(arg)
    notif = WorkspaceNotification.create(
      purpose: "designer_comment_file_transfer",
      notified: arg[:notified],
      title: "Designer comment on File Transfer",
      description: "Designer comment on File Transfer",
      read: false,
      workspace: arg[:workspace]
    )

    build.push(notif)
  end

  def ch_comment_file_transfer(arg)
    notif = WorkspaceNotification.create(
      purpose: "ch_comment_file_transfer",
      notified: arg[:notified],
      title: "Contest Holder comment on File Transfer",
      description: "Contest Holder comment on File Transfer",
      read: false,
      workspace: arg[:workspace]
    )

    build.push(notif)
  end

  def ch_upgrade_contest(arg)
    notif = ContestNotification.create(
      purpose: "ch_upgrade_contest",
      notified: arg[:notified],
      title: "Contest Holder upgrade a contest",
      description: "Contest Holder upgrade a contest",
      read: false,
      contest: arg[:contest]
    )

    build.push(notif)
  end

  def ch_upgrade_contest_approved(arg)
    notif = ContestNotification.create(
      purpose: "ch_upgrade_contest_approved",
      notified: arg[:notified],
      title: "Contest Holder upgrade a contest approved",
      description: "Contest Holder upgrade a contest approved",
      read: false,
      contest: arg[:contest]
    )

    build.push(notif)
  end

  def ch_close_workspace(arg)
    notif = WorkspaceNotification.create(
      purpose: "ch_close_workspace",
      notified: arg[:notified],
      title: "Contest Holder closed File Transfer",
      description: "Contest Holder closed File Transfer",
      read: false,
      workspace: arg[:workspace]
    )

    build.push(notif)
  end

  def ch_extend_contest(arg)
    notif = ContestNotification.create(
      purpose: "ch_extend_contest",
      notified: arg[:notified],
      title: "Contest Holder extend contest",
      description: "Contest Holder extend contest",
      read: false,
      contest: arg[:contest]
    )

    build.push(notif)

  end

  def ch_extend_contest_approved(arg)
    notif = ContestNotification.create(
      purpose: "ch_extend_contest_approved",
      notified: arg[:notified],
      title: "Contest Holder extend contest approved",
      description: "Contest Holder extend contest approved",
      read: false,
      contest: arg[:contest]
    )

    build.push(notif)
    
  end

  def designer_upload_file_master(arg)
    notif = WorkspaceNotification.create(
      purpose: "designer_upload_file_master",
      notified: arg[:notified],
      title: "Designer Upload File Master",
      description: "Designer Upload File Master",
      read: false,
      workspace: arg[:workspace]
    )

    build.push(notif)
  end

  def ch_contest_ending_in_2_days(arg)
    notif = ContestNotification.create(
      purpose: "ch_contest_ending_in_2_days",
      notified: arg[:notified],
      title: "Contest Ending in 2 days",
      description: "Contest ending in 2 days",
      read: false,
      contest: arg[:contest]
    )
    build.push(notif) 
  end

  def ch_winner_pending_deadline_in_1_day(arg)
    notif = ContestNotification.create(
      purpose: "ch_winner_pending_deadline_in_1_day",
      notified: arg[:notified],
      title: "Winner pending deadline in 1 day",
      description: "Winner pending deadline in 1 day",
      read: false,
      contest: arg[:contest]
    )
    build.push(notif) 
  end

  def ch_winner_pending_deadline_in_3_days(arg)
    notif = ContestNotification.create(
      purpose: "ch_winner_pending_deadline_in_3_days",
      notified: arg[:notified],
      title: "Winner pending deadline in 3 days",
      description: "Winner pending deadline in 3 days",
      read: false,
      contest: arg[:contest]
    )
    build.push(notif) 
  end

  def designer_contest_ending_in_2_days(arg)
    notif = ContestNotification.create(
      purpose: "designer_contest_ending_in_2_days",
      notified: arg[:notified],
      title: "Contest ending in 2 days",
      description: "Contest ending in 2 days",
      read: false,
      contest: arg[:contest]
    )
    build.push(notif) 
  end

  def designer_contest_ending_in_24_hours(arg)
    notif = ContestNotification.create(
      purpose: "designer_contest_ending_in_24_hours",
      notified: arg[:notified],
      title: "Contest ending in 24 hours",
      description: "Contest ending in 24 hours",
      read: false,
      contest: arg[:contest]
    )
    build.push(notif) 
  end

  def designer_brief_updated(arg)
    notif = ContestNotification.create(
      purpose: "designer_brief_updated",
      notified: arg[:notified],
      title: "Contest brief has been updated",
      description: "Contest brief has been updated",
      read: false,
      contest: arg[:contest]
    )
    build.push(notif) 
  end

  def ch_brief_updated(arg)
    notif = ContestNotification.create(
      purpose: "ch_brief_updated",
      notified: arg[:notified],
      title: "Contest brief has been updated",
      description: "Contest brief has been updated",
      read: false,
      contest: arg[:contest]
    )
    build.push(notif) 
  end
  
end