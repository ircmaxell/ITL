
require "./parser.rb"
require "./compiler.rb"
require "./runtime.rb"
require "pp"
require "pry"

code = '
    load "./main.itl"
    def :a (add 1 2)
    def :b (+ 1 2)
    def :c (* 2 2)
    + a (b + c)
'

pp Runtime.new.parseAndRun(code)