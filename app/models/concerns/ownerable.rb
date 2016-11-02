module Ownerable

  def is_owned_by?(member = nil)
    self.owner == member ? true : member.is_super_user? ? true : false
  rescue
    false
  end

end
