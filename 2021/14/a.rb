#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'

class Polymer
  attr_reader :formula

  def initialize(line)
    @formula = line
  end

  alias to_s formula
  alias inspect formula

  def step(instructions)
    parts = formula.chars.each_cons(2).map do |pair|
      instruction = instructions.find { |i| i.match?(pair.join) }

      if instruction
        [pair.first, instruction.insert, pair.last].join
      else
        pair.join
      end
    end

    @formula = parts.each.with_index(1).reduce(String.new) do |acc, (part, idx)|
      acc << part
      acc.chop! unless idx == parts.count
      acc
    end
  end

  def score
    formula.chars.tally.values.sort.minmax.then do |min, max|
      max - min
    end
  end
end

class Instruction
  attr_reader :match, :insert

  def initialize(line)
    @match, @insert = line.scan(/^(\w+) -> (\w+)$/).first
  end

  def to_s
    "#{match} -> #{insert}"
  end
  alias inspect to_s

  def match?(pair)
    pair == match
  end
end

polymer = nil
instructions = []

File.readlines('input.txt', chomp: true).each do |line|
  if line.match?(/->/)
    instructions << Instruction.new(line)
  elsif line.length > 0
    polymer = Polymer.new(line)
  end
end

puts '-' * 16
puts "Input:"
puts
puts polymer
puts
puts instructions
puts '-' * 16
puts "Template:     #{polymer}"
1.upto(10) do |step|
  polymer.step(instructions)
  puts "After step #{step}: (#{polymer.score})"
end
