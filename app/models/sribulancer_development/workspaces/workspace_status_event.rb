# represent an event that change the state of a workspace
class WorkspaceStatusEvent < WorkspaceEvent

  # equality for user
  def ==(other)
    return self.class == other.class
  end

  # notify the other user in the workspace
  def notify
    sender = self.member
    receiver = self.find_receiver_from_sender_chat(sender)

    MemberMailerWorker.perform_async(member_id: receiver.id.to_s, workspace_id: self.workspace.id.to_s, status_event_id: self.id.to_s, perform: :send_status_event)
    TeamMailerWorker.perform_async(workspace_id: self.workspace.id.to_s, status_event_id: self.id.to_s, perform: :send_status_event)
  end

end
