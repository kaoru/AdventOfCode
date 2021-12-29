#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'

class Instruction
  attr_reader :action, :xrange, :yrange, :zrange
  def initialize(action, xrange, yrange, zrange)
    @action = action
    @xrange, @yrange, @zrange = xrange, yrange, zrange
  end

  def to_s
    "#{action} x=#{xrange},y=#{yrange},z=#{zrange}"
  end

  def on?
    action == 'on'
  end

  def off?
    action == 'off'
  end

  def use?
    safety.cover?(xrange) && safety.cover?(yrange) && safety.cover?(zrange)
  end

  def safety
    Range.new(-50, 50)
  end
end

class Cubes
  def initialize
    @on = {}
  end

  def execute(instruction)
    instruction.xrange.each do |x|
      instruction.yrange.each do |y|
        instruction.zrange.each do |z|
          key = [x,y,z].join('-')
          if instruction.on?
            @on[key] = true
          else
            @on.delete(key)
          end
        end
      end
    end
  end

  def count
    @on.size
  end
end

instructions = []
File.readlines('input.txt', chomp: true).each do |line|
  action, xmin, xmax, ymin, ymax, zmin, zmax = line.scan(/^(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)/).first

  instructions << Instruction.new(
    action,
    Range.new(xmin.to_i, xmax.to_i),
    Range.new(ymin.to_i, ymax.to_i),
    Range.new(zmin.to_i, zmax.to_i)
  )
end

instructions.select!(&:use?)

cubes = Cubes.new

instructions.each do |instruction|
  puts instruction
  cubes.execute(instruction)
  puts cubes.count
end
