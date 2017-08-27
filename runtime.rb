

class Runtime
    include Itl::Bytecode

    def initialize()
        @globals = Env.new(self)
        @compiler = Compiler.new
        @parser = Parser.new
        load_default_functions
    end

    def load(file, env=@globals)
        parseAndRun(File.open(file, 'r').read, env)
    end

    def parseAndRun(code, env=@globals)
        bytecode = @compiler.compile @parser.parse(code)
        run bytecode
    end

    def run(bytecode, env=@globals)
        bytecode.each do |instruction|
            instruction.exec(env)
        end
        env.result
    end


	class Env
        def initialize(runtime, parent = nil)
            @runtime = runtime
            @symbol_table = Hash.new
            @result = nil
            @func_call_stack = FuncCallStack.new
            @parent = nil
        end
        def initialize_copy(copy)
            super(copy)
            @symbol_table = @symbol_table.clone
            @func_call_stack = FuncCallStack.new
        end
        def runtime()
            @runtime
        end
        def has?(key)
            @symbol_table.has_key? key
        end
        def set(key, value)
            @symbol_table.store(key, value)
        end
        def get(key)
            @symbol_table.fetch(key)
        end
        def result()
            @result
        end
        def result=(newResult)
            @result = newResult
        end
        def func_call_stack()
            @func_call_stack
        end
        def parent()
            @parent ? @parent : self
        end
        def function()
            Function
        end
        def symbol_table()
            @symbol_table   
        end
	end

    class FuncCallStack
        def initialize()
            @stack = []
        end
        def push()
            @stack.push({func: nil, args: []})
        end
        def pop()
            @stack.pop()
        end
        def func()
            @stack.last[:func]
        end
        def func=(newValue)
            @stack.last[:func] = newValue
        end
        def arg(idx, value)
            @stack.last[:args][idx] = value
        end
    end

    class Function
        def self.arg(name, is_symbol = false)
            {name: name, is_symbol: is_symbol}
        end
        def initialize(env, code, args, is_internal=false, is_variadic=false)
            @env = env
            @code = code
            @args = args
            @is_internal = is_internal
            @is_variadic = is_variadic
        end
        def call(args, env)
            if !@is_variadic && args.length != @args.length
                raise "Argument length mismatch, expecting #{@args.length} found #{args.length}"
            elsif @is_variadic && args.length < @args.length
                raise "Argument length mismatch, expecting at least #{@args.length} found #{args.length}"
            end
            processedArgs = @args.map.with_index do |arg, idx|
                value = args[idx]
                [arg[:name], value]
            end
            if @is_internal
                @code.call(env, *(processedArgs.map {|arg| arg[1]}))
            else
                local = @env.clone
                processedArgs.each do |arg|
                    local.set(arg[0], arg[1])
                end
                env.runtime.run(@code, local)
            end
        end
    end

    def load_default_functions()
        load_binary :+
        load_binary :-
        load_binary :*
        load_binary :/
        load_binary :<
        load_binary :>
        load_binary :==, "="
        @globals.set("def", Function.new(@globals, lambda{|env, name, value| env.set(name, value)}, [Function.arg("name"), Function.arg("value")], true))
        @globals.set("load", Function.new(@globals, lambda{|env, file| env.runtime.load(file, env)}, [Function.arg("file")], true))
        @globals.set("if", Function.new(@globals, lambda do |env,c,t,f|
            if !!c
                if !t.respond_to? :call
                    t
                else 
                    t.call([], env)
                end
            else
                if !f.respond_to? :call
                    f
                else
                    f.call([], env)
                end
            end
        end, [Function.arg("condition"), Function.arg("true"), Function.arg("false")], true))
    end

    def load_binary(symbol, override=nil)
        @globals.set(override ? override : symbol.to_s, Function.new(@globals, lambda {|env, *args| args.inject(symbol)}, [Function.arg("a"),Function.arg("b")], true))
    end
end