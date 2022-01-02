#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'

class Grid
  attr_reader :grid, :xsize, :ysize, :last_moves

  def initialize(grid, last_moves=nil)
    @grid = grid
    @last_moves = last_moves
    @xsize = grid.first.size
    @ysize = grid.size
  end

  def move
    Grid.new(next_grid, last_moves)
  end

  def to_s
    grid.map do |row|
      row.join
    end.join("\n")
  end

  private

  def next_grid
    next_grid = grid.map(&:dup)

    east_movers = []

    next_grid.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        next if cell != '>'
        next if right(x, y, next_grid) != '.'
        east_movers << [x, y]
      end
    end

    east_movers.each do |x, y|
      next_grid[y][x] = '.'
      right(x, y, next_grid).replace('>')
    end

    south_movers = []

    next_grid.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        next if cell != 'v'
        next if down(x, y, next_grid) != '.'
        south_movers << [x, y]
      end
    end

    south_movers.each do |x, y|
      next_grid[y][x] = '.'
      down(x, y, next_grid).replace('v')
    end

    @last_moves = east_movers.count + south_movers.count

    return next_grid
  end

  def right(x, y, g=grid)
    g[y][(x + 1) % xsize]
  end

  def down(x, y, g=grid)
    g[(y + 1) % ysize][x]
  end
end

grid = []
File.readlines('input.txt', chomp: true).each do |line|
  grid << line.chars
end

grid = Grid.new(grid)
puts ">>> initial <<<"
puts grid
puts

n = 1
until grid.last_moves == 0
  puts ">>> #{n} <<<"
  grid = grid.move
  puts grid
  puts "Moves: #{grid.last_moves}"
  puts
  n += 1
end
