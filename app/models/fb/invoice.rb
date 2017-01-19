module Fb

  #Invoice Fields come from the Freshbooks API
  #http://developers.freshbooks.com/docs/invoices/#invoice.get
  class Invoice

    attr_accessor :client, :from, :due_date, :invoice_hash
    
    def initialize(invoice_hash = {}, client = {}, from = {}, due_date_terms = {})
      @invoice_hash = invoice_hash
      @invoice_hash.keys.each do |key|
        self.class.send(:define_method, key) do
          return @invoice_hash[key]
        end
        self.class.send(:define_method, "#{key}=") do |val|
          @invoice_hash[key] = val
        end
      end
      @client = client
      @from = from
      @due_date_terms = due_date_terms
      @due_date = nil
    end

    def [](key)
      return @invoice_hash[key]
    end

    def []=(key, value)
      @invoice_hash[key] = value
    end

    def client_view()
      return @invoice_hash["links"]["client_view"]
    end
    
  end
end

