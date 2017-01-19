

class Fb::RevenueByStaffController < Fb::FbController
  
  def set_title
    @title = "FreshBooks: Revenue By Staff"
  end
  
  def index
    user = current_user
    api = Fb::Api.new(user.account_for('fb'))
    @invoices = api.fb_paid_invoices_by_date_range
    @revenue_by_staff = summarize_by_staff @invoices
    staff = api.fb_staff()
    @staff = to_map_by('staff_id', staff)
    
    respond_to do |format|
      format.html
    end
  end
  
  def summarize_by_staff(invoices)
    rv = {}
    @invoices.each do |invoice|
      invoice['lines'].each do |line|
        amt = line['amount'].to_f
        # expecting the invoice line to look like:  "[Task Name yyyy-mm-dd] FirstName LastName: description"
        possible_match = line['description'].match /\[\.?\]([A-Za-z]*) ([A-Za-z]*):?/
      end
    end
  end
end