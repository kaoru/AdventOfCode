#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'

numbers = []

class SnailfishNumber
  attr_accessor :left, :right, :value, :parent

  def initialize(arg)
    if arg.is_a?(Array)
      @left = SnailfishNumber.wrap(arg[0])
      @left.parent = self

      @right = SnailfishNumber.wrap(arg[1])
      @right.parent = self
    else
      @value = arg
    end
  end

  def self.wrap(arg)
    if arg.is_a?(SnailfishNumber)
      arg
    else
      SnailfishNumber.new(arg)
    end
  end

  def children
    return [] if value?
    [left, *left.children] + [right, *right.children]
  end

  def depth
    depth = 0
    pair = self
    while pair.parent
      depth += 1
      pair = pair.parent
    end
    depth
  end

  def add(b)
    SnailfishNumber.new([self.dup, b.dup]).tap(&:reduce!)
  end

  def dup
    if value?
      SnailfishNumber.new(value)
    else
      SnailfishNumber.new([left.dup, right.dup])
    end
  end

  def reduce!
    #ap "Reducing: #{self}"
    loop do
      explode! && next
      split! || break
    end
  end

  def replace(n)
    if n.pair?
      self.left = n.left
      self.left.parent = self

      self.right = n.right
      self.right.parent = self

      self.value = nil
    elsif n.value?
      self.left = nil
      self.right = nil
      self.value = n.value
    end
  end

  def explode!
    exploded = nil
    left_value = nil
    right_value = nil

    children.each do |n|
      if !exploded && n.value?
        left_value = n
      end

      if n.depth >= 4 && n.pair?
        exploded ||= n
      end

      if exploded && n.value? && n.parent != exploded
        right_value = n
        break
      end
    end

    if exploded
      left_value.value += exploded.left.value if left_value
      right_value.value += exploded.right.value if right_value
      exploded.replace(SnailfishNumber.new(0))
      #ap "After explode: #{self}"
      return true
    else
      return false
    end
  end
  
  def split!
    children.each do |n|
      if n.value? && n.value >= 10
        n.replace(SnailfishNumber.new([(n.value.to_f / 2).floor, (n.value.to_f / 2).ceil]))
        #ap "After split: #{self}"
        return true
      end
    end

    false
  end

  def pair?
    !!(left && right)
  end

  def value?
    !!value
  end

  def to_s
    if pair?
      "[#{left},#{right}]"
    elsif value?
      "#{value.to_s}"
    end
  end
  alias inspect to_s

  def magnitude
    if value?
      value
    else
      3*left.magnitude + 2*right.magnitude
    end
  end
end

File.readlines('input.txt', chomp: true).each do |line|
  if line.match?(/^[\[\],\d]+$/)
    numbers << SnailfishNumber.new(eval(line))
  else
    STDERR.puts "Could not safely eval line: '#{line}'"
  end
end

max_magnitude = 0
summed = nil
numbers.combination(2).each do |a, b|
  [[a,b], [b,a]].each do |m, n|
    magnitude = m.add(n).magnitude
    if magnitude > max_magnitude
      max_magnitude = magnitude
      summed = [m, n]
    end
  end
end

puts summed.first
puts "+ #{summed.last}"
puts "= #{summed.first.add(summed.last)}"
puts "Magnitude: #{max_magnitude}"
