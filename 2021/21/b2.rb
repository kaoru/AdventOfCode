#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'

class Board
  attr_reader :size, :players, :turn, :positions, :scores

  def initialize(size, players=Array.new, turn=0, positions=Hash.new(0), scores=Hash.new(0))
    @size = size
    @players = players
    @turn = turn
    @positions = positions
    @scores = scores
  end

  def dup
    Board.new(size, players, turn, positions.dup, scores.dup)
  end

  def player(player, position)
    @players << player
    @positions[player] = position
  end

  def play
    original_positions = positions.dup

    winners = Hash.new(0)
    winning_moves = Hash.new(false)
    moves = []

    [1,2,3].repeated_permutation(24).each do |universe|
      puts "Considering #{universe.join(',')}"

      @positions = original_positions.dup
      @scores = Hash.new(0)
      moves.clear

      win_check = []
      seen = false
      universe.each_slice(3) do |rolls|
        win_check += rolls
        if winning_moves[win_check.join('-')]
          seen = true
          break
        end
      end
      next if seen

      universe.each_slice(3) do |rolls|
        sum = rolls.sum
        move(player_for_turn, sum)
        moves += rolls

        if winner
          winners[player_for_turn.id] += 1
          winning_moves[moves.join('-')] = true
          puts "Winner! #{player_for_turn.id}"
          break
        end

        increment_turn
      end

      if !winner
        puts "Did not find a winner :("
      end
    end
  end

  def move(player, distance)
    @positions[player] += distance
    if @positions[player] > @size
      @positions[player] = (@positions[player] % @size) + 1
    end
    @scores[player] += @positions[player]
  end

  def player_for_turn
    players[turn % players.length]
  end

  def increment_turn
    @turn += 1
  end

  def winner
    players.find { |p| scores[p] >= 21 }
  end
end

class Player
  attr_reader :id

  def initialize(id)
    @id = id
  end
end


board = Board.new(10)

File.readlines('input.txt', chomp: true).each do |line|
  id, position = line.scan(/Player (\d+) starting position: (\d+)/).first.map(&:to_i)
  board.player(Player.new(id), position)
end

ap board.play
