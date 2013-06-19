class Dependent

	def initialize
		@references = []
	end

	#Add a reference to a knowledge source.
	def add( knowledge_source )
		@references << knowledge_source
	end

	#Remove a reference to a knowledge source
	def remove( knowledge_source )
		@references.delete( knowledge_source )
	end

	#Return the number of dependents.
	def number_of_dependents
		@references.count
	end

	def notify( msg )
		@references.each do |reference|
			reference.notify( msg, self )
		end
	end
end
