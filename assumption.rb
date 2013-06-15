class Assumption

	attr_accessor :creator, :reason, :possible_suggestion

	def initialize( knowledge_source, reason, possible_suggestion )
		#the knowledge source, i.e. creator, of the assumption
		@creator = knowledge_source
		#The reason the knowledge source made the assumption
		@reason = reason
		#The blackboard object about which the assumption was made
		@possible_suggestion = possible_suggestion
	end

	def is_retractable?
		true
	end
end
