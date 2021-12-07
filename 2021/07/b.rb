#!/usr/bin/env ruby

require 'awesome_print'

class Crab
  attr_reader :position

  def initialize(position)
    @position = position
  end

  def fuel_to_move_to(new_position)
    # Each change of 1 step in horizontal position costs 1 more unit of fuel
    # than the last: the first step costs 1, the second step costs 2, the third
    # step costs 3, and so on.
    #
    # 0 => 0
    # 1 => 1
    # 2 => 1 + 2 = 3
    # 3 => 1 + 2 + 3 = 6
    #
    # It's the triangle numbers! f = d*(d-1)/2
    #
    distance = (new_position - @position).abs
    (distance * (distance + 1)) / 2
  end
end

crabs = File.readlines('input.txt').first.split(/,/).map do |input|
  Crab.new(input.to_i)
end

positions = 0.upto(crabs.map(&:position).max)

fuel_used = positions.to_h do |position|
  [position, crabs.map { |c| c.fuel_to_move_to(position) }.sum]
end

best_position = fuel_used.sort_by(&:last).first.first
puts "Position: #{best_position}"

fuel_used_at_best_position = fuel_used[best_position]
puts "Fuel Used: #{fuel_used_at_best_position}"
