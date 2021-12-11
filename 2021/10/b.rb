#!/usr/bin/env ruby

require 'awesome_print'

class Line
  OPEN = ['(', '[', '{', '<']
  CLOSE = [')', ']', '}', '>']
  EXPECTED = OPEN.zip(CLOSE).to_h

  attr_reader :line

  def initialize(line)
    @line = line
    parse
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

  def autocomplete_score
    return 0 unless @completion

    score = 0
    scores = {
      ')' => 1,
      ']' => 2,
      '}' => 3,
      '>' => 4,
    }

    @completion.each do |char|
      score *= 5
      score += scores[char]
    end

    score
  end

  private

  def first_illegal_character
    @first_illegal_character
  end

  def completion
    @completion
  end

  def parse
    return if @parsed

    stack = []

    line.chars.each do |char|
      if OPEN.include?(char)
        stack << char
      elsif CLOSE.include?(char)
        if EXPECTED[stack.last] == char
          stack.pop
        else
          @first_illegal_character = char
          return
        end
      end

      if stack.any?
        @completion = stack.reverse.map { |o| EXPECTED[o] }
      end

      @parsed = true
    end
  end
end

lines = File.readlines('input.txt').map { |line| Line.new(line) }

scores = lines.reject(&:corrupted?).map(&:autocomplete_score).sort

puts scores[scores.length / 2]
