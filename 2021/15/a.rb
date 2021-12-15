#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'
require 'set'

class Cell
  attr_reader :x, :y, :risk
  attr_accessor :up, :right, :down, :left

  def initialize(x, y, risk)
    @x, @y, @risk = x, y, risk
  end

  def neighbours
    [down, right, up, left].compact
  end

  def to_s
    "#{x},#{y}"
  end

  def inspect
    "#{coordinate} (#{risk})"
  end
end

class Grid
  attr_reader :matrix

  def initialize(matrix)
    @matrix = matrix

    @matrix.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        if y > 0
          cell.up = matrix[y - 1][x]
        end

        if y < (@matrix.length - 1)
          cell.down = matrix[y + 1][x]
        end

        if x > 0
          cell.left = matrix[y][x - 1]
        end

        if x < (@matrix.first.length - 1)
          cell.right = matrix[y][x + 1]
        end
      end
    end
  end

  def vertices
    @matrix.flatten
  end

  def start
    @matrix.first.first
  end

  def destination
    @matrix.last.last
  end

  def to_s
    matrix.map do |row|
      row.map(&:risk).join
    end.join("\n")
  end
end

class Path
  attr_reader :cells

  def initialize(cells)
    @cells = cells
  end

  def to_s
    @cells.join(' -> ')
  end

  def total_risk
    @cells.sum(&:risk) - @cells.first.risk
  end
end

class Pathfinder
  attr_reader :grid

  def initialize(grid)
    @grid = grid
  end

  def best_path
    dijkstra(grid, grid.start)
  end

  def destination
    grid.destination
  end

  # https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm#Pseudocode
  def dijkstra(grid, source)
    dist = {}
    prev = {}
    q = Set.new

    grid.vertices.each do |v|
      dist[v] = Float::INFINITY
      prev[v] = nil
      q << v
    end
    dist[source] = 0

    while q.any?
      u = q.min_by { |v| dist[v] }

      q.delete(u)
      break if u == destination

      u.neighbours.each do |v|
        next unless q.include?(v)
        alt = dist[u] + v.risk
        if alt < dist[v]
          dist[v] = alt
          prev[v] = u
        end
      end
    end

    path = [destination]
    while v = prev[path.first]
      path.unshift(v)
    end
    Path.new(path)
  end
end

matrix = []

File.readlines('input.txt', chomp: true).each_with_index do |line, y|
  line.chars.map(&:to_i).each_with_index do |r, x|
    matrix[y] ||= []
    matrix[y][x] = Cell.new(x, y, r)
  end
end

grid = Grid.new(matrix)
puts '-' * matrix.length
puts "Input:"
puts grid
puts '-' * matrix.length

pathfinder = Pathfinder.new(grid)

best_path = pathfinder.best_path
puts "Best path: #{best_path}"
puts "Risk: #{best_path.total_risk}"
