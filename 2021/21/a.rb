#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'

class Die
  attr_reader :rolls

  def initialize(sides)
    @die = Range.new(1, sides).cycle
    @rolls = 0
  end

  def roll
    @rolls += 1
    @die.next
  end
end

class Board
  def initialize(size)
    @size = size
    @players = []
    @positions = {}
  end

  def player(player, position)
    @players << player
    @positions[player] = position
  end

  def play(die)
    @players.cycle.each do |player|
      rolls = 3.times.map { die.roll }
      distance = rolls.sum
      move(player, distance)
      player.add_score(@positions[player])

      puts "Player #{player.id} rolled #{rolls.join('+')} and moves to space #{@positions[player]} for a total score of #{player.score}."

      if player.winner?
        loser_scores = @players.reject { |p| p == player }.map(&:score).sum
        die_rolls = die.rolls
        puts "Final result: #{loser_scores} * #{die_rolls} = #{loser_scores * die_rolls}"
        return
      end
    end
  end

  def move(player, distance)
    distance.times do
      @positions[player] += 1
      if @positions[player] > @size
        @positions[player] = 1
      end
    end
  end
end

class Player
  attr_reader :id, :score

  def initialize(id)
    @id = id
    @score = 0
  end

  def add_score(n)
    @score += n
  end

  def winner?
    @score >= 1000
  end
end

die = Die.new(100)

board = Board.new(10)

File.readlines('input.txt', chomp: true).each do |line|
  id, pos = line.scan(/Player (\d+) starting position: (\d+)/).first.map(&:to_i)
  board.player(Player.new(id), pos)
end

board.play(die)
