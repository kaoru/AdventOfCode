#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'
require 'lazy_priority_queue'

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
    "#{to_s} (#{risk})"
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
    dist = Hash.new(Float::INFINITY)
    dist[source] = 0
    q = MinPriorityQueue.new

    visited = Hash.new(false)
    prev = Hash.new
    grid.vertices.each do |v|
      q.push(v, dist[v])
    end

    until q.empty?
      u = q.pop
      visited[u] = true
      break if u == destination
      ap u

      u.neighbours.each do |v|
        next if visited.key?(v)
        alt = dist[u] + v.risk
        if alt < dist[v]
          dist[v] = alt
          q.decrease_key(v, alt)
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

small_matrix = []

File.readlines('input.txt', chomp: true).each_with_index do |line, y|
  line.chars.map(&:to_i).each_with_index do |r, x|
    small_matrix[y] ||= []
    small_matrix[y][x] = r
  end
end

matrix = []

small_matrix.each_with_index do |row, y|
  row.each_with_index do |cell, x|
    matrix[y] ||= []
    matrix[y][x] = Cell.new(x, y, small_matrix[y][x])

    5.times do |ix|
      5.times do |iy|
        nv = small_matrix[y][x] + ix + iy
        if nv > 9
          nv -= 9
        end

        nx = x + (row.length * ix)
        ny = y + (small_matrix.length * iy)

        matrix[ny] ||= []
        matrix[ny][nx] = Cell.new(nx, ny, nv)
      end
    end
  end
end

grid = Grid.new(matrix)
puts "Input: #{matrix.length}x#{matrix.first.length}"

pathfinder = Pathfinder.new(grid)

best_path = pathfinder.best_path
puts "Best path: #{best_path}"
puts "Risk: #{best_path.total_risk}"
