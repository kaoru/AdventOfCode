#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'

class Universe
  attr_reader :board
  attr_accessor :wins

  def initialize(board, wins=0)
    @board = board
    @wins = wins
  end

  def play_turn
    player = board.player_for_turn

    board.increment_turn

    [].tap do |new_universes|
      roll_distribution.each do |sum, occurrences|
        universe = dup
        universe.wins += occurrences
        universe.board.move(player, sum)
        universe.board.scores[player] += universe.board.positions[player]
        new_universes << universe
      end
    end
  end

  def dup
    Universe.new(board.dup, wins)
  end

  def roll_distribution
    @roll_distribution ||= [1,2,3].repeated_permutation(3).map(&:sum).tally
  end

  def winner
    board.winner
  end

  def turn
    board.turn
  end

  def scores
    board.scores
  end
end

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
    universes = [Universe.new(self)]

    winners = players.to_h { |p| [p.id, 0] }

    loop do
      puts universes.length
      break if universes.empty?

      universes.each do |universe|
        universes.delete(universe)

        new_universes = universe.play_turn

        new_universes.select(&:winner).each do |winning_universe|
          winners[winning_universe.winner.id] += winning_universe.wins
          universes.delete(winning_universe)
          new_universes.delete(winning_universe)
        end

        universes += new_universes

        grouped = universes.group_by { |u| u.board.players.map { |p| [u.board.positions[p], u.board.scores[p]] } }.values
        merged_universes = grouped.map do |universes|
          u = universes.pop
          universes.each do |u2|
            u.wins += u2.wins
          end
          u
        end

        universes = merged_universes
      end
    end

    winners
  end

  def move(player, distance)
    @positions[player] += distance
    if @positions[player] > @size
      @positions[player] = (@positions[player] % @size) + 1
    end
  end

  def player_for_turn
    players[turn % players.length]
  end

  def increment_turn
    @turn += 1
  end

  def winner
    @winner ||= players.find { |p| scores[p] >= 21 }
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
