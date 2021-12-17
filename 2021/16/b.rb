#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'

class Packet
  attr_reader :binary_string, :version, :type_id, :length_type_id, :subpackets, :literal

  def initialize(binary_string)
    @binary_string = binary_string
    parse!
  end

  def literal?
    type_id == 4
  end

  def parse!
    return if @parsed

    @pointer = 0
    @subpackets = []
    @version = extract_binary!(3)
    @type_id = extract_binary!(3)

    if literal?
      @literal = extract_literal!
    else
      @length_type_id = extract_binary!(1)

      case @length_type_id
      when 0
        length = extract_binary!(15)
        packets_data = extract_binary_string!(length)

        while packets_data && packets_data.length > 0
          packet = Packet.new(packets_data)
          @subpackets << packet
          packets_data = packet.remainder
        end
      when 1
        number_of_subpackets = extract_binary!(11)
        packets_data = extract_binary_string!(binary_string.length)

        number_of_subpackets.times do
          binding.pry if packets_data.nil?
          packet = Packet.new(packets_data)
          @subpackets << packet
          packets_data = packet.remainder
        end
        @pointer = binary_string.length - packets_data.length
      end
    end

    @parsed = true
  end

  def result
    case type_id
    when 0
      subpacket_results.sum
    when 1
      subpacket_results.reduce(1, :*)
    when 2
      subpacket_results.min
    when 3
      subpacket_results.max
    when 4
      @literal
    when 5
      subpacket_results.first > subpacket_results.last ? 1 : 0
    when 6
      subpacket_results.first < subpacket_results.last ? 1 : 0
    when 7
      subpacket_results.first == subpacket_results.last ? 1 : 0
    end
  end

  def subpacket_results
    subpackets.map(&:result)
  end

  def versions_sum
    version + subpackets.map(&:versions_sum).sum
  end

  def to_s
    binary_string
  end

  def inspect
    {
      b: binary_string,
      v: version,
      vs: versions_sum,
      t: type_id,
      i: length_type_id,
      s: subpackets.count,
      r: result,
    }
  end

  def extract_binary!(digits)
    extract_binary_string!(digits).to_i(2)
  end

  def extract_binary_string!(digits)
    binary_string.slice(@pointer, digits).tap do
      @pointer += digits
    end
  end

  def extract_literal!
    x = []
    loop do
      bits = extract_binary!(5)
      check = (bits & 0b10000) >> 4
      bits = bits & 0b01111

      x << bits

      if check.zero?
        return x.map { |n| n.to_s(2).rjust(4, '0') }.join.to_i(2)
      end
    end
  end

  def remainder
    binary_string.slice(@pointer, binary_string.length)
  end
end

File.readlines('input.txt', chomp: true).each do |line|
  binary_string = line.chars.map do |hex|
    hex.to_i(16).to_s(2).rjust(4, '0')
  end.join
  p = Packet.new(binary_string)
  ap p.result
end
