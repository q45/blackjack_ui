require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_MIN_HIT = 17

helpers do

	def calculate_total(cards)
		arr = cards.map{|e| e[1]}

		total = 0
		arr.each do |a|
			if a == "A"
				total += 11
			else
				total += a.to_i == 0 ? 10 : a.to_i
			end
		end

		#correct for aces
		arr.select{|element| element == "A"}.count.times do
			break if total <= BLACKJACK_AMOUNT
			total -= 10
		end
		total
	end

		def winner!(msg)
			@play_again = true
			@show_hit_or_stay_button = false
			@success = "<strong>#{session[:player_name]} wins</strong> #{msg}"
		end

		def loser!(msg)
			@play_again = true
			@show_hit_or_stay_button = false
			@error = "<strong>#{session[:player_name]} loses</strong> #{msg}"
		end

		def tie!(msg)
			@play_again = true
			@show_hit_or_stay_button = false
			@succes = "<strong>It's a tie</strong> #{msg}"
		end	
end



def card_image(card)

		suit = case card[0]
			when 'hearts' then 'hearts'
			when 'diamonds' then 'diamonds'
			when 'clubs' then 'clubs'
			when 'spades' then 'spades'
 		end
 		value = card[1]
 		if ['J', 'Q', 'K', 'A'].include?(value)
 			value = case card[1]
 			when 'J' then 'jack'
 			when 'Q' then 'queen'
 			when 'K' then 'king'
 			when 'A' then 'ace'
 			end
 		end

		"<img src='/images/cards/#{suit}_#{value}.jpg' class=card_image>"
	
end
	
before do
	@show_hit_or_stay_button =  true
end

post "/set_name" do


end

get "/"  do
	@show_hit_or_stay_button = true
	if !session[:player_name]
		redirect '/new_player'
	else
		redirect '/game'
	end
end

get '/new_player' do
	@show_hit_or_stay_button = true
		erb :new_player
end

post '/new_player' do

	if params[:player_name].empty?
		@error = "Name is required"
		halt erb :new_player
	end
	session[:player_name] = params[:player_name]
	#progress to the game
	redirect '/game'
end

get '/game' do

	session[:turn] = session[:player_name]
	#set up initial game values
	#deck
	suits = ['hearts', 'diamonds', 'clubs', 'spades']
	values = %w[2 3 4 5 6 7 8 9 10 jack queen king ace]

	session[:deck] = suits.product(values).shuffle
	#deal cards
		#dealer cards
		session[:dealer_cards] = []
		session[:player_cards] = []

		session[:dealer_cards] << session[:deck].pop
		session[:player_cards] << session[:deck].pop
		session[:dealer_cards] << session[:deck].pop
		session[:player_cards] << session[:deck].pop

		session[:player_total] = session[:player_cards[0][1]] 



		#player cards

	erb :game
end

post '/game/player/hit' do
	session[:player_cards] << session[:deck].pop

	player_total = calculate_total(session[:player_cards])

	if player_total == BLACKJACK_AMOUNT
		winner!("#{session[:player_name]} hit blackjack")
	elsif player_total > BLACKJACK_AMOUNT
		loser!("Sorry #{session[:player_name]} you busted")
	else
		tie!("")
	end
	erb :game
end

post '/game/player/stay' do

	@success = "#{session[:player_name]} chose to stay"
	@show_hit_or_stay_button = false
	redirect '/game/dealer'
end

get '/game/dealer' do
	session[:turn] = "dealer"
	@show_hit_or_stay_button = false
	dealer_total = calculate_total(session[:dealer_cards])

	if dealer_total == BLACKJACK_AMOUNT
		@error = "Sorry Dealer hit blackjack"
	elsif dealer_total > BLACKJACK_AMOUNT
		@success = "Congrats you win. Dealer busted"
	elsif dealer_total >= DEALER_MIN_HIT #17 18 19 20
		#dealer stays
		redirect '/game/compare'

	else
		#dealer hits
		@show_dealer_hit_button = true
	end

	erb :game
end

post '/game/dealer/hit' do
	session[:dealer_cards] << session[:deck].pop
	redirect '/game/dealer'
end

get '/game/compare' do
	player_total = calculate_total(session[:player_cards])
	dealer_total = calculate_total(session[:dealer_cards])

	if player_total < dealer_total
		@error = "Sorry, you lose"
		loser!("#{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}")
	elsif player_total > dealer_total
		@success = "Congrats you win"
		winner!("#{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}")
	else
		@success = "It's a tie"
		tie!("Both #{player_name} and the dealer stayed at #{dealer_total}")
	end

	erb :game
end

get '/game_over' do
	erb :game_over
end


