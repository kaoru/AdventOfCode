#!/usr/bin/env ruby

require 'awesome_print'

class Cell
  attr_reader :number

  def initialize(n)
    @number = n
    @marked = false
  end

  def mark!
    @marked = true
  end

  def marked?
    @marked
  end

  def to_s
    format("%3d", number)
  end
  alias inspect to_s
end

class Board
  attr_reader :board, :rows, :columns, :cells

  def initialize(board_string)
    @board = board_string.lines.map do |line|
      line.split.map(&:to_i).map do |n|
        Cell.new(n)
      end
    end

    @rows = @board
    @columns = @board.transpose
    @cells = @rows.flatten
  end

  def mark(n)
    cells.each do |cell|
      cell.mark! if cell.number == n
    end
  end

  def winner?
    if @rows.any? { |row| row.all? { |cell| cell.marked? } }
      true
    elsif @columns.any? { |column| column.all? { |cell| cell.marked? } }
      true
    else
      false
    end
  end

  def score
    @cells.reject(&:marked?).map(&:number).sum
  end
end

input = File.readlines('input.txt').map(&:chomp)

called_numbers = input.shift.split(/\s*,\s*/).map(&:to_i)

boards = input.join("\n").split(/\n\n/).map(&:strip).map do |board_string|
  Board.new(board_string)
end

called_numbers.each do |called_number|
  boards.each do |board|
    board.mark(called_number)

    if board.winner?
      puts "Winner!"
      puts called_number

      score = board.score
      puts score

      puts score * called_number
      exit
    end
  end
end
