
class Batch::Nightly
  def perform()
    begin
      do_perform
    rescue => e
      SupportHelper.on_exception "NIGHTLY BATCH FAILED!!!!  #{e.message}", e
    end
  end
  
  def do_perform
    Rails.logger.info "Starting nightly batch job"
    Batch::LoadExchangeRatesJob.enqueue_range(5.days.ago, Date.current)
    Fb::RefreshAllClientsJob.enqueue(119)
    
    Rails.logger.info "Finished nightly batch job"
    
  end
  
