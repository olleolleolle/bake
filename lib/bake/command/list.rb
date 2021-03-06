# Copyright, 2020, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'samovar'
require 'set'

module Bake
	module Command
		class List < Samovar::Command
			PARAMETER = /@param\s+(?<name>.*?)\s+\[(?<type>.*?)\]\s+(?<details>.*?)\Z/
			
			def format_parameters(parameters, terminal)
				parameters.each do |type, name|
					case type
					when :key
						name = "#{name}="
					when :keyreq
						name = "#{name}="
					when :keyrest
						name = "**#{name}"
					else
						name = name.to_s
					end
					
					terminal.print(:reset, " ")
					terminal.print(type, name)
				end
			end
			
			def format_recipe(recipe, terminal)
				terminal.print(:command, recipe.command)
				
				if parameters = recipe.parameters
					format_parameters(parameters, terminal)
				end
			end
			
			def print_scope(terminal, scope)
				format_recipe = self.method(:format_recipe).curry
				
				scope.recipes.sort.each do |recipe|
					terminal.print_line
					terminal.print_line("\t", format_recipe[recipe])
					
					recipe.description.each do |line|
						if match = line.match(PARAMETER)
							terminal.print_line("\t\t",
								:parameter, match[:name], :reset, " [",
								:type, match[:type], :reset, "] ",
								:description, match[:details]
							)
						else
							terminal.print_line("\t\t", :description, line)
						end
					end
				end
			end
			
			def call
				first = true
				terminal = @parent.terminal
				context = @parent.context
				
				if scope = context.scope
					terminal.print_line(:context, context)
					
					print_scope(terminal, context.scope)
					
					terminal.print_line
				end
				
				context.loaders.each do |loader|
					terminal.print_line(:loader, loader)
					
					loader.each do |path|
						if scope = loader.scope_for(path)
							print_scope(terminal, scope)
						end
					end
					
					terminal.print_line
				end
			end
		end
	end
end
