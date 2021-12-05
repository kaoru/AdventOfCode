#!/usr/bin/env ruby

require 'awesome_print'

measurements = File.readlines('input.txt').map(&:to_i)

sums = measurements.each_cons(3).map { |a, b, c| a + b + c }

increases = sums.each_cons(2).select { |a, b| a < b }

puts increases.count
