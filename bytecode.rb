
module Itl
	module Bytecode
		class Bytecode 
			def is_literal?()
				false
			end
            def is_argument?()
                false
            end
		end

		class DeclareFunc < Bytecode

		end

		class FuncCall < Bytecode
            def exec(env)
                call = env.func_call_stack.pop()
                if call[:func].respond_to? :call
                    # regular function
                    env.result = call[:func].call(call[:args], env)
                elsif call[:args][0].respond_to? :call
                    # infix notation
                    newCall = call.clone
                    newCall[:func] = call[:args][0]
                    newCall[:args][0] = call[:func]
                    env.result = newCall[:func].call(newCall[:args], env)
                else
                    raise "Unknown function found #{call[:func]}"
                end
            end
		end

		class NoOp < Bytecode
		end

		class LiteralLookup < Bytecode
		end

		class BeginFuncCall < Bytecode
            def exec(env)
                env.func_call_stack.push()
                env.func_call_stack.func = env.result
            end
		end

		class Block < Bytecode
            def initialize(bytecode)
                @args = []
                @body = []
                bytecode.each do |code|

                    if code.is_argument?
                        @args.push code
                    else
                        @body.push code
                    end
                end
            end
            def exec(env)
                env.result = env.function.new(
                    env,
                    @body,
                    @args.map {|arg| env.function.arg(arg.name, arg.is_symbol?)}
                )
            end
		end

		class Argument < Bytecode
			def initialize(name)
				@name = name
			end
            def name()
                @name
            end
            def is_symbol?()
                false
            end
            def is_argument?()
                true
            end
		end

		class Symbol < Bytecode
			def initialize(name)
				@name = name
			end 
            def exec(env)
                env.result = @name
            end
		end

		class ArgumentFetch < Bytecode
            def initialize(idx)
                @idx = idx
            end
            def exec(env)
                env.func_call_stack.arg(@idx, env.result)
            end
		end

		class IntegerLiteral < Bytecode
			def initialize(value)
				@value = Integer(value)
			end
			def is_literal?()
				true
			end
            def exec(env)
                env.result = @value
            end
		end

        class StringLiteral < Bytecode
            def initialize(value)
                @value = String(value)
            end
            def is_literal?()
                true
            end
            def exec(env)
                env.result = @value
            end
        end

		class Identifier < Bytecode
			def initialize(value)
				@value = value
			end
            def exec(env)
                env.result = env.get(@value)
            end
		end

	end
end