// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery_ujs
//= require dashboard
//= require graphs
//= require alerts
//= require signin
//= require bootstrap-sortable.js
//= require moment.min.js

    
toggleExplanation = function() {
	$('.explanation').toggle();
};

function isFunction(possibleFunction) {
  return (typeof(possibleFunction) == typeof(Function));
}

function isNumber(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}

function isEmpty(n) {
	return (!n || typeof(n) == 'undefined' || n.length < 1);		
}

userAlert = function(cssClass, contents){
	outerContents = "<div class=\"alert " + cssClass + " alert-dismissable\">  <button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-hidden=\"true\">&times;</button>" + contents + "</div>";
	$("#message-center").append(outerContents);
	$('#message-center').show();
 $("html, body").animate({ scrollTop: 0 }, "slow");
};

userError = function(contents) {
	userAlert('alert-error', contents);
};

userSuccess = function(contents) {
	userAlert('alert-success', contents);
};

inputHasError = function(inputName) {	
	$('input[name="' + inputName + '"]').parent().addClass('has-error');
};

clearInputErrors = function() {
	$('#message-center').html("");
	$('input').parent().removeClass('has-error');
};
		

if (typeof String.prototype.endsWith !== 'function') {
    String.prototype.endsWith = function(suffix) {
        return this.indexOf(suffix, this.length - suffix.length) !== -1;
    };
}

$(document).ajaxStart(function () { $(this).addClass("wait"); });
$(document).ajaxSend(function(event,xhr,options) { trackPageview(options.url) });
$(document).ajaxStop(function () { $(this).removeClass("wait"); });
$(document).ajaxError(function(event, xhr,options,exception) {trackEvent('Error','Ajax',options.url)});

$(document).ready(function () {
	$('.btn').click(function() {
		try { 
		   trackEvent('Button',$(this).prop('href'));
		 } catch (err){
		 	log("problem with button tracking: " + err.message);
		 }
	});
});

String.prototype.capitalize = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
};

window.log = function(){
  if(this.console){
    console.log( Array.prototype.slice.call(arguments) );
  }
};

function trackUser(user_id_int, user_id_str, plan_bucket, email, org_created_at) {
	if (doTracking){
		plan_bucket = typeof plan_bucket !== 'undefined' ? plan_bucket : null;
		email = typeof email !== 'undefined' ? email : null;
		try {
		  ga('require','displayfeatures');
		  ga('create', 'UA-16297310-9', 'auto');
			ga('set', 'dimension1', plan_bucket);//this is the user's plan
			ga('set', 'dimension2', user_id_str);//this is the user's id
			ga('set', '&uid', user_id_int); // Set the user ID using signed-in user_id.
		 } catch (err){
		 	log("problem with google analytics tracking: " + err.message);
		 }
		try {
			if (this._retf){
				_retf.push(['identifyVisitor',user_id_str,email,org_created_at,{plan_bucket: plan_bucket}]);
				ga(function(tracker) {
				  var ga_user_id = tracker.get('clientId');
				  _retf.push(['identifyVisitor',ga_user_id,email,org_created_at,{user_id_source: 'GA'}]);
				});
			}
		} catch (err) {
		 	log("problem with _retf tracking: " + err.message);
		}
	}
 	
}

function trackEvent(category, action, value) {
	if (doTracking){
		value = typeof value !== 'undefined' ? value : null;
		try {
			ga('send','event',category, action, value);
		 } catch (err){
		 	log("problem with google analytics tracking: " + err.message);
		 }
		try {
			if (this._retf){
				_retf.push(['trackEvent',category,action,'no name',value]);
			}
		} catch (err) {
		 	log("problem with _retf tracking: " + err.message);
		}
	}
}

function trackPageview(url) {
	if (doTracking){
		try {
			if(this._gaq){
				_gaq.push(['_trackPageview',url]);
			}
			ga('send','pageview',url);
		 } catch (err){
		 	log("problem with google analytics tracking: " + err.message);
		 }
		try {
			if (this._retf){
				_retf.push(['trackPageView',url]);
			}
		} catch (err) {
		 	log("problem with _retf tracking: " + err.message);
		}
	}
}

function async_remove(url, row_selector) {
    $(row_selector).addClass("row-in-progress");
    $.ajax({url: url,
            type: "POST",   
            dataType: 'json',
            success: function(result){
                $(row_selector).removeClass("row-in-progress")
                if (result.acknowledged) {
                    $(row_selector).remove();
                } 
            },
            error: function() {
                $(row_selector).removeClass("row-in-progress")
                alert("Error trying to remove");
            }
           });
}

