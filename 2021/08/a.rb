#!/usr/bin/env ruby

require 'awesome_print'

class SignalPattern
  NORMAL_DIGITS = [
    [:a, :b, :c,     :e, :f, :g], # 0 => 6
    [        :c,         :f    ], # 1 => 2
    [:a,     :c, :d, :e,     :g], # 2 => 5
    [:a,     :c, :d,     :f, :g], # 3 => 5
    [    :b, :c, :d,     :f    ], # 4 => 4
    [:a, :b,     :d,     :f, :g], # 5 => 5
    [:a, :b,     :d, :e, :f, :g], # 6 => 6
    [:a,     :c,         :f    ], # 7 => 3
    [:a, :b, :c, :d, :e, :f, :g], # 8 => 7
    [:a, :b, :c, :d,     :f, :g], # 9 => 6
  ]

  attr_reader :signals

  def initialize(string)
    @signals = string.chars.sort.map(&:to_sym)
  end

  def signal_count
    signals.count
  end

  def unique?
    NORMAL_DIGITS.select { |nd| nd.count == signal_count }.count == 1
  end
end

class InputRecord
  attr_reader :unique_patterns, :output_patterns

  def initialize(string)
    observed, output = string.split(/\s+\|\s+/)

    @unique_patterns = observed.split.map do |str|
      SignalPattern.new(str)
    end

    @output_patterns = output.split.map do |str|
      SignalPattern.new(str)
    end
  end
end

input_records = File.readlines('input.txt', chomp: true).map do |input_string|
  InputRecord.new(input_string)
end

unique_count = input_records.sum do |ir|
  ir.output_patterns.select(&:unique?).count
end

puts unique_count
