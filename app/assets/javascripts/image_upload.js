

imageChangeClicked = function(field_name) {
	$('#' + field_name + '-image-button-row').show();
	$('#' + field_name + '-image-input-field-row').hide();
	$('#' + field_name + '-image-upload-row').hide();
};

imageUploadCancelClicked = function(field_name) {
	$('#' + field_name + '-image-button-row').show();
	$('#' + field_name + '-image-input-field-row').hide();
	$('#' + field_name + '-image-upload-row').hide();
};

imageUploadClicked = function(field_name) {
	$('#' + field_name + '-image-upload-file').hide();
	
	//insert a placeholder message
	$('#' + field_name + '-image-upload-wait').show();
	$('#' + field_name + '-image-upload-start').hide();

	//show the right divs
	$('#' + field_name + '-image-button-row').hide();
	$('#' + field_name + '-image-input-field-row').hide();
	$('#' + field_name + '-image-upload-row').show();
	
	//make ajax call to get signed request
	$.ajax({url: '/image_upload/generate_token',
		dataType: 'json',
		type: 'POST',
		error: function() {alert("Sorry, something failed please try again")},
		success: function(data, textState, jqXHR){
    		$('#' + field_name + '-image-upload-wait').hide();
			var uploadUrl = data['upload_url'];
			var fields = data['fields'];
			var key = data['key'];
			var selector = '#' + field_name + '-image-upload-file';
			$(selector).fileupload({
				url: uploadUrl,
				type: 'POST',
				autoUpload:  true,
				formData: fields,
				paramName: 'file',
				dataType: 'XML',
				replaceFileInput: false})
				  .bind('fileuploadstart', function (e, data) {
					$('#' + field_name + '-image-upload-start').show();
					$('#' + field_name + '-image-upload-file').hide();
				  })
				  .bind('fileuploaddone', function (e, data) {
  					$('#' + field_name + '-image-upload-start').hide();
					 // extract key and generate URL from response
			        var key   = $(data.jqXHR.responseXML).find("Key").text();
			        var imageUrl   = uploadUrl + key;
			        $("#" + field_name + "-image-field").val(imageUrl);
			        //trigger angular change event if necessary
			        //see: http://stackoverflow.com/questions/17109850/update-angular-model-after-setting-input-value-with-jquery
			        $("#" + field_name + "-image-field").trigger('input');
			        imageSpecifyClicked(field_name);
				  })
				  .bind('fileuploadfail', function(e, data) {
				  	alert("Sorry, there was an error uploading the image.  Please try again.");
				  });
			$(selector).show();
		}			
	});	
};

imageSpecifyClicked = function(field_name) {
	$('#' + field_name + '-image-button-row').hide();
	$('#' + field_name + '-image-upload-row').hide();
	$('#' + field_name + '-image-input-field-row').show();
};

imageDontUseClicked = function(field_name) {
	var url = "https://s3.amazonaws.com/fv-assets/rf-messages/placeholder_image.jpg";
	$("#" + field_name + "-image-field").val(url);
	//trigger angular change event if necessary
	//see: http://stackoverflow.com/questions/17109850/update-angular-model-after-setting-input-value-with-jquery
	$("#" + field_name + "-image-field").trigger('input');
};


registerImageUploadField = function(field_name) {
	$(document).ready(function() {
		if (!isEmpty($('#' + field_name + "-image-field").val())){
			imageSpecifyClicked(field_name);
		}
	});
}
