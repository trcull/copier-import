
startNewUser = function() {
	$('.choose-form').hide();
	$('.sign-in-form').hide();
	$('.sign-up-form').show();
	$('.sign-up-form .step1').show();
	$('.sign-up-form .step2').hide();
};

startReturningUser = function() {
	$('.choose-form').hide();
	$('.sign-up-form').hide();
	$('.sign-in-form').show();
	$('.sign-in-form .step1').show();
};

signupStepTwo = function() {
	$('.step1').hide();
	$('.sign-up-form .step2').show();
	return false;
};

validateStep1 = function() {
	
};

validateStep2 = function() {
	
};

signupSubmit = function() {
	$("#sign-up-form").submit();
}