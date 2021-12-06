#!/usr/bin/env ruby

require 'awesome_print'

class School
  attr_reader :school, :days

  def initialize(initial_state_string)
    @school = initial_state_string.split(/\s*,\s*/).map(&:to_i)
  end

  def simulate(days)
    puts "Initial state: #{self}"

    days.times do |day|
      next_day
      puts "After #{format('%2d', day + 1)} day#{'s' if day > 0}: #{self}"
    end

    puts "Ended with #{school.count} fish"
  end

  def next_day
    @school = next_school
  end

  def to_s
    school.join(',')
  end
  alias inspect to_s

  private

  def next_school
    [].tap do |next_school|
      new_fish = 0

      school.each do |fish|
        if fish == 0
          next_school << 6
          new_fish += 1
        else
          next_school << fish - 1
        end
      end

      new_fish.times do
        next_school << 8
      end
    end
  end
end

input = File.readlines('input.txt').first.chomp

school = School.new(input)
school.simulate(80)
