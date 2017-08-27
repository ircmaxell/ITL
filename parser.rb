require 'treetop'

base_path = File.expand_path(File.dirname(__FILE__))

require File.join(base_path, 'node_extensions.rb')

Treetop.load(File.join(base_path, 'itl_parser.treetop'))

class Parser
	def initialize()
		@parser = ItlParser.new
	end

	def parse(data)
		tree = @parser.parse(data)

		if tree.nil?
			raise Exception, "Parse error at offset: #{@parser.index}"
		end

		clean_tree tree
	end

	private
	def clean_tree(root_node)
		return if root_node.elements.nil?
		root_node.elements.delete_if {|node| node.class.name == "Treetop::Runtime::SyntaxNode"}
		root_node.elements.each {|node| clean_tree(node)}
		root_node
	end
end