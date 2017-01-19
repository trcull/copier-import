require 'aws-sdk'

#see: http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/S3.html
#see: http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/S3/ObjectCollection.html
class Infrastructure::DocStore
  class << self
    def boot_up
      unless connected?
        @key_id = ENV['DOCSTORE_ACCESS_KEY_ID']
        raise "DOCSTORE_ACCESS_KEY_ID not set" if @key_id.nil? || @key_id.length < 1
        @key = ENV['DOCSTORE_SECRET_ACCESS_KEY']
        raise "DOCSTORE_SECRET_ACCESS_KEY not set" if @key.nil? || @key.length < 1
        @bucket = ENV['DOCSTORE_BASE_BUCKET'] || "rf-docs-#{Rails.env}"
        puts "USING S3 BUCKET: #{@bucket}"
        AWS.config(
          :access_key_id => @key_id,
          :secret_access_key => @key)
      end
    end
    
    def connected?
      @connection.present?
    end
    
    def disconnect
      @connection = nil
    end
    
    def connection 
      if !connected?
        #boot_up #workers won't have done this already
        @connection = AWS::S3.new
        target_bucket = @connection.buckets[@bucket]
        if target_bucket.nil? || !target_bucket.exists?
          msg = "Creating S3 bucket named #{@bucket}"
          Rails.logger.info msg
          bucket = @connection.buckets.create(@bucket)
        end
      end
      @connection
    end
    
    def add_or_update(key, value, content_type=nil, make_public=false)
      content_type ||= 'application/octet-stream'
      options = {:content_type=>content_type}
      bucket = _get_bucket
      obj = bucket.objects.create(key, value, options)      
      obj.acl = :public_read if make_public
      obj
    end

    def get_value(key)
      _get_bucket().objects[key].read  
    end
    
    def get_file(key)
      _get_bucket().objects[key].read do |chunk|
        yield chunk
      end  
    end

    def sign_cors_post(key)
      bucket = _get_bucket()
      rv = bucket.presigned_post(key: key, success_action_status: 201, acl: :public_read)
      rv
    end
    
    #meant to be private
    def _get_bucket
      connection.buckets[@bucket]  
    end
    

  end
end

#This is here mostly because in development mode every time a controller is changed then this class is reloaded, which makes @config null
Infrastructure::DocStore.boot_up
