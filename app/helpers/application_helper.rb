module ApplicationHelper
  include ActionView::Helpers::NumberHelper
  def as_pct(val, significant_digits=1)
    if val.nil?
      "n/a %"
    else
      number_to_percentage(val * 100, :precision=>significant_digits)
    end
  end
  
  def pretty_dt(val)
    if val
      val.strftime("%Y-%m-%d")
    else
      ''
    end   
  end
  
  def pretty_num(val, significant_digits=1)
    if val.nil?
      "n/a"
    else
      number_with_precision(val, :precision => significant_digits, :delimiter => ',')
    end
  end
  
  def pretty_int(val)
    pretty_num(val, 0)
  end

  def pretty_or_zero(val)
    if val.nil?
      "n/a"
    elsif val < 0
      "0"
    else
      pretty_num(val)
    end
  end
  
  def tags_tag(name, current_values)
    #TODO: switch out with the tags widget that came with flat ui
    prefilled = current_values.collect{|t| "\"#{t.tag}\""}.join(',')
    
    html = "<input id=\"tags-#{name}\" type=\"text\" name=\"visible-#{name}\" placeholder=\"Tags\" class=\"tm-input form-control\"/>
      <script type=\"application/javascript\">
        $(document).ready(function() {
          $(\"#tags-#{name}\").tagsManager({
            prefilled: [#{prefilled}],
            name: 'visible-#{name}',
            hiddenTagListName: '#{name}',
            tagClass: ''
          });});
      </script>"
    html.html_safe
  end


end
