
class Batch::Hourly
  def perform()
    Rails.logger.info "Starting hourly batch job"
    
    Rails.logger.info "Finished hourly batch job"
  end
end