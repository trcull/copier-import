require 'oauth'
#note: this explicit require must be here or else oauth says PLAINTEXT is not a valid signature method
require 'oauth/signature/plaintext'

class Infrastructure::Oauth < OAuth::Consumer
  def initialize(key, secret, options = Hash.new)
    super(key, secret, options)
    http.set_debug_output($stdout) 
  end
  
end

# This requires some explanation.  Under some circumstances, the OAuth::Consumer creates a new HTTP object immediately before sending
#  requests.  This means if you want to see debugging information or set client-side SSL certificates then you're screwed.  What
#  this mixin does is decorate the OAuth::Consumer.create_http method with our own method.  First, we call the old create_http
#  method and then we set the debug output and the cert.
module OAuth
  class Consumer
    def create_http_with_featureviz(*args)
      @http ||= create_http_without_featureviz(*args).tap do |http|
        begin
          http.set_debug_output($stdout) unless options[:supress_debugging]
          #Used first by Xero, which requires client-side ssl certificates for every request.
          http.cert = OpenSSL::X509::Certificate.new(options[:ssl_client_cert]) if options[:ssl_client_cert]
          http.key  = OpenSSL::PKey::RSA.new( options[:ssl_client_key]) if options[:ssl_client_key]
          #http.cert = OpenSSL::X509::Certificate.new( File.read('ssl-cert/entrust-cert.pem') )
          #http.key = OpenSSL::PKey::RSA.new( File.read('ssl-cert/entrust-private-nopass.pem') )   
        rescue => e
          puts "error trying to add client ssl certificates #{e.message}"
        end
      end
    end
    alias_method_chain :create_http, :featureviz
  end
end

module OAuth::Signature::RSA
  class SHA1 < OAuth::Signature::Base
    def digest
      private_key = OpenSSL::PKey::RSA.new(
        if options[:private_key_str]
          options[:private_key_str]
        elsif options[:private_key_file]
          IO.read(options[:private_key_file])
        else
          consumer_secret
        end
      )

      private_key.sign(OpenSSL::Digest::SHA1.new, signature_base_string)
    end  
  end
end
