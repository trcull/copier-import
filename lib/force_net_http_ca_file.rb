module Net
  class HTTP 
    alias :original_initialize :initialize
    
    def initialize(address, port = nil)
      original_initialize(address, port)
      @ca_file = ENV['SSL_CERT_FILE']
    end
    
  end
end
