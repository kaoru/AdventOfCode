#!/usr/bin/env ruby

require 'awesome_print'

class Octopus
  attr_reader :x, :y, :energy
  attr_accessor :adj

  def initialize(x, y, energy)
    @x = x
    @y = y
    @energy = energy
    @flashed = false
  end

  def up
    @energy += 1
  end

  def flash
    @flashed = true
  end

  def flashed?
    @flashed
  end

  def reset
    @energy = 0
    @flashed = false
  end
end

class Grid
  attr_reader :grid, :octopodes, :flashes

  def initialize(grid)
    @grid = grid
    @octopodes = grid.flatten
    @flashes = 0
  end

  def to_s
    grid.map do |row|
      row.map(&:energy).join
    end.join("\n")
  end
  alias inspect to_s

  def step
    # First, the energy level of each octopus increases by 1
    octopodes.each(&:up)

    # Then, any octopus with an energy level greater than 9 flashes. This
    # increases the energy level of all adjacent octopuses by 1, including
    # octopuses that are diagonally adjacent. If this causes an octopus to have
    # an energy level greater than 9, it also flashes. This process continues
    # as long as new octopuses keep having their energy level increased beyond
    # 9. (An octopus can only flash at most once per step.)
    while (fs = flashers).any?
      fs.each do |f|
        flash(f)
        adjacent(f).each do |o|
          o.up
        end
      end
    end

    # Finally, any octopus that flashed during this step has its energy level
    # set to 0, as it used all of its energy to flash.
    octopodes.each do |o|
      o.reset if o.flashed?
    end
  end

  def flashers
    octopodes.select do |octopus|
      octopus.energy > 9 && !octopus.flashed?
    end
  end

  def flash(octopus)
    octopus.flash
    @flashes += 1
  end

  def adjacent(octopus)
    directions.map do |dx, dy|
      x, y = octopus.x + dx, octopus.y + dy

      if x.negative? || y.negative?
        nil
      else
        grid.dig(x, y)
      end
    end.compact end

  def directions
    @directions ||= -1.upto(1).flat_map { |x| -1.upto(1).map { |y| [x, y] } }.reject { |d| d == [0, 0] }
  end
end

grid = []

File.readlines('input.txt', chomp: true).each_with_index do |line, x|
  line.chars.map(&:to_i).each_with_index do |energy, y|
    grid[x] ||= []
    grid[x][y] = Octopus.new(x, y, energy)
  end
end

grid = Grid.new(grid)

100.times do
  grid.step
end

puts grid.flashes
