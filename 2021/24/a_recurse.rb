#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'

UnknownOpError = Class.new(StandardError)
InputExhaustedError = Class.new(StandardError)

def timer(msg)
  t = Time.now
  yield.tap do
    dt = 1000 * (Time.now - t)
    puts "#{msg} (#{dt.round(3)}ms)"
  end
end

class Instruction
  attr_reader :op, :args, :target

  PROCS = {
    inp: proc { |alu, _| alu.input },
    addv: proc { |_, slots| slots[args[0]] + slots[args[1]] },
    addi: proc { |_, slots| slots[args[0]] + args[1] },
    mulv: proc { |_, slots| slots[args[0]] * slots[args[1]] },
    muli: proc { |_, slots| slots[args[0]] * args[1] },
    divv: proc { |_, slots| slots[args[0]] / slots[args[1]] },
    divi: proc { |_, slots| slots[args[0]] / args[1] },
    modv: proc { |_, slots| slots[args[0]] % slots[args[1]] },
    modi: proc { |_, slots| slots[args[0]] % args[1] },
    eqlv: proc { |_, slots| slots[args[0]] == slots[args[1]] ? 1 : 0 },
    eqli: proc { |_, slots| slots[args[0]] == args[1] ? 1 : 0 },
    notv: proc { |_, slots| slots[args[0]] != slots[args[1]] ? 1 : 0 },
    noti: proc { |_, slots| slots[args[0]] != args[1] ? 1 : 0 },
    setv: proc { |_, slots| slots[args[1]] },
    seti: proc { |_, slots| args[1] },
    zer: proc { |_, _| 0 },

    zeraddvmodiaddinotv: proc { |_, slots| binding.pry },
  }

  def initialize(op, *args)
    @op = op.to_sym
    @args = args.map do |arg|
      if arg.is_a?(String)
        if arg.match?(/^[wxyz]$/)
          arg.to_sym
        else
          arg.to_i
        end
      else
        arg
      end
    end
    @target = @args[0]

    define_singleton_method(:call, &(PROCS[@op] || proc { |_, _| raise UnknownOpError, @op }))
  end

  def to_s
    "#{op} #{args.join(' ')}"
  end
end

class Alu
  attr_reader :instructions, :slots

  def initialize(instructions)
    @instructions = optimize(instructions)
  end

  def optimize(instructions)
##  instructions = instructions.reject do |ins|
##    ins.op == :div && ins.args.last == 1
##  end

##  instructions = instructions.map do |ins|
##    if ins.op == :mul && ins.args[1] == 0
##      Instruction.new(:zer, ins.target)
##    else
##      ins
##    end
##  end

##  instructions = instructions.each_with_index.map do |ins, i|
##    peek_backward = instructions[i-1]
##    peek_forward = instructions[i+1]

##    if ins.op == :eql && peek_forward&.op == :eql && ins.target == peek_forward&.target && peek_forward&.args[1] == 0
##      Instruction.new(:not, *ins.args)
##    elsif ins.op == :eql && peek_backward&.op == :eql && ins.target == peek_backward&.target && ins.args[1] == 0
##      nil
##    elsif ins.op == :zer && peek_forward&.op == :add && ins.target == peek_forward&.target
##      nil
##    elsif ins.op == :add && peek_backward&.op == :zer && ins.target == peek_backward&.target
##      Instruction.new(:set, *ins.args)
##    else
##      ins
##    end
##  end.compact

    instructions.map! do |ins|
      spec_op = if ins.args.length > 1
                  if ins.args.last.is_a?(Symbol)
                    (ins.op.to_s + 'v').to_sym
                  else
                    (ins.op.to_s + 'i').to_sym
                  end
                end

      if spec_op
        Instruction.new(spec_op, *ins.args)
      else
        ins
      end
    end

    instructions
  end

  def run(input, slots={w: 0, x: 0, y: 0, z: 0})
    @input = input.to_s.chars.map(&:to_i)
    @slots = slots

    @instructions.each do |ins|
      @slots[ins.target] = ins.call(self, @slots)
    end

    return slots[:z]
  end

  def input
    @input.shift || raise(InputExhaustedError)
  end
end

instructions = []
File.readlines('input.txt', chomp: true).each do |line|
  op, *args = line.split(/\s+/)
  instructions << Instruction.new(op, *args)
end

chunked_instructions = instructions.chunk_while do |a, b|
  b.op != :inp
end.to_a
digit_instructions = 14.times.map { |i| chunked_instructions[i] }

alus = { complete: Alu.new(instructions) }
1.upto(14) do |d|
  alus[d] = Alu.new(digit_instructions[d-1])
end

#inputs = {}
#14.downto(1) do |d|
#  ap d
#  alu = alus[d]
#
#  targets = if d == 14
#              {0 => true}
#            else
#              inputs[d+1].values.flatten.to_h { |t| [t[:input_z], true] }
#            end
#
#  z_inputs = if d == 1
#               Range.new(0, 0)
#             else
#               Range.new(0, 500_000)
#             end
#
#  binding.pry if d == 1
#
#  1.upto(9) do |n|
#    inputs[d] ||= {}
#    inputs[d][n] ||= []
#
#    z_inputs.each do |i|
#      res = alu.run(n, { w: 0, x: 0, y: 0, z: i })
#      if targets.include?(res)
#        inputs[d][n] << { input_z: i, output_z: res }
#      end
#    end
#  end
#end
#
#ap inputs

def solve(alus, number, zinput)
  ap "solve(alus, #{number}, #{zinput})"

  ndigit = 14 - number.length
  return number if ndigit.zero? && zinput.zero?
  return if ndigit < 1

  alu = alus[ndigit]

  9.downto(1).each do |next_digit|
    next_zinput = alu.run(next_digit, {w: 0, x: 0, y: 0, z: zinput})

    if d = solve(alus, [next_digit]+number, next_zinput)
      return d
    end
  end

  nil
end

ap solve(alus, [], 0)
