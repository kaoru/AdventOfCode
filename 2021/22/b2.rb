#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'

class Cube
  attr_reader :action, :xrange, :yrange, :zrange

  def initialize(action, xrange, yrange, zrange)
    @action = action
    @xrange, @yrange, @zrange = xrange, yrange, zrange
    @subtract = []
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

  def inverse_action
    if on?
      'off'
    else
      'on'
    end
  end

  def volume_multiplier
    if on?
      1
    else
      -1
    end
  end

  def use?
    safety.cover?(xrange) && safety.cover?(yrange) && safety.cover?(zrange)
  end

  def safety
    Range.new(-50, 50)
  end

  def volume
    (volume_multiplier * xrange.size * yrange.size * zrange.size) + @subtract.sum(&:volume)
  end

  def intersects?(other)
    return false if xrange.min > other.xrange.max || other.xrange.min > xrange.max
    return false if yrange.min > other.yrange.max || other.yrange.min > yrange.max
    return false if zrange.min > other.zrange.max || other.zrange.min > zrange.max
    true
  end

  def intersect(other)
    return unless intersects?(other)

    xr = Range.new([xrange.min, other.xrange.min].max, [xrange.max, other.xrange.max].min)
    yr = Range.new([yrange.min, other.yrange.min].max, [yrange.max, other.yrange.max].min)
    zr = Range.new([zrange.min, other.zrange.min].max, [zrange.max, other.zrange.max].min)

    sub = Cube.new(inverse_action, xr, yr, zr)
    @subtract.each do |s|
      s.intersect(sub)
    end
    @subtract << sub
  end
end

class Reactor
  def initialize
    @cubes = []
  end

  def add(cube)
    @cubes.each do |other|
      other.intersect(cube)
    end

    if cube.on?
      @cubes << cube
    end
  end

  def cubes_on
    @cubes.sum(&:volume)
  end
end

cubes = []
File.readlines('input.txt', chomp: true).each do |line|
  action, xmin, xmax, ymin, ymax, zmin, zmax = line.scan(/^(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)/).first

  cubes << Cube.new(action, Range.new(xmin.to_i, xmax.to_i), Range.new(ymin.to_i, ymax.to_i), Range.new(zmin.to_i, zmax.to_i))
end

reactor = Reactor.new

cubes.each do |cube|
  puts cube
  reactor.add(cube)
  puts reactor.cubes_on
end
