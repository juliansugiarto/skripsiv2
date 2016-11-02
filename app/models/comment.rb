# ================================================================================
# Part:
# Desc:
# ================================================================================
class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                       Constant
  # ==============================================================================
  before_save :before_save_callback

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :body, type: String
  field :active, type: Boolean, default: true
  field :image

  # DEPRECATED, DELETED SOON
  field :private_chat, type: Boolean, default: false
  field :comment_for_winner_position, type: Integer, default: 0

  #                                                                       Relation
  # ==============================================================================
  # Author comment can be member (CH, Designer), user, system, robot, etc
  belongs_to :author, polymorphic: true

  # Context comment can be Contest or Entry
  belongs_to :commentable, polymorphic: true

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates_presence_of :body

  #                                                                   Class Method
  # ==============================================================================
  class << self
    def comment_from_sibby(contest=nil, flag=nil)
      sibby = Member.find_by(username: "sibby")
      case flag
      when "edit_brief"
        comment = contest.comments.build(
          body: "notifications.automatic.edit_brief_notif",
          author: sibby
        )
      when "first_comment"
        comment = contest.comments.build(
          body: "notifications.automatic.first_comment_in_open_contest",
          author: sibby
        )
      # elsif flag == "extend_contest"
      #   comment = contest.comments.build(comment: "contest_details.show.extend_contest")
      # elsif flag == "first_comment_in_open_contest"
      #   comment = contest.comments.build(comment: "contest_details.show.first_comment_in_open_contest")
      end
      comment.save
    end
  end

  #                                                                         Method
  # ==============================================================================
  def before_save_callback
    self.body = self.body.gsub(/(\r)?\n/, "<br/>")
  end

  

end
