

function alertPoll(first, period){
    var url = "/alerts/notifications";
    setTimeout(function(){
        $.ajax({ url: url, success: function(data){
            handleAlertsUpdate(data);
            //Setup the next poll recursively
            alertPoll(period, period);
        }, dataType: "html"});
    }, first);
}

function handleAlertsUpdate(alertArrayHTML) {
    var severeCount = $(alertArrayHTML).find(".level_300").length
    if (severeCount > 0) {
        $("#numberOfAlerts").addClass("has-severe");
    } 
    else {
        $("#numberOfAlerts").removeClass("has-severe");
    }
    $("#alerts-dropdown").html(alertArrayHTML);
    var newAlertCount = $("#alerts-dropdown li").length;
    $("#numberOfAlerts").html(newAlertCount);
}

function acknowledgeAlert(id) {
  var row_selector = "#alert-" + id;
  var url = "/alerts/" + id + "/acknowledge";	
 $.ajax({url: url,
            type: "POST",   
            dataType: 'json',
            success: function(result){
                if (result.acknowledged) {
                    $(row_selector).alert('close');
                } 
            },
            error: function() {
                alert("Error trying to acknowledge alert, please try again.");
            }
           });
   return false;
}


$(document).ready(function(){
    alertPoll(1, 150000);
    $("#alerts a").click(function() {
        $("#alerts ul.subnav").toggle();
    });
});

