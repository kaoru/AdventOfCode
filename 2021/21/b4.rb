#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'

class Board
  attr_reader :size, :players, :positions, :scores

  def initialize(size, players=Array.new, positions=Hash.new(0), scores=Hash.new(0))
    @size = size
    @players = players
    @positions = positions
    @scores = scores

    # Perl-style auto-vivifying Hash
    p = lambda { |h, k| h[k] = Hash.new(&p) }
    @wins = Hash.new(&p)
  end

  def player(player, position)
    @players << player
    @positions[player.id] = position
    @scores[player.id] = 0
  end

  def wins(positions=@positions, scores=@scores, turn=1)
    if (cached = @wins[positions][scores][turn]).any?
      return cached
    end

    winner = scores.sort.to_h.values.map do |v|
      v >= 21 ? 1 : 0
    end
    if winner.any?(&:positive?)
      return winner
    end

    player = players[(turn-1) % players.length].id

    @wins[positions][scores][turn] = outcomes.map do |roll|
      next_pos = move(positions[player], roll)

      wins(positions.merge({ player => next_pos }), scores.dup.tap { |s| s[player] += next_pos }, turn + 1)
    end.reduce(Array.new(players.length) { 0 }) { |acc, win| acc = acc.zip(win).map(&:sum) }
  end

  def move(position, distance)
    (position + distance - 1) % size + 1
  end

  def outcomes
    @outcomes ||= [1,2,3].repeated_permutation(3).map(&:sum)
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

ap board.wins
