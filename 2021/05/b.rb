#!/usr/bin/env ruby

require 'awesome_print'

class Integer
  def towards(other)
    if self <= other
      self.upto(other)
    else
      self.downto(other)
    end
  end
end

class Point
  attr_reader :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  def to_s
    [x, y].join(',')
  end
  alias inspect to_s
end

class Line
  attr_reader :x1, :y1
  attr_reader :x2, :y2

  def initialize(x1, y1, x2, y2)
    @x1, @y1 = x1, y1
    @x2, @y2 = x2, y2
  end

  def to_s
    format("%d,%d -> %d,%d", x1, y1, x2, y2)
  end
  alias inspect to_s

  def points
    if x1 == x2
      y1.towards(y2).map { |y| Point.new(x1, y) }
    elsif y1 == y2
      x1.towards(x2).map { |x| Point.new(x, y1) }
    else
      x1.towards(x2).zip(y1.towards(y2)).map do |x, y|
        Point.new(x, y)
      end
    end
  end
end

class Grid
  def initialize(size)
    @grid = Array.new(size) do
      Array.new(size) { 0 }
    end
  end

  def to_s
    @grid.map do |row|
      row.map do |cell|
        cell == 0 ? '.' : cell
      end.join
    end.join("\n")
  end

  def plot(line)
    line.points.each do |point|
      @grid[point.y][point.x] += 1
    end
  end

  def overlaps
    @grid.map do |row|
      row.select { |v| v > 1 }.count
    end.sum
  end
end

input = File.readlines('input.txt').map(&:chomp)

lines = input.map do |line|
  points = line.scan(/(\d+),(\d+) -> (\d+),(\d+)/).first
  points.map!(&:to_i)
  Line.new(*points)
end

size = lines.map { |line| [line.x1, line.y1, line.x2, line.y2] }.flatten.max

grid = Grid.new(size + 1)

lines.each do |line|
  grid.plot(line)
end

puts grid.overlaps
