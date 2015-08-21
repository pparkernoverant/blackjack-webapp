require 'rubygems'
require 'sinatra'
require './blackjack.rb'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'afsd82rn3rqfgegq94vkfdd298r834tb' 

helpers do
  def check_21(player)
    return Blackjack.get_possible_scores(session[:game].cards[player]).include? 21
  end
end

get '/' do
  redirect '/new_game'
end

get '/new_game' do
  erb :set_name
end

post '/set_name' do
  if params[:player_name].empty?
    @error = "Name is required"
    halt erb :set_name
  end

  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  session[:player] = Blackjack::Player.new session[:player_name]
  session[:dealer] = Blackjack::Computer.new 'Dealer'

  session[:game] = Blackjack::Game.new [session[:player], session[:dealer]]
  
  session[:game].hit! session[:dealer]
  session[:game].hit! session[:dealer]
  session[:game].hit! session[:player]
  session[:game].hit! session[:player]

  if check_21 session[:player]
    @winner = session[:player]
  else
    @enable_player_actions = true
  end

  @whose_turn = session[:player_name]
  erb :game
end

post '/player_action' do
  if params['player_action'] == 'Hit'
    session[:game].hit! session[:player]

    if session[:game].busted? session[:player]
      @player_busted = "You busted!"
      @winner = session[:dealer]
    elsif check_21 session[:player]
      @winner = session[:player] if check_21 session[:player]
    else
      @enable_player_actions = true
    end

    @whose_turn = session[:player_name]
    halt erb :game
  else
    redirect 'dealer_action'
  end
end


get '/dealer_action' do
  @dealer_action = session[:dealer].get_choice session[:game].cards[session[:dealer]]

  if session[:game].busted? session[:dealer]
    @dealer_busted = true 
    @winner = session[:player]
    halt erb :game
  end

  if @dealer_action == 'stay'
    player_score = Blackjack.get_possible_scores(session[:game].cards[session[:player]]).max
    dealer_score = Blackjack.get_possible_scores(session[:game].cards[session[:dealer]]).max

    if player_score > dealer_score
      @winner = session[:player]
    else
      @winner = session[:dealer]
    end
  end
      
  @whose_turn = 'Dealer'
  erb :game
end

post '/reveal_dealer_card' do
  session[:game].hit! session[:dealer]
  redirect '/dealer_action'
end








