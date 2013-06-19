require_relative 'assumption.rb'

class Affirmation

	attr_accessor :assumption

	def initialize( assumption)
		@assumption = assumption
	end

	def retract
		@assumption = nil
	end

end
