require './bytecode.rb'


class Compiler

	def compile(tree)
		case tree
			when Itl::Program
				compile_program tree
			when Itl::ExpressionList
				compile_expressionlist tree
			when Itl::Expression
				compile_expression tree
			when Itl::Block
				compile_block tree
			when Itl::EmptyExpressionList
				[]
            when Itl::Grouped
                compile_program tree
			when Itl::ArgumentList
				compile_argumentlist tree
			when Itl::IntegerLiteral
				[Itl::Bytecode::IntegerLiteral.new(tree.text_value)]
            when Itl::StringLiteral
                [Itl::Bytecode::StringLiteral.new(tree.text_value[1..-2])]
			when Itl::IdentifierLiteral
				[
					Itl::Bytecode::Identifier.new(tree.text_value),
				]
            when Itl::Symbol
                [Itl::Bytecode::Symbol.new(tree.elements.first.text_value)]
			else
				raise "Unknown tree type #{tree.class}"
				[]
		end
	end

	def compile_expression(expression)
		case expression.elements.length
			when 0
				[Itl::Bytecode::NoOp.new]
			when 1
				literal = (compile expression.elements[0])
				if literal.last.is_literal?
					return literal
				end
				[
					literal,
					Itl::Bytecode::LiteralLookup.new()
				]
			else
				[
					(compile expression.elements[0]),
					Itl::Bytecode::BeginFuncCall.new(),
					expression.elements.drop(1).map.with_index do |arg, idx|
						[
							(compile arg),
							Itl::Bytecode::ArgumentFetch.new(idx),
						]
					end,
					Itl::Bytecode::FuncCall.new,
				].flatten
		end	
	end

	def compile_argumentlist(args)
		args.elements.map do |child|
			Itl::Bytecode::Argument.new(child.elements.first.text_value)
		end
	end

	def compile_block(block)
		[
			Itl::Bytecode::Block.new(
    			block.elements.map do |child|
    				compile child
    			end.flatten
            ),
		]
	end

	def compile_program(program)
		program.elements.map do |child|
			compile child
		end.first
	end

	def compile_expressionlist(expressionlist)
		expressionlist.elements.map do |child|
			compile child
		end.flatten
	end

end