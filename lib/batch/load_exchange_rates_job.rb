
class Batch::LoadExchangeRatesJob
  
  def self.enqueue_range(start_dt, end_dt)
    start_dt.to_date.upto(end_dt.to_date) do |dt|
      Batch::LoadExchangeRatesJob.enqueue dt
    end  
  end
  
  def self.enqueue(dt)
    Batch::LoadExchangeRatesJob.new.delay(priority: PRIORITY_DEFAULT).safe_perform(dt)  
  end
  
  def safe_perform(dt)
    begin
      self.perform(dt)
    rescue => e
      SupportHelper.on_exception "ERROR trying to #{self.class.name} : #{e.message}", e
    end
  end
  
  def perform(dt)
    Rails.logger.info "Doing #{self.class.name} for date #{dt}"
    rates_json = download_rates(dt)
    rates = parse_rates(rates_json, dt)
    as_of_dt = load_rates(dt, rates)
    Rails.logger.info "Done doing #{self.class.name} "
  end
  
  def load_rates(as_of_date, rates)
    base_currency = rates[:base]
    quote_date = Time.at(rates[:timestamp])
    rates[:rates].each_pair do |currency, rate|
      fx = ExchangeRate.where(as_of_dt: as_of_date, base_currency: base_currency, quote_currency: currency).first_or_initialize 
      fx.mid_rate = rate
      fx.quoted_at = quote_date
      fx.save!
    end
  end
  
  #see: https://openexchangerates.org/quick-start 
  # see: spec/fixtures/exchange_rates/2013-01-01.json for example of format 
  def download_rates(as_of_date)
    date_str = as_of_date.strftime "%Y-%m-%d"
    url = "http://openexchangerates.org/api/historical/#{date_str}.json?app_id=51b534fba001480d989ae03c571a7166"
    request = Net::HTTP::Get.new(url)
    net = Net::HTTP.new("openexchangerates.org", 80)
    net.use_ssl = false
    net.set_debug_output STDOUT 
    net.read_timeout = 3
    net.open_timeout = 3
    response = net.start do |http|
      http.request(request)
    end
    response.body
  end

  def parse_rates(rates_json, dt)
    rates = JSON.parse(rates_json, {symbolize_names: true})
    if (rates[:error] && rates[:error] == true) || (rates[:status] && rates[:status] == 400)
      raise "No rates found for date #{dt}"
    end
    rates
  end
  
  #see: http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml?time=2014-11-30
  def download_rates_from_ecb
    "<gesmes:Envelope xmlns:gesmes=\"http://www.gesmes.org/xml/2002-08-01\" xmlns=\"http://www.ecb.int/vocabulary/2002-08-01/eurofxref\">
      <gesmes:subject>Reference rates</gesmes:subject>
      <gesmes:Sender>
      <gesmes:name>European Central Bank</gesmes:name>
      </gesmes:Sender>
      <Cube>
      <Cube time=\"2014-12-05\">
      <Cube currency=\"USD\" rate=\"1.2362\"/>
      <Cube currency=\"JPY\" rate=\"149.03\"/>
      <Cube currency=\"BGN\" rate=\"1.9558\"/>
      <Cube currency=\"CZK\" rate=\"27.635\"/>
      <Cube currency=\"DKK\" rate=\"7.4399\"/>
      <Cube currency=\"GBP\" rate=\"0.78810\"/>
      <Cube currency=\"HUF\" rate=\"307.25\"/>
      <Cube currency=\"LTL\" rate=\"3.4528\"/>
      <Cube currency=\"PLN\" rate=\"4.1628\"/>
      <Cube currency=\"RON\" rate=\"4.4321\"/>
      <Cube currency=\"SEK\" rate=\"9.2990\"/>
      <Cube currency=\"CHF\" rate=\"1.2021\"/>
      <Cube currency=\"NOK\" rate=\"8.8105\"/>
      <Cube currency=\"HRK\" rate=\"7.6740\"/>
      <Cube currency=\"RUB\" rate=\"66.3305\"/>
      <Cube currency=\"TRY\" rate=\"2.7660\"/>
      <Cube currency=\"AUD\" rate=\"1.4765\"/>
      <Cube currency=\"BRL\" rate=\"3.1832\"/>
      <Cube currency=\"CAD\" rate=\"1.4085\"/>
      <Cube currency=\"CNY\" rate=\"7.6055\"/>
      <Cube currency=\"HKD\" rate=\"9.5823\"/>
      <Cube currency=\"IDR\" rate=\"15220.71\"/>
      <Cube currency=\"ILS\" rate=\"4.8945\"/>
      <Cube currency=\"INR\" rate=\"76.3786\"/>
      <Cube currency=\"KRW\" rate=\"1377.79\"/>
      <Cube currency=\"MXN\" rate=\"17.4990\"/>
      <Cube currency=\"MYR\" rate=\"4.2911\"/>
      <Cube currency=\"NZD\" rate=\"1.5928\"/>
      <Cube currency=\"PHP\" rate=\"55.123\"/>
      <Cube currency=\"SGD\" rate=\"1.6293\"/>
      <Cube currency=\"THB\" rate=\"40.717\"/>
      <Cube currency=\"ZAR\" rate=\"13.8773\"/>
      </Cube>
      </Cube>
      </gesmes:Envelope>"
  end
end