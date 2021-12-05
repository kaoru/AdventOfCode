#!/usr/bin/env ruby

require 'awesome_print'

measurements = File.readlines('input.txt').map(&:to_i)

increases = measurements.each_cons(2).select { |a, b| a < b }

puts increases.count
