require_relative 'knowledge_source'

class SimilarTracks < KnowledgeSource

	def initialize( blackboard, artist_name, track_name )
		super(blackboard, artist_name, track_name)
		@similar_tracks = @lastfm.track.get_similar(:artist => @artist_name, :track => @track_name )
	end

	#return and remove first element in similar_artists array
	def evaluate
		if !empty?
			possible_suggestion = PossibleSuggestion.new( trim_lastfm_track(@similar_tracks.shift) )
			#see if track is already in pool; see method 'return_suggestion_with_traits' in Blackboard class
			res = get_suggestion_from_pool_with_traits( possible_suggestion )
			if res
				#if we have seen this suggestion before, add the related assumption to the existing track
				track_recommended_more_than_once = Assumption.new( self, Constants::TRACK_RECOMMENDED_MORE_THAN_ONCE, res )
				res.add_affirmation( Affirmation.new(track_recommended_more_than_once) )
				puts "SimilarTracks KS added positive assumption for #{res.get_artist}, #{res.get_track}"
			elsif !reject_pool_contains_suggestion?( possible_suggestion )
				@blackboard.add( possible_suggestion )
			end
		else
			puts "SimilarTracks KS ran out of suggestions!"
			Constants::NO_REMAINING_SUGGESTIONS
		end
	end

	def empty?
		@similar_tracks.empty?
	end

	def return_suggestions
		@similar_tracks
	end

	def trim_lastfm_track( lastfm_track )
		lastfm_track.delete("image")
		lastfm_track
	end

	def get_suggestion_from_pool_with_traits( suggestion )
		@blackboard.return_suggestion_with_traits( suggestion.get_artist, suggestion.get_track )
	end

	def reject_pool_contains_suggestion?( suggestion )
		res = @blackboard.reject_pool_contains_suggestion_with_traits( suggestion.get_artist, suggestion.get_track )
	end
end

########## FOR TESTING ############
# b = Blackboard.new

# s = SimilarTracks.new(b, "Madonna", "Like a Virgin")
# s.evaluate
# puts "pool #{b.get_pool}"
