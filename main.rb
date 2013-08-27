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
end

post "/set_name" do


end

get "/"  do
	if session[:player_name]
		redirect '/game'
	else
		redirect '/new_player'
	end
end

get '/new_player' do
		erb :new_player
end

post '/new_player' do
	session[:player_name] = params[:player_name]
	#progress to the game
	redirect '/game'
end

get '/game' do
	#set up initial game values
	#deck
	suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades']
	values = %w[2 3 4 5 6 7 8 9 10 J Q K A]

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



