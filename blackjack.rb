
module Blackjack

  class Game
    attr_reader :players, :cards

    def initialize(players)
      @completed = false
      @deck = Deck.new
      @players = {}
      @cards = {}

      players.each do |player|
        @players[player.name] = player
        @cards[player] = []
      end

    end

    def hit!(player)
      player = players[player.to_s] unless player.is_a? Player
      cards[player] << @deck.draw
    end

    def busted?(player)
      player = players[player.to_s] unless player.is_a? Player
      busted = Blackjack.get_possible_scores(cards[player]).empty?
      return busted 
    end
  end

  class Deck
    @@suits = ['Spades', 'Hearts', 'Clubs', 'Diamonds']
    @@faces = ['Jack', 'Queen', 'King', 'Ace']
    (2..10).each {|x| @@faces << x.to_s}

    def initialize
      @cards = Array.new
      @@suits.each do |suit|
        @@faces.each do |face|
          @cards << Card.new(suit, face)
        end
      end
      @cards.shuffle!
    end

    def draw
      @cards.pop
    end
  end

  class Card
    attr_reader :suit, :face, :value
    
    def initialize(suit, face)
      @suit = suit
      @face = face

      if (2..10).include? face.to_i
        @value = face.to_i
      elsif ['Jack', 'Queen', 'King'].include? face
        @value = 10
      else
        @value = [1, 11]
      end
    end

    def to_s
      "#{face} of #{suit}"
    end
  end

  class Player
    attr_reader :name

    def initialize(name)
      @name = name
    end
  end

  class Computer < Player
    def get_choice(cards)
      if Blackjack.get_possible_scores(cards).select {|card| card > 16}.empty?
        choice = 'hit'
      else
        choice = 'stay'
      end

      return choice
    end
  end

  def self.get_possible_scores(cards)
    scores = [0]

    cards.each do |card|
      if card.face != 'Ace'
        scores.map! {|score| score + card.value} 
      else
        new_scores = Array.new
        scores.each do |score|
          new_scores << score + 1
          new_scores << score + 11
        end
        scores = new_scores
      end
    end

    return scores.uniq.select {|score| score < 22}
  end

end
