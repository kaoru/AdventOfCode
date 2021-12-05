#!/usr/bin/env ruby

require 'awesome_print'

movements = File.readlines('input.txt').map(&:chomp)

totals = movements.each_with_object(Hash.new(0)) do |movement, o|
  direction, distance = movement.scan(/^(\S+)\s+(\d+)$/).first

  o[direction.to_sym] += distance.to_i
end

horizontal = totals[:forward]
vertical = totals[:down] - totals[:up]

puts horizontal * vertical
