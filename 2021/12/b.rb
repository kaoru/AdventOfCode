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
    return false if special?
    name.match?(/[a-z]/)
  end

  def big?
    return false if special?
    name.match?(/[A-Z]/)
  end

  def start?
    name == 'start'
  end

  def special?
    ['start', 'end'].include?(name)
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

    if self == destination
      paths << path
      return
    end

    links.each do |next_cave|
      next if next_cave.start?

      if next_cave.small?
        small_visits = path.select(&:small?).tally
        small_visits[next_cave] ||= 0
        next unless (small_visits[next_cave] < 1) || (small_visits[next_cave] < 2 && small_visits.values.select { |v| v > 1 }.count == 0)
      end

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
