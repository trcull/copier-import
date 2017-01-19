
class PhoneNumberValidator < ActiveModel::Validator
  def validate(record)
    options[:fields].each do |field| 
      value = record.send(field)
      if false
        record.errors.add field, "#{field} is not a phone number: #{value}"
      end  
    end    
  end
end