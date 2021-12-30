#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'

class Move
  attr_reader :mover, :from, :to, :distance

  def initialize(mover, from, to, distance)
    @mover = mover
    @from = from
    @to = to
    @distance = distance
  end

  def id
    "#{mover}-#{from.id}-#{to.id}"
  end

  def to_s
    "#{mover} moves from #{from.id} to #{to.id}, using #{energy} energy"
  end

  def costs
    { 'A' => 1, 'B' => 10, 'C' => 100, 'D' => 1000 }
  end

  def energy
    distance * costs[mover]
  end

  def execute
    from.occupant = nil
    to.occupant = mover
  end

  def undo
    from.occupant = mover
    to.occupant = nil
  end

  def visitable?
    if to.corridor? && to.down.room?
      false
    elsif to.room? && (to.home != mover)
      false
    elsif to.room? && to.down.room? && (!to.down.occupied? || (to.down.occupant != to.down.home))
      false
    elsif from.corridor? && to.corridor?
      false
    else
      true
    end
  end
end

class Cell
  attr_reader :type, :char, :occupant

  attr_accessor :home
  attr_accessor :up, :right, :down, :left
  attr_accessor :number

  def initialize(char:)
    @char = char

    if @char.match?(/^[A-Z]$/)
      @type = :room
      @occupant = char
    elsif @char == '.'
      @type = :corridor
    elsif @char == '#' || @char == ' '
      @type = :wall
    end
  end

  def occupant=(occ)
    if occ
      @occupant = occ
      @char = occ
    else
      @occupant = nil
      @char = '.'
    end
  end

  def neighbours
    [up, right, down, left]
  end

  def moves
    traversables.select { |m| m.visitable? }
  end

  def traversables(mover=occupant, source=self, seen={}, distance=0)
    seen[self] = true
    neighbours.select(&:traversable?)
      .reject { |n| seen[n] }
      .flat_map { |n| [Move.new(mover, source, n, distance + 1)] + n.traversables(mover, source, seen, distance + 1) }
  end

  def traversable?
    !wall? && !occupied?
  end

  def room?
    @type == :room
  end

  def corridor?
    @type == :corridor
  end

  def wall?
    @type == :wall
  end

  def occupied?
    !!@occupant
  end

  def done?
    if occupied?
      (occupant == home) && down.done?
    else
      true
    end
  end

  def id
    @id ||= "#{type.to_s[0].upcase}#{number}"
  end

  def to_s
    @char
  end

  def inspect
    to_s
  end
end

class World
  attr_reader :corridor, :amphs, :grid

  def initialize(corridor:, amphs:)
    @corridor = corridor
    @amphs = amphs

    @grid = [
      '#' * (corridor + 2),
      '#' + ('.' * corridor) + '#',
      '###' + amphs.first.join('#') + '###',
      amphs.slice(1, amphs.length).map do |row|
        '  #' + row.join('#') + '#  '
      end,
      '  ' + ('#' * (corridor - 2)) + '  ',
    ].flatten.map(&:chars)

    @grid.each do |row|
      row.each_with_index do |char, i|
        row[i] = Cell.new(char: char)
      end
    end

    homes = amphs.flatten.uniq.sort
    grid.flatten.select(&:room?).each_slice(homes.count).to_a.transpose.zip(homes).each do |rooms, home|
      rooms.each { |room| room.home = home }
    end

    grid.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        cell.up = grid[i-1][j] if i > 0
        cell.right = grid[i][j+1] if j < (row.length-1)
        cell.down = grid[i+1][j] if i < (grid.length-1)
        cell.left = grid[i][j-1] if j > 0
      end
    end

    cells.each_with_index do |cell, n|
      cell.number = n + 1
    end
  end

  def cells
    grid.flatten
  end

  def solve
    winning_moves = []
    play(winning_moves)
    winning_moves.map { |moves| moves.sum(&:energy) }.sort.first
  end

  def play(winning_moves, moves=[])
    energy_sum = moves.sum(&:energy)

    @seen ||= {}

    return if energy_sum >= (@seen[state] || Float::INFINITY)
    return if energy_sum >= (@best_energy || Float::INFINITY)

    @seen[state] = energy_sum

    return true if cells.all?(&:done?)

    next_moves = possible_moves.reject do |move|
      moves.any? && moves.last.to == move.from
    end
    if next_moves.none?
      return
    end

    next_moves.each do |move|
      moves << move
      #puts to_s(move)
      move.execute

      if play(winning_moves, moves)
        winning_moves << moves.dup
        @best_energy = moves.sum(&:energy)
        puts "Winner!"
        puts moves
        puts @best_energy
        puts
      end
      
      moves.pop.undo
    end

    nil
  end

  def possible_moves
    cells.select(&:occupied?).reject(&:done?).flat_map(&:moves)
  end

  def state
    grid.map(&:join).join
  end

  def to_s(move=nil)
    grid.map do |row|
      row.map do |cell|
        if move
          if move.from == cell
            cell.to_s.green
          elsif move.to == cell
            cell.to_s.red
          else
            cell
          end
        else
          cell
        end
      end.join
    end.join("\n")
  end

  def inspect
    grid.map { |row| row.map(&:inspect).join }.join("\n")
  end
end

corridor = 0
amphs = []
File.readlines('input.txt', chomp: true).each do |line|
  if line.match?(/^\#\.+\#$/)
    corridor = line.scan(/^\#(\.+)\#$/).first.first.length
  elsif line.match?(/\#[A-Z]\#/)
    amphs << line.scan(/\#([A-Z])/).map(&:first)
  end
end

world = World.new(corridor: corridor, amphs: amphs)
puts world
puts
puts world.solve
