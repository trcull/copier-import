var App = angular.module('App', []);
 
var EditOrganizationCtrl = function EditOrganizationCtrl($scope, $http) {
	$scope.org = {};
	$scope.user = {};
	$scope.allowableTypes = ['Organization', 'ShopifyOrganization'];
	$scope.allowableStoreTypes = ['Manual','Shopify'];
	$scope.storeTypeToType = {'Manual':'Organization', 'Shopify':'ShopifyOrganization'};
	
	$scope.allowableCurrencies = ['USD','EUR','CAD','GBP','AED','AFN','ALL','AMD','ANG','AOA','ARS','AWG','AZN','BAM','BBD','BDT','BGN','BHD','BIF','BMD','BND','BOB','BRL','BSD','BTC','BTN','BWP','BYR','BZD','CDF','CHF','CLF','CLP','CNY','COP','CRC','CUP','CVE','CZK','DJF','DKK','DOP','DZD','EEK','EGP','ERN','ETB','FJD','FKP','GEL','GGP','GHS','GIP','GMD','GNF','GTQ','GYD','HKD','HNL','HRK','HTG','HUF','IDR','ILS','IMP','INR','IQD','IRR','ISK','JEP','JMD','JOD','JPY','KES','KGS','KHR','KMF','KPW','KRW','KWD','KYD','KZT','LAK','LBP','LKR','LRD','LSL','LTL','LVL','LYD','MAD','MDL','MGA','MKD','MMK','MNT','MOP','MRO','MTL','MUR','MVR','MWK','MXN','MYR','MZN','NAD','NGN','NIO','NOK','NPR','NZD','OMR','PAB','PEN','PGK','PHP','PKR','PLN','PYG','QAR','RON','RSD','RUB','RWF','SAR','SBD','SCR','SDG','SEK','SGD','SHP','SLL','SOS','SRD','STD','SVC','SYP','SZL','THB','TJS','TMT','TND','TOP','TRY','TTD','TWD','TZS','UAH','UGX','UYU','UZS','VEF','VND','VUV','WST','XAF','XAG','XAU','XCD','XDR','XOF','XPF','YER','ZAR','ZMK','ZMW','ZWL'];
	$scope.selectedCurrency = $scope.allowableCurrencies[0];
	$scope.selectedType = $scope.allowableTypes[0];
	$scope.reportedErrors = [];
	
	$scope.init = function(org, org_type, user) {
		org.type = org_type;
		if (isEmpty(org.store_type)) {
			org.store_type = $scope.allowableStoreTypes[0];
		}
		if (isEmpty(org.currency)) {
			org.currency = $scope.allowableCurrencies[0];
		}
		$scope.selectedCurrency = org.currency;
		$scope.org = org;
		$scope.user = user;
	};
	
	$scope.currencyChanged = function() {
		if ($scope.org.currency == 'USD' || $scope.org.currency == 'CAD') {
			$scope.org.currency_template_text = "${{amount}}";
			$scope.org.currency_template_html = "<span class=money>${{amount}}</span>";
		} else if ($scope.org.currency == 'GBP') {
			$scope.org.currency_template_text = "£{{amount}}";
			$scope.org.currency_template_html = "<span class=money>&pound;{{amount}} GBP</span>";
		} else if ($scope.org.currency == 'EUR') {
			$scope.org.currency_template_text = "€{{amount}}";
			$scope.org.currency_template_html = "<span class=money>&euro;{{amount}}</span>";
		} else {
			$scope.org.currency_template_text = "{{amount}} " + $scope.org.currency;
			$scope.org.currency_template_html = "<span class=money>{{amount}} " + $scope.org.currency + "</span>";
		}	
	};
	
	$scope.storeUrlChanged = function() {
	};
	
	$scope.storeTypeChanged = function() {
		$scope.org.type = $scope.storeTypeToType[$scope.org.store_type];
	};
	
	$scope.save = function() {
		if (!isEmpty($scope.org.store_url) && $scope.org.store_url.match(/http/)) {
			$scope.org.store_url = $scope.org.store_url.replace('http://','').replace('http:','').replace('http','');
		}
		$scope.reportedErrors = [];
		$http.put('/organizations/' + $scope.org.id + '.json', {'organization': $scope.org}).success( function(data) {
			if (data.success == true) {
				userSuccess('Successfully saved organization');
			} else {
				//userError(data.message);
				for (var fieldName in data.errors) {
					var fieldErrors = data.errors[fieldName];
					for (var i=0; i< fieldErrors.length ; i++) {
						userError("Error: " + fieldName + " " + fieldErrors[i]);
					}
				}
			}
		}).error(function() {
			userError("Sorry, there was an error saving.  Please try again later.");
		});		
		//submit the form
	};
};

EditOrganizationCtrl.$inject = ['$scope','$http'];
App.controller('EditOrganizationCtrl',EditOrganizationCtrl);

$('select').selectpicker({
    style: 'btn-primary',
    menuStyle: 'dropdown-inverse'
});