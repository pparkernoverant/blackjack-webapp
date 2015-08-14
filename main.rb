require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'afsd82rn3rqfgegq94vkfdd298r834tb' 

helpers do
  def calculate_total(cards)
    10
  end
end


get '/' do
  erb :set_name
end

get '/message01' do
  erb :sb_template01
end

get '/message02' do
  erb :'sb_subfolder/sb_template02'
end


post '/set_name' do
  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  session[:deck] = [['2', 'Spades'], ['3', 'Hearts'], ['10', 'Clubs']]
  session[:player_cards] = []
  session[:player_cards] << session[:deck].pop

  erb :game
end