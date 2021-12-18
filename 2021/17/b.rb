#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'

class Target
  attr_reader :xrange, :yrange

  def initialize(xrange:, yrange:)
    @xrange = xrange
    @yrange = yrange
  end

  def hits
    shots = []

    0.upto(xrange.max) do |xv|
      yrange.min.upto(xrange.max) do |yv|
        if shot(xv, yv)
          shots << [xv, yv]
        end
      end
    end

    shots.length
  end

  def shot(xv, yv)
    input = "(#{xv}, #{yv})"
    n = 0

    x, y = 0, 0

    while xv != 0 || y > yrange.min
      n += 1

      x += xv
      y += yv

      if xv > 0
        xv -= 1
      else
        xv += 1
      end

      yv -= 1

      if xrange.cover?(x) && yrange.cover?(y)
        ap "Hit! With #{input} after #{n} steps"
        return true
      end
    end

    ap "Miss! With #{input} after #{n} steps"
    false
  end

  def to_s
    "target_area: x=#{xrange}, y=#{yrange}"
  end
end

File.readlines('input.txt', chomp: true).each do |line|
  xmin, xmax, ymin, ymax = line.scan(/^target area: x=([-\d]+)[.][.]([-\d]+), y=([-\d]+)[.][.]([-\d]+)/).first.map(&:to_i)

  target = Target.new(xrange: Range.new(xmin, xmax), yrange: Range.new(ymin, ymax))
  puts target
  ap target.hits
end
