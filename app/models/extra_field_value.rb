# ================================================================================
# Part:
# Desc:
# ================================================================================
class ExtraFieldValue
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :value
  field :original_filename


  #                                                                       Relation
  # ==============================================================================
  belongs_to :extra_field
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
  class << self

    def get_value_from(contest_id,extra_field_id)
      extra_field_value = ExtraFieldValue.where(contest_id: contest_id, extra_field_id: extra_field_id).first
      extra_field_value.value if extra_field_value.present?
    end

    def get_extra_field_value_from(contest_id, extra_field_id)
      extra_field_value = ExtraFieldValue.where(contest_id: contest_id, extra_field_id: extra_field_id).first
      extra_field_value if extra_field_value.present?
    end

    def get_id_from(contest_id, extra_field_id)
      extra_field_value = ExtraFieldValue.where(contest_id: contest_id, extra_field_id: extra_field_id).first
      extra_field_value.id.to_s if extra_field_value.present?
    end

    def get_filename_from(contest_id,extra_field_id)
      extra_field_value = ExtraFieldValue.where(contest_id: contest_id, extra_field_id: extra_field_id).first
      if extra_field_value.present?
        return extra_field_value.original_filename if extra_field_value.original_filename.present?
      end
    end

  end

  #                                                                         Method
  # ==============================================================================
  private
  def before_destroy_callback
    if self.extra_field.extra_field_type.type == "attachment"
      directory = Rails.root.to_s + "/assets/files/contests/"
      FileUtils.remove_file("#{directory}#{self.value}") if File.file?("#{directory}#{self.value}")
    end
  end
  
end
