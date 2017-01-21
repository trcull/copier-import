require 'aws-sdk'

#see: http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/S3.html
#see: http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/S3/ObjectCollection.html
class Infrastructure::DocStore
  class << self
    @root_directory = '/tmp'
    def boot_up
        @root_directory = ENV['DOCSTORE_ROOT_DIRECTORY'] || '/tmp'
        puts "USING DOCSTORE ROOT DIRECTORY #{@root_directory}"
    end
    
    def connected?
      true
    end
    
    def disconnect
      #noop
    end
        
    def calculate_file_path(key)
      file_path = "#{@root_directory}/#{key.gsub("/",".")}"
    end
    
    def add_or_update(key, value, content_type=nil, make_public=false)
      file_path = calculate_file_path(key)
      File.open(file_path, "w") do |f|
        f.puts(value)
      end
      value
    end

    def get_value(key)
      file_path = calculate_file_path(key)
      IO.read(file_path)
    end
    
    def get_file(key)
      rv = get_value(key)
      yield rv
      rv
    end


  end
end

#This is here mostly because in development mode every time a controller is changed then this class is reloaded, which makes @config null
Infrastructure::DocStore.boot_up
