#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'

class Submarine
  attr_reader :scanners

  def initialize(scanners)
    @scanners = scanners
  end

  def beacons
    compared = Hash.new(false)

    loop do
      scanners.each do |s1|
        scanners.each do |s2|
          ids = [s1, s2].map(&:id).sort.join('+')
          if s1.located? && !s2.located? && !compared[ids]
            ap "Comparing #{s1} to #{s2}"
            compared[ids] = true
            s1.combine(s2)
          end
        end
      end

      if scanners.all?(&:located?)
        ap "Scanner locations: #{scanners.map(&:coords)}"
        ap "Unique beacons: #{scanners.flat_map { |s| s.beacons_relative_to_origin }.map(&:coords).uniq.count}"
        ap "Max Manhattan distance between scanners: #{scanners.combination(2).max_by { |s1, s2| s1.distance_to(s2) }.then { |s1, s2| "#{s1} and #{s2} are #{s1.distance_to(s2)} away" } }"
        return
      end
    end
  end
end

class Scanner
  attr_reader :id, :beacons
  attr_reader :x, :y, :z

  def initialize(id)
    @id = id
    @beacons = []
    set_location(0, 0, 0) if id.zero?
  end

  def set_location(x, y, z)
    @x, @y, @z = x, y, z
  end

  def distance_to(other)
    coords.zip(other.coords).map do |c1, c2|
      (c1-c2).abs
    end.sum
  end

  def set_beacons(beacons)
    @beacons = beacons
    @rotations = nil
  end

  def beacons_relative_to_origin
    beacons.map do |beacon|
      Beacon.new(x+beacon.x, y+beacon.y, z+beacon.z)
    end
  end

  def located?
    x && y && z
  end

  def coords
    [x,y,z]
  end

  def add_beacon(beacon)
    @beacons << beacon
  end

  def rotations
    @rotations ||= beacons.map(&:rotations).transpose
  end

  def combine(other)
    other.rotations.each do |other_rotated_beacons|
      beacons.each do |b1|
        other_rotated_beacons.each do |b2|
          dx, dy, dz = b1.x-b2.x, b1.y-b2.y, b1.z-b2.z

          relative = other_rotated_beacons.map do |b3|
            Beacon.new(b3.x+dx, b3.y+dy, b3.z+dz)
          end

          if (beacons.map(&:coords) & relative.map(&:coords)).count >= 12
            other.set_location(x+dx, y+dy, z+dz)
            other.set_beacons(other_rotated_beacons)
            return
          end
        end
      end
    end
  end

  def to_s
    "scanner #{id}"
  end
end

class Beacon
  attr :x, :y, :z

  def initialize(x, y, z)
    @x, @y, @z = x, y, z
  end

  def coords
    [x,y,z]
  end

  def rotations
    [].tap do |rs|
      v = self

      2.times do |cycle|
        3.times do |step|
          v = v.roll
          rs << v

          3.times do |i|
            v = v.turn
            rs << v
          end
        end
        v = v.roll.turn.roll
      end
    end
  end

  def roll
    Beacon.new(x, z, -y)
  end

  def turn
    Beacon.new(-y, x, z)
  end

  def to_s
    coords.join(',')
  end
end

scanners = []
File.readlines('input.txt', chomp: true).each do |line|
  if line.match?(/^---/)
    id = line.scan(/^--- scanner (\d+) ---$/).first.first.to_i
    scanners << Scanner.new(id)
  elsif line.match?(/,/)
    beacon = Beacon.new(*line.split(/,/).map(&:to_i))
    scanners.last.add_beacon(beacon)
  end
end

Submarine.new(scanners).beacons
