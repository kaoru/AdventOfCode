#!/usr/bin/env ruby

require 'awesome_print'

class Line
  OPEN = ['(', '[', '{', '<']
  CLOSE = [')', ']', '}', '>']
  EXPECTED = OPEN.zip(CLOSE).to_h

  attr_reader :line

  def initialize(line)
    @line = line
  end

  def corrupted?
    first_illegal_character
  end

  def corruption_score
    return 0 unless corrupted?

    scores = {
      ')' => 3,
      ']' => 57,
      '}' => 1197,
      '>' => 25137,
    }

    scores[first_illegal_character]
  end

  private

  def first_illegal_character
    stack = []

    line.chars.each do |char|
      if OPEN.include?(char)
        stack << char
      elsif CLOSE.include?(char)
        if EXPECTED[stack.last] == char
          stack.pop
        else
          puts "Expected #{EXPECTED[stack.last]}, but found #{char} instead."
          return char
        end
      end
    end

    nil
  end
end

lines = File.readlines('input.txt').map { |line| Line.new(line) }

puts lines.sum(&:corruption_score)
