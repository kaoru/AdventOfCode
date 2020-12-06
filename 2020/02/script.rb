#!/usr/bin/env ruby

class Password
  def initialize(min, max, char, password)
    @min = min
    @max = max
    @char = char
    @password = password
  end

  def valid?
    @min <= char_count && char_count <= @max
  end

  def char_count
    letters.fetch(@char, 0)
  end

  def letters
    @letters ||= @password.chars.tally
  end
end

class Validator
  def initialize(strings)
    @passwords = strings.map do |str|
      min, max, char, password = str.scan(/^(\d+)-(\d+)\s+(\w):\s+(\w+)/).first
      Password.new(min.to_i, max.to_i, char, password)
    end
  end

  def count_valid
    @passwords.count(&:valid?)
  end
end

puts Validator.new(File.readlines('passwords')).count_valid
