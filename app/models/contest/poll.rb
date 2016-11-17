# ================================================================================
# Part:
# Desc:
# ================================================================================
class Poll
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                       Constant
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================
  attr_accessor :name_title

  #                                                                       Callback
  # ==============================================================================
  before_save :before_save_poll

  #                                                                          Field
  # ==============================================================================
  field :title, type: String
  field :slug, type: String
  field :designs_poll, type: Array, default: []
  field :vote, type: Hash, default: {}
  field :share, type: Boolean, default: false

  #                                                                       Relation
  # ==============================================================================
  belongs_to :contest

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================


  #                                                                   Class Method
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================
  def before_save_poll
    self.slug = SribuUtils::Util.slug_word([self.title, self.id])
  end

  def share_poll(client, polling_path, provider ='facebook')
    if provider.eql?('facebook')
      FacebookCredential.share_designs_to_facebook(client, self, polling_path)
      self.share = true
      self.save!
    end
  end

  # Pool design choosed by client - add
  def add_design_pool(id_design)
    return false if self.designs_poll.include?(id_design)

    self.vote["#{id_design}"] =  0
    self.designs_poll << id_design
    self.save!
  end

  # Pool design choosed by client - remove
  def remove_from_design_pool(id_design)
    return false if !self.designs_poll.include?(id_design)

    self.designs_poll.delete(id_design)
    self.save!
  end

end
