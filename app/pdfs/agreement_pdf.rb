class AgreementPdf < Prawn::Document
  
  def initialize(params ={})
    super(:top_margin => 25)
    font_type = {:font_big => 23, :font_medium => 13, :font_small => 8.5}
    
    render_for_paragraph1(font_type)
    
    render_for_paragraph2(font_type)
    
    render_for_paragraph3(font_type)
    
    render_for_paragraph4(font_type, params)
  end
  
  
  
  
  private
  def render_for_paragraph1(font)    
    doc_title = "Copyright Agreement"
    
    title1      = I18n.t("agreement_document.title1")
    content1a   = I18n.t("agreement_document.content1a")
    content1b   = I18n.t("agreement_document.content1b")
    content1c   = I18n.t("agreement_document.content1c")
    
    font_big      = font[:font_big]
    font_medium   = font[:font_medium]
    font_small    = font[:font_small]
    
    cell :content => doc_title, 
          :background_color => 'ABABAB', 
          :width => 540, :height => 30, 
          :align => :center, :text_color => "FFFFFF",
          :size => 18
    
    move_down 50
    text title1, :align => :left, :size => font_medium
    
    move_down 5
    text content1a, :align => :left, :size => font_small, :inline_format => true
    
    move_down 5
    text content1b, :align => :left, :size => font_small
    
    move_down 5
    text content1c, :align => :left, :size => font_small
  end
  
  def render_for_paragraph2(font)
    
    title2    = I18n.t("agreement_document.title2")
    content2a = I18n.t("agreement_document.content2a")
    content2b = I18n.t("agreement_document.content2b")
    content2c = I18n.t("agreement_document.content2c")
    content2d = I18n.t("agreement_document.content2d")
    
    
    font_big      = font[:font_big]
    font_medium   = font[:font_medium]
    font_small    = font[:font_small]
    
    move_down 10
    text title2, :align => :left, :size => font_small
    
    move_down 5
    indent(20) do
      text content2a, :align => :left, :size => font_small, :inline_format => true
    end
    
    move_down 5
    indent(20) do
      text content2b, :align => :left, :size => font_small
    end
    
    move_down 5
    indent(20) do
      text content2c, :align => :left, :size => font_small, :inline_format => true
    end
    
    move_down 5
    indent(20) do
      text content2d, :align => :left, :size => font_small
    end
  end
  
  def render_for_paragraph3(font)
    title3    = I18n.t("agreement_document.title3")
    content3a = I18n.t("agreement_document.content3a")
    content3b = I18n.t("agreement_document.content3b")
    content3c = I18n.t("agreement_document.content3c")
    content3d = I18n.t("agreement_document.content3d")   
    content3e = I18n.t("agreement_document.content3e")
    content3f = I18n.t("agreement_document.content3f")    
    content3g = I18n.t("agreement_document.content3g")
    
    content3h = I18n.t("agreement_document.content3h")
    content3i = I18n.t("agreement_document.content3i")
    content3j = I18n.t("agreement_document.content3j")
    content3k = I18n.t("agreement_document.content3k")
    content3l = I18n.t("agreement_document.content3l")
    content3m = I18n.t("agreement_document.content3m")
    content3n = I18n.t("agreement_document.content3n")
    content3o = I18n.t("agreement_document.content3o")
    content3p = I18n.t("agreement_document.content3p")
    content3q = I18n.t("agreement_document.content3q")
    content3r = I18n.t("agreement_document.content3r")
    content3s = I18n.t("agreement_document.content3s")
    content3t = I18n.t("agreement_document.content3t")
    content3u = I18n.t("agreement_document.content3u")
    content3v = I18n.t("agreement_document.content3v")
               
    
    font_big      = font[:font_big]
    font_medium   = font[:font_medium]
    font_small    = font[:font_small]
    
    move_down 10
    text title3, :align => :left, :size => font_small
    
    move_down 5
    text content3a, :align => :left, :size => font_small
    
    move_down 5
    text content3b, :align => :left, :size => font_small
    
    move_down 5
    text content3c, :align => :left, :size => font_small
    
    move_down 5
    text content3d, :align => :left, :size => font_small    
    
    move_down 5
    text content3e, :align => :left, :size => font_small
    
    move_down 5
    text content3f, :align => :left, :size => font_small
    
    move_down 5
    text content3g, :align => :left, :size => font_small    
    
    move_down 5
    text content3h, :align => :left, :size => font_small
    
    move_down 5
    text content3i, :align => :left, :size => font_small
    
    move_down 5
    text content3j, :align => :left, :size => font_small
    
    move_down 5
    text content3k, :align => :left, :size => font_small
    
    move_down 5
    text content3l, :align => :left, :size => font_small
    
    move_down 5
    text content3m, :align => :left, :size => font_small
    
    move_down 5
    text content3n, :align => :left, :size => font_small
    
    move_down 5
    text content3o, :align => :left, :size => font_small
    
    move_down 5
    text content3p, :align => :left, :size => font_small
    
    move_down 5
    text content3q, :align => :left, :size => font_small
    
    move_down 5
    text content3r, :align => :left, :size => font_small
    
    move_down 5
    text content3s, :align => :left, :size => font_small
    
    move_down 5
    text content3t, :align => :left, :size => font_small
    
    move_down 5
    text content3u, :align => :left, :size => font_small
    
    move_down 5
    text content3v, :align => :left, :size => font_small
  end
  
  def render_for_paragraph4(font, params)
    agreement = params[:agreement]
    
    winner_name   = agreement.info_winner_name.present? ? agreement.info_winner_name : agreement.winner.member.username 
    winner_notelp = agreement.info_winner_notelp.present? ? agreement.info_winner_notelp : agreement.winner.member.phone_books.first.present? ? agreement.winner.member.phone_books.first.mobile_phone_number : "-"
    winner_email  = agreement.info_winner_email.present? ? agreement.info_winner_email : agreement.winner.member.email
    
    title4      = I18n.t("agreement_document.title4")  
    
    title4a     = I18n.t("agreement_document.title4a", :contract_no => params[:contract_no])
    content4a   = I18n.t("agreement_document.content4a", :created_date => params[:created_date])
    
    title4b     = I18n.t("agreement_document.title4b") 
    content4b1  = I18n.t("agreement_document.content4b1", :designer => winner_name)
    content4b2  = I18n.t("agreement_document.content4b2", :address => agreement.info_winner_address)
    
    client_company_name = agreement.info_client_company_name.present? ? agreement.info_client_company_name : agreement.winner.contest.contest_owner.company
    client_holder = agreement.info_client_holder.present? ? agreement.info_client_holder : agreement.winner.contest.contest_owner.username
    client_notelp = agreement.info_client_notelp.present? ? agreement.info_client_notelp : ""
    client_email = agreement.info_client_email.present? ? agreement.info_client_email : agreement.winner.contest.contest_owner.email
    
    title4c     = I18n.t("agreement_document.title4c") 
    content4c1  = I18n.t("agreement_document.content4c1", :company => client_company_name)
    content4c2  = I18n.t("agreement_document.content4c2", :address => agreement.info_client_address)
    content4c3  = I18n.t("agreement_document.content4c3", :business_type => agreement.info_client_business_type)
    content4c4  = I18n.t("agreement_document.content4c4", :holder => client_holder)
    content4c5  = I18n.t("agreement_document.content4c5", :idcard => agreement.info_client_idcard)
      

    font_medium   = font[:font_medium]
    font_small    = font[:font_small]
    
    move_down 15
    text title4, :align => :left, :size => font_small
    
    
    
    move_down 5
    text title4a, :align => :left, :size => font_small, :inline_format => true
    
    move_down 5
    text content4a, :align => :left, :size => font_small, :inline_format => true
    
    move_down 15
    text title4b, :align => :left, :size => font_medium, :inline_format => true
    
    move_down 5
    indent(20) do
      move_down 5
      text content4b1, :align => :left, :size => font_small, :inline_format => true
      move_down 5
      text content4b2, :align => :left, :size => font_small, :inline_format => true
    end
    
    move_down 10
    text title4c, :align => :left, :size => font_medium, :inline_format => true
    
    move_down 5
    indent(20) do
      move_down 5
      text content4c1, :align => :left, :size => font_small, :inline_format => true
      move_down 5
      text content4c2, :align => :left, :size => font_small, :inline_format => true
      move_down 5
      text content4c3, :align => :left, :size => font_small, :inline_format => true
      move_down 5
      text content4c4, :align => :left, :size => font_small, :inline_format => true
      move_down 5
      text content4c5, :align => :left, :size => font_small, :inline_format => true
    end

  end
  
end

