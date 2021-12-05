#!/usr/bin/env ruby

require 'awesome_print'

movements = File.readlines('input.txt').map(&:chomp)

aim = 0

horizontal_distance = 0
depth_distance = 0

movements.each do |movement|
  direction, x = movement.scan(/^(\S+)\s+(\d+)$/).first
  direction = direction.to_sym
  x = x.to_i

  case direction
  when :down
    aim += x
  when :up
    aim -= x
  when :forward
    horizontal_distance += x
    depth_distance += aim * x
  end
end

ap aim
ap horizontal_distance
ap depth_distance

ap horizontal_distance * depth_distance
