module FeaturevizLegacyHelper
  def action_links(an_obj)
    if (an_obj.class == User && an_obj.login == 'admin') 
        "<td class='action-button'>#{show_link an_obj}</td><td class='action-button'>#{edit_link(an_obj)}</td><td class='action-button'></td>".html_safe
      else 
        "<td class='action-button'>#{show_link an_obj}</td><td class='action-button'>#{edit_link(an_obj)}</td><td class='action-button'>#{remove_link an_obj}</td>".html_safe
    end
  end
  
  def action_headers()
      "<th></th><th></th><th></th>".html_safe
  end

  def ajax_button(text, busy_text, id, stuff=Hash.new)
    real_params = stuff.merge({:id=>id, :class=>'btn',:disble_with => busy_text})
    submit_tag text, real_params
  end
  
  # see: https://github.com/rails/jquery-ujs/wiki/ajax
  def ajax_json_button_binding(form_id, success_function_name, error_function_name)
    "<script type=\"text/javascript\">
      $('##{form_id}').bind('ajax:success', function(evt, data, status, xhr){
          #{success_function_name}(jQuery.parseJSON(xhr.responseText));          
      });
      $('##{form_id}').bind('ajax:error', function(){
          #{error_function_name}();
      });
      $('##{form_id}').bind('ajax:before', function() {
        $('##{form_id} .btn').addClass('submitted-button');
      });
    </script>".html_safe
    #TODO: check response code for a 500 and send to error function instead of success function

  end

  def ajax_html_button_binding(form_id, results_div_id, error_function_name)
    "<script type=\"text/javascript\">
      $('##{form_id}').bind('ajax:success', function(evt, data, status, xhr){
          $('##{results_div_id}').html(xhr.responseText);          
      });
      $('##{form_id}').bind('ajax:error', function(){
          #{error_function_name}();
      });
    </script>".html_safe
    
  end
    
  def search_button()
    image_submit_tag "icons/001_38.png", :height => "20px;", :style => "padding:0px;margin-bottom:-4px;margin-left:-3px;"
  end
  
def show_link(an_obj, url=nil)
  url = url_for(an_obj) if url.nil?
  link_to image_tag("icons/001_60.png"), url, :action=>:show
end

def edit_link(an_obj, url=nil)
  url = url_for(an_obj) + "/edit" if url.nil?
  link_to image_tag("icons/001_45.png"), url
end

def remove_link(an_obj, url=nil)
  url = url_for(an_obj) if url.nil?
  link_to image_tag("icons/001_49.png"), url, :confirm => 'Are you sure?', :method => :delete
end
  
end