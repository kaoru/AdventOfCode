#!/usr/bin/env ruby

input = File.read('input')

expenses = input.split("\n").map(&:to_i)

expenses.sort!

expenses.each do |a|
  expenses.each do |b|
    if a + b == 2020
      puts a * b
    end
  end
end
