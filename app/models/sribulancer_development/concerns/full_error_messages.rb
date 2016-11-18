module FullErrorMessages
  extend ActiveSupport::Concern

  # includes errors on this model as well as any nested models
  def all_error_messages
    messages = self.errors.messages.dup
    nested_messages = Hash.new
    keys_removed = Array.new
    messages.each do |column, errors|
      if self.respond_to?(:"#{column}_attributes=") && (resource = self.send(column))
        keys_removed << column
        if resource.is_a?(Array)
          resource.each_with_index do |sub_resource, index|
            nested_messages["#{column} ##{index + 1}"] = sub_resource.errors.messages
          end
        else
          nested_messages[column] = resource.errors.messages
        end
      end
    end

    # combine original message with nested message, also remove the nested keys from the original message
    messages.merge!(nested_messages).except!(*keys_removed)
  end

  # this is the goodness:
  #1.9.3-p362 :008 > s.all_full_error_messages
  # => ["Purchaser can't be blank", "Consumer email can't be blank", "Consumer email is invalid", "Consumer full name can't be blank"]
  #
  # this is what we're avoiding:
  #1.9.3-p362 :009 > s.errors.full_messages
  # => ["Purchaser can't be blank", "Consumer is invalid"]
  def all_full_error_messages
    # this would properly done with full recursion, right now we're limited to a single level
    formatter = self.errors.method(:full_message)
    self.all_error_messages.map do |attribute, messages|
      if messages.is_a? Hash
        messages.map { |nested_attribute, messages| messages.map { |message| formatter.call("#{attribute} #{nested_attribute}", message) } }
      else
        messages.map { |message| formatter.call(attribute, message) }
      end
    end.flatten
  end

end
