#!/usr/bin/env ruby

require 'awesome_print'

class Grid
  attr_reader :grid

  def initialize(grid)
    @grid = grid
  end

  def low_points
    [].tap do |low_points|
      grid.each_with_index do |row, x|
        row.each_with_index do |cell, y|
          adj = [
            grid.dig(x - 1, y),
            grid.dig(x + 1, y),
            grid.dig(x, y - 1),
            grid.dig(x, y + 1),
          ].compact

          if adj.all? { |ac| ac.height > cell.height }
            low_points << cell
          end
        end
      end
    end
  end

  class Cell
    attr_reader :x, :y, :height

    def initialize(x:, y:, height:)
      @x = x
      @y = y
      @height = height
    end

    def risk_value
      @height + 1
    end
  end
end

grid = File.readlines('input.txt', chomp: true).each_with_index.map do |string, x|
  string.split(//).map(&:to_i).each_with_index.map do |height, y|
    Grid::Cell.new(x: x, y: y, height: height)
  end
end

grid = Grid.new(grid)

puts grid.low_points.sum(&:risk_value)
