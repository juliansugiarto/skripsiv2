class JobOrderInvoicePdf < Prawn::Document
  
  def initialize(params ={})
    super(:top_margin => 25)
    font_type = {:font_big => 23, :font_medium => 12, :font_small => 9}
    jo = JobOrder.find params[:id]
    render_content(font_type, jo)

  end
    
  private
  
  def render_content(font, jo)
    logo =  (Rails.env.development?) ? "#{Rails.root.to_s}/app/assets/images/logo-email.png" : "https://sribulancer-production-sg.s3.amazonaws.com/assets/media/images/logo-email.png"
    image open(logo), :width => 100
    move_down 15


    rows = [] # Table dengan 4 kolom
    rows << ["", "Tagihan", "", ""]
    rows << ["","Freelancer: #{jo.freelancer.name}", "Tanggal: #{jo.created_at.strftime('%d %b %Y')}",""]
    rows << ["","Employer: #{jo.employer.name}", "Nomor Tagihan: #{jo.invoice_number}",""]
    rows << ["","Particulars", "Jumlah",""]
    rows << ["",jo.job.title , jo.budget_display, ""]
    if jo.promotion.present?
      promotion = Promotion.find(jo.promotion)
      rows << ["","Discount", "#{jo.currency.code} #{promotion.voucher_value_display(jo)}",""]
    end
    rows << ["","Kode Bayar", jo.payment_code_display, ""]
    rows << ["","Total", jo.total_cost_display,""]

    table rows, column_widths: {0 => 10, 1 => 330, 2 => 180, 3 => 10} do

      # Font Style

      row(0).font_style = :bold
      row(0).columns(1).size = font[:font_big]
      row(3).font_style = :bold
      row(6).font_style = :bold


      # Alignment Cell

      row(6).columns(1).align = :right


      # Padding

      (0..6).each do |r|
        row(r).padding = 9
      end

      row(2).columns(1).padding_bottom = 20

      # Styling Table

      cells.border_width = 0

      row(0).border_top_width = 1
      row(0).border_color = "bbbbbb"
      row(-1).border_bottom_width = 1
      row(-1).border_color = "bbbbbb"
      columns(0).border_left_width = 1
      columns(0).border_color = "bbbbbb"
      columns(-1).border_right_width = 1
      columns(-1).border_color = "bbbbbb"

      (3..5).each do |x|
        row(x).border_top_width = 1
        row(x).border_color = "bbbbbb"

        row(x).columns(0).border_top_width = 0
        row(x).columns(3).border_top_width = 0
      end
    end

    rows_bank = [] #table with 1 column
    rows_bank << ["- Bank BCA. Account Number : #{StaticData::BCA_ACCOUNT_NO}. Account Name : PT Sribu Digital Kreatif"]
    rows_bank << ["- Bank Mandiri. Account Number : #{StaticData::MANDIRI_ACCOUNT_NO}. Account Name : PT Sribu Digital Kreatif"]

    table rows_bank, column_widths: { 0 => 450} do
      row(0).columns(0).padding_top = 30
      (0..1).each do |x|
        row(x).border_left_width = 0
        row(x).border_top_width = 0
        row(x).border_bottom_width = 0
        row(x).border_right_width = 0
        row(x).columns(0).size = font[:font_small]
      end
    end 

    create_stamp("paid") do
      rotate(-30, :origin => [-5, -5]) do
        stroke_color "FF3333"
        stroke_ellipse [0, 0], 29, 15
        stroke_color "000000"
        fill_color "993333"
        font("Times-Roman") do
          draw_text "PAID", :at => [-23, -3]
        end
        fill_color "000000"
      end
    end
    
    stamp_at "paid", [480, 680] if jo.order_status_id == OrderStatus.get_paid.id

  end  
end