require 'rubygems'
require 'sinatra'

set :sessions, true

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
			break if total <= 21
			total -= 10
		end
		total

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
	if calculate_total(session[:player_cards]) > 21
		@error = " Sorry, it looks like #{session[player_name]}"
		@show_hit_or_stay_button = false
	end
	erb :game
end

post '/game/player/stay' do
	@success = "#{session[:player_name]} chose to stay"
	@show_hit_or_stay_button = false
	erb :game
end


