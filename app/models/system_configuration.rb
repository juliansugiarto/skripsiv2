# ================================================================================
# Part:
# Desc:
# ================================================================================
class SystemConfiguration
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :maximum_contest_attachment_file_size, type: Integer
  field :maximum_file_transfer_file_size, type: Integer
  field :maximum_contest_detail_attachment_file_size, type: Integer
  # field :usd_to_idr_exchange_rate, type: Float
  # field :idr_to_usd_exchange_rate, type: Float
  field :thematic, type: Boolean, default: false
  field :using_paypal, type: Boolean, default: false

  field :using_veritrans, type: Boolean, default: true

  # Kalau pakai vt_direct maka vt_web akan disable
  field :using_vt_direct, type: Boolean, default: false

  field :using_visa_commercial, type: Boolean, default: false
  field :api_url_development, type: String
  field :api_url_production, type: String
  field :using_reputation_system, type: Boolean
  field :time_designer_payment_day, type: String, default: 'wednesday'
  field :pph21, type: Float, default: 0.03

  field :patent_registration_email
  field :outsource_clothing_production_email
  field :outsource_video_production_email
  field :outsource_web_development_email
  field :outsource_web_hosting_email
  field :outsource_online_marketing_email
  field :outsource_printing_email
  field :outsource_production_email

  field :using_s3, type: Boolean
  field :using_affiliate_system, type: Boolean

  field :withdraw_design, type: Boolean

  field :website_contest_bronze_total_page, type: Integer, default: 1
  field :website_contest_silver_total_page, type: Integer, default: 1
  field :website_contest_gold_total_page, type: Integer, default: 1

  field :using_designer_test, type: Boolean, default: false

  field :using_hellobar_promo_250k, type: Boolean, default: false
  field :using_social_locker_budget, type: Boolean, default: false
  field :using_exit_intent_free_course, type: Boolean, default: false
  field :using_exit_intent_survey_pricing, type: Boolean, default: false
  field :using_sms_zenziva, type: Boolean, default: false

  field :using_auto_close_expired_file_transfer_after_n_days, type: Boolean, default: false
  field :how_long_auto_close_expired_file_transfer, type: Integer, default: 7

  field :show_we_are_hiring_in_menubar_homepage, type: Boolean, default: false

  field :show_hellobar_notification, type: Boolean, default: false
  field :enable_zopim, type: Boolean, default: true

  field :universal_password_frontend, type: String

  field :payout_other_bca_fee, type: Float

  # BLOG
  field :limit_ajax_running_contest, type: Integer, default: 10
  field :limit_ajax_testimonials, type: Integer, default: 5

  # Soft Selling
  field :soft_selling_private, type: Integer, default: 200000

  # Target
  field :monthly_sales_target, type: Float

  # Design Store
  field :file_download_expires, type: Integer, default: 10
  field :store_payment_paypal, type: Boolean, default: true
  field :store_thumbnail_size, type: Integer # in kilobytes
  field :store_preview_size, type: Integer # in kilobytes
  field :store_master_size, type: Integer # in megabytes

  field :currency_exchanges, type: Array

  #                                                                       Relation
  # ==============================================================================


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

    def using_designer_test?
      first.using_designer_test?
    end

    def withdraw_design?
      first.withdraw_design?
    end

    def default_api
      Rails.env.production? ? first.api_url_production : first.api_url_development
    end

    def thematic?
      first.thematic?
    end

    def using_paypal?
      first.using_paypal?
    end

    def using_veritrans?
      first.using_veritrans?
    end

    def using_vt_direct?
      first.using_vt_direct?
    end

    def using_visa_commercial?
      first.using_visa_commercial?
    end

    def using_reputation_system?
      first.using_reputation_system
    end

    def patent_registration_emails
      first.patent_registration_email.to_s
    end

    def outsource_clothing_production_emails
      first.outsource_clothing_production_email.to_s
    end

    def outsource_video_production_emails
      first.outsource_video_production_email.to_s
    end

    def outsource_web_development_emails
      first.outsource_web_development_email.to_s
    end

    def outsource_web_hosting_emails
      first.outsource_web_hosting_email.to_s
    end

    def using_s3?
      first.using_s3?
    end

    def pph21
      first.pph21
    end

    def website_contest_bronze_total_page
      first.website_contest_bronze_total_page
    end

    def website_contest_silver_total_page
      first.website_contest_silver_total_page
    end

    def website_contest_gold_total_page
      first.website_contest_gold_total_page
    end

    def using_affiliate_system?
      first.using_affiliate_system?
    end

    def using_hellobar_promo_250k?
      first.using_hellobar_promo_250k?
    end

    def using_social_locker_budget?
      first.using_social_locker_budget?
    end

    def using_exit_intent_free_course?
      first.using_exit_intent_free_course?
    end

    def using_exit_intent_survey_pricing?
      first.using_exit_intent_survey_pricing?
    end

    def using_exit_intent_firststep_survey?
      first.using_exit_intent_firststep_survey?
    end

    def using_exit_intent_secondstep_survey?
      first.using_exit_intent_secondstep_survey?
    end

    def using_sms_zenziva?
      first.using_sms_zenziva?
    end

    def using_auto_close_expired_file_transfer_after_n_days?
      first.using_auto_close_expired_file_transfer_after_n_days?
    end

    def how_long_auto_close_expired_file_transfer?
      first.how_long_auto_close_expired_file_transfer
    end

    def limit_ajax_running_contest
      first.limit_ajax_running_contest
    end

    def limit_ajax_testimonials
      first.limit_ajax_testimonials
    end

    def show_we_are_hiring_in_menubar_homepage?
      first.show_we_are_hiring_in_menubar_homepage?
    end

    def show_hellobar_notification?
      first.show_hellobar_notification?
    end

    def payout_other_bca_fee
      first.payout_other_bca_fee
    end

    def soft_selling_private_feature
      first.soft_selling_private
    end

    def file_download_expires
      first.file_download_expires
    end

    def store_payment_paypal?
      first.store_payment_paypal
    end

    def store_thumbnail_size
      first.store_thumbnail_size
    end

    def store_preview_size
      first.store_preview_size
    end

    def store_master_size
      first.store_master_size
    end

    def currency_exchanges
      first.currency_exchanges
    end

    def enable_zopim?
      first.enable_zopim
    end  


  end

  #                                                                         Method
  # ==============================================================================

end
