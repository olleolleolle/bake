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

require_relative 'recipe'
require_relative 'scope'

module Bake
	class Base < Struct.new(:context)
		def self.derive(path = [])
			klass = Class.new(self)
			
			klass.const_set(:PATH, path)
			
			return klass
		end
		
		def self.to_s
			if path = self.path
				path.join(':')
			else
				super
			end
		end
		
		def self.inspect
			if path = self.path
				"Bake::Base<#{path.join(':')}>"
			else
				super
			end
		end
		
		def self.path
			self.const_get(:PATH)
		rescue
			nil
		end
		
		def path
			self.class.path
		end
		
		def call(*arguments)
			self.context.call(*arguments)
		end
		
		def recipes
			return to_enum(:recipes) unless block_given?
			
			names = self.public_methods - Base.public_instance_methods
			
			names.each do |name|
				yield recipe_for(name)
			end
		end
		
		def recipe_for(name)
			Recipe.new(self, name)
		end
	end
end
