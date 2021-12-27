#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'

class Algorithm
  def initialize(algorithm)
    @algorithm = algorithm
  end

  def to_s
    @algorithm
  end

  def [](idx)
    @algorithm[idx]
  end
end

class Image
  def initialize(grid)
    @grid = grid
  end

  def to_s
    @grid.map do |row|
      row.join
    end.join("\n")
  end

  def lit_pixels
    @grid.map do |row|
      row.map do |cell|
        cell == '#' ? 1 : 0
      end.sum
    end.sum
  end

  def dup
    self.class.new(@grid.map(&:dup))
  end

  def enhance(algorithm)
    new_image = dup

    new_image.embiggen!
    new_image.embiggen!
    new_image.embiggen!
    new_image.embiggen!
    new_image.embiggen!
    new_image.embiggen!

    new_image.apply!(algorithm)

    new_image.strip!

    new_image
  end

  def apply!(algorithm)
    new_grid = @grid.map(&:dup)

    @grid.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        nvs = neighbour_values(i, j)
        idx = nvs.map { |v| v == '#' ? 1 : 0 }.join.to_i(2)
        new_grid[i][j] = algorithm[idx]
      end
    end

    @grid = new_grid
  end

  def neighbour_values(i, j)
    [
      cell_value(i-1, j-1), cell_value(i-1, j), cell_value(i-1, j+1),
      cell_value(i, j-1), cell_value(i, j), cell_value(i, j+1),
      cell_value(i+1, j-1), cell_value(i+1, j), cell_value(i+1, j+1),
    ]
  end

  def cell_value(i, j)
    if 0 > i || i >= @grid.length
      @grid[0][0]
    elsif 0 > j || j >= @grid.first.length
      @grid[0][0]
    else
      @grid[i][j]
    end
  end

  def embiggen!
    field = @grid[0][0]

    @grid.each do |row|
      row.unshift(field)
      row.push(field)
    end

    @grid.unshift(Array.new(@grid.first.length) { field })
    @grid.push(Array.new(@grid.first.length) { field })

    self
  end

  def strip!
    2.times do
      @grid.each do |row|
        if row.all? { |cell| cell == '.' }
          @grid.delete(row)
        end
      end

      @grid = @grid.transpose
    end

    self
  end
end

algorithm, image = File.read('input.txt').split("\n\n")
algorithm.delete!("\n")
grid = image.split("\n").map(&:chars)

algorithm = Algorithm.new(algorithm)
image = Image.new(grid)
puts algorithm
puts
puts image
puts '-' * 78

2.times do
  image = image.enhance(algorithm)
  puts image
  puts "Lit pixels: #{image.lit_pixels}"
  puts '-' * 78
end
