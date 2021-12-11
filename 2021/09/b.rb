#!/usr/bin/env ruby

require 'awesome_print'

class Grid
  attr_reader :grid, :cells

  def initialize(grid)
    @grid = grid
    @cells = grid.flatten
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

  def basins
    low_points.each do |low_point|
      populate(low_point, low_point.to_s, low_point.height)
    end

    cells.group_by(&:basin).except('none').values
  end

  def populate(cell, basin, height)
    return if cell.basin
    return unless cell.height >= height

    cell.basin = basin

    x, y = cell.x, cell.y

    adj = [
      grid.dig(x - 1, y),
      grid.dig(x + 1, y),
      grid.dig(x, y - 1),
      grid.dig(x, y + 1),
    ].compact

    adj.each do |adj_cell|
      populate(adj_cell, basin, cell.height)
    end
  end

  class Cell
    attr_reader :x, :y, :height
    attr_accessor :basin

    def initialize(x:, y:, height:)
      @x = x
      @y = y
      @height = height
      if @height == 9
        @basin = 'none'
      end
    end

    def to_s
      "(#{[x, y, height].join(',')})"
    end
  end
end

grid = File.readlines('input.txt', chomp: true).each_with_index.map do |string, x|
  string.split(//).map(&:to_i).each_with_index.map do |height, y|
    Grid::Cell.new(x: x, y: y, height: height)
  end
end

grid = Grid.new(grid)

basins = grid.basins

puts basins.map(&:size).sort.last(3).reduce(1, :*)
