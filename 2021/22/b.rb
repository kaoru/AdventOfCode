#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'

class Instruction
  attr_reader :action, :cube

  def initialize(action, cube)
    @action = action
    @cube = cube
  end

  def to_s
    "#{action} x=#{cube.xrange},y=#{cube.yrange},z=#{cube.zrange}"
  end

  def on?
    action == 'on'
  end

  def off?
    action == 'off'
  end

  def use?
    safety.cover?(cube.xrange) && safety.cover?(cube.yrange) && safety.cover?(cube.zrange)
  end

  def safety
    Range.new(-50, 50)
  end
end

class Cube
  attr_reader :xrange, :yrange, :zrange

  def initialize(xrange, yrange, zrange)
    @xrange, @yrange, @zrange = xrange, yrange, zrange
  end

  def to_s
    "#{xrange},#{yrange},#{zrange}"
  end

  def size
    xrange.size * yrange.size * zrange.size
  end

  def overlap(other)
    xr = Range.new([xrange.min, other.xrange.min].max, [xrange.max, other.xrange.max].min)
    yr = Range.new([yrange.min, other.yrange.min].max, [yrange.max, other.yrange.max].min)
    zr = Range.new([zrange.min, other.zrange.min].max, [zrange.max, other.zrange.max].min)

    Cube.new(xr, yr, zr) if xr.any? && yr.any? && zr.any?
  end
end

class Cubes
  def initialize
    @cubes = []
    @adjustment_cubes = []
  end

  def execute(instruction)
    cube = { cube: instruction.cube, on: instruction.on? }
    adjustment_cubes = []

    cubes = @cubes.select { |c| c[:on] == instruction.on? }.product([cube])
    while (overlaps = cubes.map { |a, b| a[:cube].overlap(b[:cube]) }.compact.map { |c| { cube: c, on: !instruction.on? } }).any?
      adjustment_cubes += overlaps
      ap adjustment_cubes.count

      cubes = overlaps.map { |c| { cube: c[:cube], on: !c[:on] } }.combination(2)
    end

    @cubes << cube
    @adjustment_cubes += adjustment_cubes
  end

  def count
    (@cubes + @adjustment_cubes).map do |cube|
      (cube[:on] ? 1 : - 1) * cube[:cube].size
    end.sum
  end
end

instructions = []
File.readlines('input.txt', chomp: true).each do |line|
  action, xmin, xmax, ymin, ymax, zmin, zmax = line.scan(/^(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)/).first

  instructions << Instruction.new(action, Cube.new(Range.new(xmin.to_i, xmax.to_i), Range.new(ymin.to_i, ymax.to_i), Range.new(zmin.to_i, zmax.to_i)))
end

instructions.select!(&:use?)

cubes = Cubes.new

instructions.each do |instruction|
  puts instruction
  cubes.execute(instruction)
  puts cubes.count
end
