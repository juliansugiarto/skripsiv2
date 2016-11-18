class Setting
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'settings'
  field :size_daily_recap, :type => Integer, default: 0
  field :is_using_size_daily_recap, type: Boolean, default: false
  field :is_using_survicate, type: Boolean, default: false
  field :is_using_adroll, type: Boolean, default: false
  field :is_using_zenziva, type: Boolean, default: false
  field :is_using_optimizely, type: Boolean, default: false
  field :is_using_optinmonster, type: Boolean, default: false
  field :is_using_kissmetrics, type: Boolean, default: false
  field :is_using_zopim, type: Boolean, default: false
  field :is_using_bornevia_livechat, type: Boolean, default: false
  field :is_using_perfect_audience, type: Boolean, default: false
  field :is_using_mywot, type: Boolean, default: false
  field :is_using_inspectlet, type: Boolean, default: false
  field :is_using_analytics, type: Boolean, default: false
  field :is_using_google_adwords, type: Boolean, default: false
  field :is_using_hot_jar, type: Boolean, default: false
  field :is_using_pixel, type: Boolean, default: false
  field :is_using_active_campaign_tracking_list, type: Boolean, default: false
  field :is_using_crazy_egg, type: Boolean, default: false
  field :is_using_sumome, type: Boolean, default: false
  field :is_using_veritrans, type: Boolean, default: false
  field :does_service_provider_need_verification, type: Boolean, default: true
  field :monthly_target, type: Float
  field :universal_password_frontend, type: String

  class << self

    def all_fields
      Setting.fields.keys.reject {|i| ["_id", "created_at", "updated_at"].include?(i) }
    end

    def value_fields
       Setting.all_fields.reject {|i| i.include?("is_using") || i.include?("does_service_provider_need_verification") || i.include?("universal_password_frontend") }
    end

    def question_fields
      Setting.all_fields.select {|i| i.include?("is_using") || i.include?("does_service_provider_need_verification")}
    end

    def self.provides_static_class_for(field_name, with_question_sign)
      # Check if field is in asking manner.
      class_eval %Q{
        def #{field_name}#{with_question_sign ? "?" : ""}
          return self.get_instance.#{field_name}
        end
      }
    end

    Setting.value_fields.each do |field_name|
      provides_static_class_for(field_name, false)
    end

    Setting.question_fields.each do |field_name|
      provides_static_class_for(field_name, true)
    end

    # Don't change this.
    def get_instance
      @setting ||= self.first
    end
  end
end
