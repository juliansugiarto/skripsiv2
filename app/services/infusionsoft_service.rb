class InfusionsoftService

  # Kalau ada error "Wrong type NilClass.". Cek password infusionsoft di .env.development

  def initialize(email)
    @email  = email
    @member = Infusionsoft.contact_find_by_email(@email, [:Email, :Id])
  end

  def contact_add(username, phone, member_type, lang)
    if @member.blank?
      id = Infusionsoft.contact_add({ :Email => @email, :FirstName => username, :Phone1 => phone })
      if id.present? and member_type == 'ch'
        result_add_tag = Infusionsoft.contact_add_to_group(id, INFUSIONSOFT["tags"]["ch"])
        result_add_tag = Infusionsoft.contact_add_to_group(id, INFUSIONSOFT["tags"]["english"]) if lang == "en"
      end
    end
  end

  def contact_add_to_group(tag, category_slug = nil)
    if @member.present?

      if category_slug.present?
        category_slug.gsub!("-", "_")
        tag_id         = INFUSIONSOFT["tags"][tag][category_slug]
      else
        tag_id         = INFUSIONSOFT["tags"][tag]
      end

      member_id      = @member.first["Id"]
      result_add_tag = Infusionsoft.contact_add_to_group(member_id, tag_id) if tag_id.present?
    end
  end

end
