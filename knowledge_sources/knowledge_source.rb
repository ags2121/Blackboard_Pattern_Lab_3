require 'lastfm'
require_relative '../blackboard.rb'
require_relative '../possible_suggestion.rb'
require_relative '../constants.rb'
require_relative '../affirmation.rb'

class KnowledgeSource

	include Constants

	def initialize( blackboard, artist_name, track_name )
		@blackboard = blackboard
		@artist_name = artist_name
		@track_name = track_name
		@lastfm = Lastfm.new( Constants::API_KEY, Constants::API_SECRET )
	end

	def evaluate
		raise 'cannot evaluate abstract KnowledgeSource'
	end

	def reset
		raise 'cannot reset abstract KnowledgeSource'
	end
end
