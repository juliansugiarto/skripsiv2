# Create notification via this service
class Notify
  #                                                              Included/Required
  # ==============================================================================
  extend NotifyMethod

  #                                                                     Initialize
  # ==============================================================================


  #                                                                  Class Methods
  # ==============================================================================
  class << self

    def build()
      new()
    end

  end


  #                                                               Instance Methods
  # ==============================================================================
  # Push notification to client
  def push(notif)

  end

end
