require_relative 'knowledge_source'

class PopularTracksSimilarArtist < KnowledgeSource

	NUM_OF_SIM_ARTISTS = 15

	def initialize( blackboard, artist_name, track_name )
		super(blackboard, artist_name, track_name)
		similar_artists = @lastfm.artist.get_similar( :artist => @artist_name )
		@popular_tracks = []
		similar_artists[1..NUM_OF_SIM_ARTISTS].each do |sim_art|
			@popular_tracks << @lastfm.artist.get_top_tracks( :artist => sim_art["name"] )[0]
		end
		@popular_tracks.sort! { |a, b| b["playcount"].to_i <=> a["playcount"].to_i }
	end

	def evaluate
		if !empty?
			possible_suggestion = PossibleSuggestion.new( trim_lastfm_track(@popular_tracks.shift) )
			#see if track is already in pool; see method 'return_suggestion_with_traits' in Blackboard class
			res = get_suggestion_from_pool_with_traits( possible_suggestion )
			if res
				#if we have seen this suggestion before, add the related assumption to the existing track
				track_recommended_more_than_once = Assumption.new( self, Constants::TRACK_RECOMMENDED_MORE_THAN_ONCE, res )
				res.add_affirmation( Affirmation.new(track_recommended_more_than_once) )
				puts "PopularTracksSimilarArtist KS added positive assumption for #{res.get_artist}, #{res.get_track}"
			elsif !reject_pool_contains_suggestion?( possible_suggestion )
				@blackboard.add( possible_suggestion )
			end
		else
			puts "PopularTracksSimilarArtist KS ran out of suggestions!"
			Constants::NO_REMAINING_SUGGESTIONS
		end
	end

	def empty?
		@popular_tracks.empty?
	end

	def return_popular_tracks
		@popular_tracks
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

# s =  PopularTracksSimilarArtist.new(b, "Madonna", "like a virgin" )
# s.evaluate
# puts "pool #{b.get_pool}"

