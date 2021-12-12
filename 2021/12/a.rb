#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'

class Cave
  attr_reader :name, :links

  def initialize(name)
    @name = name
    @links = []
  end

  def small?
    name.match?(/[a-z]/)
  end

  def big?
    name.match?(/[A-Z]/)
  end

  def to_s
    name
  end
  alias inspect to_s

  def link(other)
    @links << other
  end

  def paths_to(destination)
    paths = []

    pathfinder(destination, [], paths)

    paths
  end

  def pathfinder(destination, path, paths)
    path << self
    paths << path if self == destination

    links.each do |next_cave|
      next if next_cave.small? && path.include?(next_cave)

      #ap "Path finding from #{self} to #{next_cave} on path #{path.join(',')}"

      next_cave.pathfinder(destination, path.dup, paths)
    end
  end
end

caves = {}

File.readlines('input.txt', chomp: true).each do |line|
  pair = line.split(/-/)

  pair.each do |cave|
    caves[cave] ||= Cave.new(cave)
  end

  pair.permutation(2).each do |a, b|
    caves[a].link(caves[b])
  end
end

start_cave = caves['start']
end_cave = caves['end']

paths = start_cave.paths_to(end_cave)

paths.each do |path|
  puts path.join(',')
end

puts "Found #{paths.count} paths"
