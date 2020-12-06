#!/usr/bin/env ruby

class Password
  def initialize(pos1, pos2, char, password)
    @positions = [pos1, pos2]
    @char = char
    @password = password
  end

  def valid?
    @positions.count { |pos| @password[pos - 1] == @char } == 1
  end
end

class Validator
  def initialize(strings)
    @passwords = strings.map do |str|
      pos1, pos2, char, password = str.scan(/^(\d+)-(\d+)\s+(\w):\s+(\w+)/).first
      Password.new(pos1.to_i, pos2.to_i, char, password)
    end
  end

  def count_valid
    @passwords.count(&:valid?)
  end
end

puts Validator.new(File.readlines('passwords')).count_valid
