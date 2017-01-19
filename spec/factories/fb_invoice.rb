# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :fb_invoice , :class=>Fb::Invoice do
    ignore do
      client {FactoryGirl.create(:fb_client)}
      client_id { client.fb_id}

      invoice_id {Forgery(:basic).text()}
      date '2012-08-01'
      status 'unpaid'
      
      fb_invoice {{"organization"=>'my org', "invoice_id" => invoice_id, "date" => date, "number" => "12345", "client_id" => client_id, "status"=>status}}

    end
    initialize_with { Fb::Invoice.new(fb_invoice, client) }

  end
end
