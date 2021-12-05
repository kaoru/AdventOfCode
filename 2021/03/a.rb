#!/usr/bin/env ruby

require 'awesome_print'

inputs = File.readlines('input.txt').map(&:chomp)

positions = inputs.each_with_object([]) do |binary_string, array|
  binary_string.each_char.with_index do |binary_digit, index|
    array[index] ||= []
    array[index] << binary_digit
  end
end

gamma_digits = positions.map do |position_values|
  position_values.tally.to_a.sort_by { |a| a[1] }.last.first
end

gamma = gamma_digits.join.to_i(2)

epsilon_digits = positions.map do |position_values|
  position_values.tally.to_a.sort_by { |a| a[1] }.first.first
end

epsilon = epsilon_digits.join.to_i(2)

ap gamma
ap epsilon
ap gamma * epsilon
