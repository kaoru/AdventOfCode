#!/usr/bin/env ruby

require 'awesome_print'

class School
  attr_reader :school, :days

  def initialize(initial_state_string)
    @school = initial_state_string.split(/\s*,\s*/).map(&:to_i).tally
  end

  def simulate(days)
    puts "Initial state: #{fish_count} fish"

    days.times do |day|
      next_day
      puts "After #{format('%2d', day + 1)} day#{'s' if day > 0}: #{fish_count} fish"
    end

    puts "Ended with #{fish_count} fish"
  end

  def next_day
    @school = next_school
  end

  def fish_count
    school.values.sum
  end

  private

  def next_school
    Hash.new(0).tap do |next_school|
      school.keys.each do |fish|
        if fish == 0
          next_school[6] += school[fish]
          next_school[8] += school[fish]
        else
          next_school[fish - 1] += school[fish]
        end
      end
    end
  end
end

input = File.readlines('input.txt').first.chomp

school = School.new(input)
school.simulate(256)
