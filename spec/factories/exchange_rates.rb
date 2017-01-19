FactoryGirl.define do
  factory :exchange_rate do
    quoted_at DateTime.new
    as_of_dt Date.new
    base_currency "USD"
    quote_currency "EUR"
    mid_rate 11.234546
  end
end