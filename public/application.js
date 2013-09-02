$(document).ready(function() {
		player_hits();
		player_stays();
});

function player_hits() {
		$(document).on('click', '#hit_form input', function() {


		$.ajax({
			type: 'POST',
			url: '/game/player/hit'
		}).done(function(msg) {
			$('#game').replaceWith(msg);	
		
		});

		return false;
	});
}

function player_stays() {
			$(document).on('click', '#stay_form input', function() {


		$.ajax({
			type: 'POST',
			url: '/game/player/stay'
		}).done(function(msg) {
			$('#game').replaceWith(msg);	
		
		});

		return false;
	});

}