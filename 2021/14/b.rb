#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'

class Polymer
  attr_reader :chars, :last_char

  def initialize(line)
    @chars = line.chars.each_cons(2).map(&:join).tally
    @last_char = line.chars.last
  end

  def step(instructions)
    new = Hash.new(0)

    chars.each do |pair, count|
      instruction = instructions.find { |i| i.match?(pair) }

      if instruction
        new["#{pair[0]}#{instruction.insert}"] += count
        new["#{instruction.insert}#{pair[1]}"] += count
      else
        new[pair] += count
      end
    end

    @chars = new
  end

  def score
    letters = chars.each_with_object(Hash.new(0).tap { |h| h[last_char] = 1 }) do |(k, v), h|
      h[k[0]] += v
    end

    letters.values.reject(&:zero?).sort.minmax.then { |min, max| max - min }
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
puts "Template:     #{polymer.score}"
1.upto(40) do |step|
  polymer.step(instructions)
  puts "After step #{step}: #{polymer.score}"
end
