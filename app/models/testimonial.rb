# ================================================================================
# Part:
# Desc:
# ================================================================================
class Testimonial
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Constant
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :body, :type => String
  field :body_en, :type => String
  field :image
  field :active, :type => Boolean, :default => false

  #                                                                       Relation
  # ==============================================================================
  belongs_to :owner, polymorphic: true
  belongs_to :contest


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
    def testimonial_from(from, confidential, active = true, page = 1, per = 7)
      testimonials = (active == true ? Testimonial.active : Testimonial.all).order_by([:created_at, :desc])
      if confidential # ambil kontes yang confidential
        testimonials = testimonials.select do |t|
          begin
            (t.contest.present? && t.contest.confidential_contest?)
          rescue Mongoid::Errors::DocumentNotFound => e
            false
          end
        end
      end

      testimonials = testimonials.select do |t|
        (from.to_s == 'designer' ? t.owner.is_designer? : t.owner.is_contest_holder?) if t.owner.is_present?
      end
      Kaminari.paginate_array(testimonials).page(page).per(per)
    end

    def contest_holder
      Testimonial.all.order_by([:created_at, :desc]).select {|t| t.owner.present? && t.owner.is_contest_holder? }
    end

    def designer
      Testimonial.all.order_by([:created_at, :desc]).select {|t| t.owner.present? && t.owner.is_designer? }
    end

    def active
      where(active: true)
    end
  end

  #                                                                         Method
  # ==============================================================================

end
