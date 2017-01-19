class Infrastructure::Alerting

  SOURCE_XEROX = 100
  SOURCE_RECURLY = 300
  
  LEVEL_INFO = 100
  LEVEL_WARN = 200
  LEVEL_SEVERE = 300
  
  class << self
    def raise_alert(user_id, source, level, message)
      Alert.create(:user_id => user_id, :source => source, :level => level, :message => message)
    end
  end
end
