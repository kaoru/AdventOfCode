#!/usr/bin/env ruby

require 'awesome_print'

inputs = File.readlines('input.txt').map(&:chomp)

o2 = inputs.dup

o2.first.length.times do |i|
  positions = o2.each_with_object([]) do |binary_string, array|
    binary_string.each_char.with_index do |binary_digit, index|
      array[index] ||= []
      array[index] << binary_digit
    end
  end

  tally = positions[i].tally
  common = tally['0'] > tally['1'] ? '0' : '1'

  o2.select! { |binary_string| binary_string[i] == common }

  break if o2.length == 1
end

o2 = o2.first
ap o2

co2 = inputs.dup

co2.first.length.times do |i|
  positions = co2.each_with_object([]) do |binary_string, array|
    binary_string.each_char.with_index do |binary_digit, index|
      array[index] ||= []
      array[index] << binary_digit
    end
  end

  tally = positions[i].tally
  least_common = tally['0'] <= tally['1'] ? '0' : '1'

  co2.select! { |binary_string| binary_string[i] == least_common }

  break if co2.length == 1
end

co2 = co2.first
ap co2

ap o2.to_i(2)
ap co2.to_i(2)

ap o2.to_i(2) * co2.to_i(2)
