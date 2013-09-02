$(document).ready(function() {
	//$('#hit_form input').click(function() {
		
		$(document).on('click', '#hit_form input', function() {


		$.ajax({
			type: 'POST',
			url: '/game/player/hit'
		}).done(function(msg) {
			$('#game').replaceWith(msg);	
		
		});

		return false;
	});

});