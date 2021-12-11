#!/usr/bin/env ruby

require 'awesome_print'
require 'set'

class SignalPattern
  DIGITS = [
    Set.new([:a, :b, :c,     :e, :f, :g]), # 0 => 6
    Set.new([        :c,         :f    ]), # 1 => 2
    Set.new([:a,     :c, :d, :e,     :g]), # 2 => 5
    Set.new([:a,     :c, :d,     :f, :g]), # 3 => 5
    Set.new([    :b, :c, :d,     :f    ]), # 4 => 4
    Set.new([:a, :b,     :d,     :f, :g]), # 5 => 5
    Set.new([:a, :b,     :d, :e, :f, :g]), # 6 => 6
    Set.new([:a,     :c,         :f    ]), # 7 => 3
    Set.new([:a, :b, :c, :d, :e, :f, :g]), # 8 => 7
    Set.new([:a, :b, :c, :d,     :f, :g]), # 9 => 6
  ]
  EXISTENCE = DIGITS.to_h { |d| [d,true] }

  attr_reader :signals

  def initialize(string)
    @signals = Set.new(string.chars.map(&:to_sym))
  end

  def valid?(mapping)
    EXISTENCE.key?(mapped(mapping))
  end

  def value(mapping)
    DIGITS.index(mapped(mapping))
  end

  def mapped(mapping)
    Set.new(signals.map { |s| mapping[s] })
  end
end

class InputRecord
  SIGNALS = (:a..:g).to_a
  POSSIBLE = SIGNALS.permutation(7).to_a.map do |perm|
    SIGNALS.zip(perm).to_h
  end
  attr_reader :unique_patterns, :output_patterns

  def initialize(string)
    observed, output = string.split(/\s+\|\s+/)

    @unique_patterns = observed.split.sort_by(&:length).map do |str|
      SignalPattern.new(str)
    end

    @output_patterns = output.split.map do |str|
      SignalPattern.new(str)
    end
  end

  def output_value
    mapping = observe

    output_patterns.each_with_index.sum do |pattern, i|
      pattern.value(mapping) * (10 ** (3-i))
    end
  end

  def observe
    possible_mappings = POSSIBLE.dup

    POSSIBLE.find do |mapping|
      unique_patterns.all? { |pattern| pattern.valid?(mapping) }
    end
  end
end

input_records = File.readlines('input.txt', chomp: true).map do |input_string|
  InputRecord.new(input_string)
end

final_result = input_records.sum do |ir|
  value = ir.output_value
  puts "Result: #{value}"
  value
end

puts "Final Result: #{final_result}"
