class ProfilePdf < Prawn::Document
  
  def initialize(params ={})
    super(:top_margin => 25)
    member = Member.find params[:id]
    render_content(member)
  end
    
  private
  def render_content(member)
    custom_font = {:large => 28, :medium => 16, :small => 10}
    custom_color = {:black => "000000", :light_blue => "6CA9DC", :dark_blue => "00599A", :grey => "646566"}

    float do 
      text member.country.name, align: :right
      # text member.email, align: :right
      # text "+#{member.country.phone_code} #{member.contact_number}", align: :right
    end

    # Photo, name and title
    if member.photo_url.present? and File.exist?(member.photo_url)
      photo_profile = member.photo_url
      image open(photo_profile), :width => 100 unless photo_profile.include?(".gif")
      move_down 15
    end
    text member.name, :size => custom_font[:large], :style => :bold, :color => custom_color[:dark_blue]
    text member.title, color: custom_color[:grey] if member.title.present?

    move_down 30


    # Table for details
    rows = []

    # Bio
    rows << [ "Bio", member.bio ] if member.bio.present?

    # Educations
    if member.educations.present?
      member.educations.each_with_index do |education, i|
        next if education.institution_name.blank?

        a = []
        a << education.institution_name
        a << education.field_of_study if education.field_of_study.present?
        # a << education.description if education.description.present?
        a << "#{education.from_year} - #{education.still_studies_here ? "present" : education.to_year}" if education.from_year.present?

        b = a.join("\n")
        if i == 0
          rows << [ "Educations", b ]
        else
          rows << [ "", b ]
        end
      end
    end

    # Employments
    if member.employments.present?
      member.employments.each_with_index do |employment, i|
        next if employment.company_name.blank?

        a = []
        a << employment.company_name
        a << employment.job_title if employment.job_title.present?
        # a << employment.description if employment.description.present?
        a << "#{employment.from_year} - #{employment.still_works_here ? "present" : employment.to_year}" if employment.from_year.present?

        b = a.join("\n")
        if i == 0
          rows << [ "Experiences", b ]
        else
          rows << [ "", b ]
        end

      end
    end

    # Skills
    if member.skill_with_ratings.present?
      @a = []
      member.skill_with_ratings.each_with_index do |skill, i|
        @a << skill[:name]
      end
      b = @a.join(", ")
      rows << [ "Skills", b ]
    end

    # Languages
    if member.prefered_languages.present?
      @a = []
      member.prefered_languages.each do |pl|
        @a << pl.name
      end
      b = @a.join(", ")
      rows << [ "Languages", b ]
    end

    # Create table
    if rows.count > 0
      table rows, column_widths: {0 => 170, 1 => 360} do

        cells.border_width = 0

        rows.each_with_index do |r, i|

          row(i).border_top_width = 0.3
          row(i).border_color = custom_color[:light_blue]
          
          if r[0] != ""
            row(i).columns(0).text_color = custom_color[:light_blue]
            row(i).columns(0).size = custom_font[:medium]
          else
            row(i).column(0).border_top_width = 0
          end

          row(i).padding_top = 9
          row(i).padding_bottom = 9
          row(i).padding_left = 0
          row(i).padding_right = 0
        end
      end
    end

    # Sign
    # move_down 100
    # text "Generated by:", size: custom_font[:small], color: custom_color[:grey]
    # move_down 10
    # logo =  (Rails.env.development?) ? "#{Rails.root.to_s}/app/assets/images/logo-email.png" : "https://sribulancer-production-sg.s3.amazonaws.com/assets/media/images/logo-email.png"
    # image open(logo), :width => 100

  end  
end