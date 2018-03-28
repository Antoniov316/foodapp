// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.min.js
//= require bootstrap-sprockets
//= require jquery_ujs
//= require jquery-ui/datepicker
//= require jquery-ui/slider
//= require toastr
//= require moment
//= require fullcalendar 
//= require card
//= require bootstrap-datepicker
//= require cable
//= require bootstrap.min.js
//= require owl.carousel
//= require_tree .


function onRemoveProduct(name)
{
		var r = confirm("are you sure want to remove " + name +" from cart?");
	if(r==true)
	{
 		window.location.href = "/remove_product_from_session?name="+name;
    }
}

$(function() {
	$(".autolocation").geocomplete();
})

