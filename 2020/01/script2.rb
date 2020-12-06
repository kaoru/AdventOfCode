#!/usr/bin/env ruby

input = File.read('input')

expenses = input.split("\n").map(&:to_i)

expenses.sort!

expenses.each do |a|
  expenses.each do |b|
    expenses.each do |c|
      if a + b + c == 2020
        puts a * b * c
        exit
      end
    end
  end
end
