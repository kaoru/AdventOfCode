#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'

class Paper
  attr_reader :grid

  def initialize
    @grid = []
  end

  def to_s
    grid.transpose.map do |row|
      row.join
    end.join("\n")
  end
  alias inspect to_s

  def mark_dot(x, y)
    expand(x, y)

    grid[x][y] = '#'
  end

  def visible_dots
    grid.map do |column|
      column.count do |cell|
        cell == '#'
      end
    end.sum
  end

  def fold(instruction)
    Paper.new.tap do |folded|
      x_size = grid.size - 1
      y_size = grid.first.size - 1

      if instruction.direction == :x
        x_size = instruction.lines - 1
      elsif instruction.direction == :y
        y_size = instruction.lines - 1
      end

      folded.expand(x_size, y_size)

      grid.each_with_index do |col, x|
        col.each_with_index do |cell, y|
          folded_y = if (instruction.direction == :y) && (y >= instruction.lines)
                       if y == instruction.lines
                         nil
                       else
                         instruction.lines - (y - instruction.lines)
                       end
                     else
                       y
                     end

          folded_x = if (instruction.direction == :x) && (x >= instruction.lines)
                       if x == instruction.lines
                         nil
                       else
                         instruction.lines - (x - instruction.lines)
                       end
                     else
                       x
                     end

          next if folded_x.nil? || folded_y.nil?

          if grid[x][y] == '#'
            folded.mark_dot(folded_x, folded_y)
          end
        end
      end
    end
  end

  def expand(x, y)
    return if x < (grid.size - 1) && y < (grid.first.size - 1)

    new_x_size = [x, grid.size - 1].max
    0.upto(new_x_size) do |xx|
      grid[xx] ||= []
    end

    new_y_size = [y, grid.first.size - 1].max
    grid.each do |row|
      0.upto(new_y_size) do |yy|
        row[yy] ||= '.'
      end
    end
  end
end

class Instruction
  attr_reader :direction, :lines

  def initialize(direction, lines)
    @direction = direction.to_sym
    @lines = lines.to_i
  end

  def to_s
    "fold along #{direction}=#{lines}"
  end
  alias inpsect to_s
end

paper = Paper.new
instructions = []

File.readlines('input.txt', chomp: true).each do |line|
  if line.match?(/^fold/)
    instructions << Instruction.new(*line.scan(/^fold along (\w+)=(\d+)$/).first)
  elsif line.match?(/,/)
    x, y = line.split(/,/).map(&:to_i)

    paper.mark_dot(x, y)
  end
end

puts instructions
puts '----------------------------'
#puts paper
puts "Visible dots: #{paper.visible_dots}"
puts '----------------------------'

folded = paper
instructions.each do |ins|
  puts "Folding: #{ins}"
  folded = folded.fold(ins)
  #puts folded
  puts "Visible dots: #{folded.visible_dots}"
  puts '----------------------------'
end

puts folded
