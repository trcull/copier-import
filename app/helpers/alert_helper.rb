module AlertHelper
  def level_class(alert)
    value = alert.level
    rv = ""
    if value <= Infrastructure::Alerting::LEVEL_INFO
      rv = "alert-info" 
    elsif value <= Infrastructure::Alerting::LEVEL_WARN
      rv= "alert-warning"
    else #severe
      rv= "alert-danger"
    end
    rv.html_safe
  end

end

