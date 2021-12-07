#!/usr/bin/env ruby

require 'awesome_print'

class Crab
  attr_reader :position

  def initialize(position)
    @position = position
  end

  def fuel_to_move_to(new_position)
    (new_position - @position).abs
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
