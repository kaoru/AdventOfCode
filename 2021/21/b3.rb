#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'

class Node
  attr_reader :board, :positions, :turn, :scores, :occurrences, :children

  def initialize(board, positions=board.positions, turn=1, scores=Hash.new(0), occurrences=0, children={})
    @board = board
    @positions = positions
    @turn = turn
    @scores = scores
    @occurrences = occurrences
    @children = children
  end

  def play(winners)
    scores.each do |player, score|
      if score >= 21
        winners[player] += occurrences
        ap winners
        return :winner
      end
    end

    roll_distribution.each do |roll, times|
      children[roll] ||= begin
                           new_positions = positions.dup
                           new_scores = scores.dup

                           new_positions[player_for_turn] = move(positions[player_for_turn], roll)
                           new_scores[player_for_turn] += new_positions[player_for_turn]

                           Node.new(board, new_positions, turn+1, new_scores, occurrences + times)
                         end
    end

    children.values
  end

  def to_h
    {
      current_player: player_for_turn,
      positions: positions,
      scores: scores,
    }
  end

  def players
    positions.keys
  end

  def player_for_turn
    players[(turn-1) % players.length]
  end

  def roll_distribution
    @roll_distribution ||= [1,2,3].repeated_permutation(3).map(&:sum).tally
  end

  def move(position, distance)
    (position + distance - 1) % board.size + 1
  end
end

class Board
  attr_reader :size, :players, :positions

  def initialize(size, players=Array.new, positions=Hash.new(0))
    @size = size
    @players = players
    @positions = positions
    @universe = Node.new(self)
    @plays = {}
  end

  def player(player, position)
    @players << player
    @positions[player.id] = position
  end

  def play(universe=@universe, winners=Hash.new(0))
    next_universes = @plays[universe.to_h] ||= universe.play(winners)

    if next_universes.is_a?(Array)
      next_universes.each do |uni|
        self.play(uni, winners)
      end
    end

    winners
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
