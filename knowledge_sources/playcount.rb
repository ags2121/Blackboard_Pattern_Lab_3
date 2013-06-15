require_relative 'knowledge_source'

class Playcount < KnowledgeSource

	def initialize( blackboard, artist_name, track_name )
		super(blackboard, artist_name, track_name)
		@ideal_playcount = @blackboard.user_lastfm_seed_track["playcount"].to_i
	end

	def evaluate
		closest_playcount_track = find_closest
		farthest_playcount_track = find_farthest

		#create assumption
		farthest_assumption = Assumption.new(self, Constants::FARTHEST_MATCH_PLAYCOUNT, farthest_playcount_track)
		closest_assumption = Assumption.new(self, Constants::CLOSEST_MATCH_PLAYCOUNT, closest_playcount_track)

		#add affirmation to furthest and closest track
		farthest_playcount_track.add_affirmation( Affirmation.new(farthest_assumption) )
		closest_playcount_track.add_affirmation( Affirmation.new(closest_assumption) )

		#add this knowledge source as a dependent to both suggestions
		farthest_playcount_track.add(self)
		closest_playcount_track.add(self)

		puts "ideal playcount: #{@ideal_playcount}"
		puts "closest_playcount_track: #{closest_playcount_track.get_artist}, #{closest_playcount_track.get_track}, farthest_playcount_track: #{farthest_playcount_track.get_artist}, #{farthest_playcount_track.get_track}"
		puts "closest track playcount: #{get_playcount(closest_playcount_track)}, farthest track playcount: #{get_playcount(farthest_playcount_track)}"
	end

	def find_closest
		@blackboard.get_pool.min_by{ |x| ( x.lastfm_track["playcount"].to_i - @ideal_playcount).abs }
	end

	def find_farthest
		min_max = @blackboard.get_pool.minmax { |a, b| a.lastfm_track["playcount"].to_i<=> b.lastfm_track["playcount"].to_i }
		min_max.max { |a, b| ( a.lastfm_track["playcount"].to_i - @ideal_playcount ).abs <=> ( b.lastfm_track["playcount"].to_i - @ideal_playcount).abs }
	end

	def change_ideal_playcount( val )
		@ideal_playcount += val
	end

	def get_playcount( suggestion )
		suggestion.lastfm_track["playcount"].to_i
	end

	def reset
		 @blackboard.get_pool.each do |suggestion|
		 	if !suggestion.affirmations.empty?
				suggestion.affirmations.delete_if do |affirm|
		 			if affirm.assumption.creator == self
		 				puts "affirmation succesfully retracted from playcount KS"
		 				true
		 			end
		 		end
		 	end
		 end
	end

	def notify( msg )
		if msg ==
	end

end

########## FOR TESTING ############

# def trim_lastfm_track( lastfm_track )
# 	lastfm_track.delete("image")
# 	lastfm_track
# end

# artist = "Kanye West"
# track = "Jesus Walks"
# b = Blackboard.new

# lastfm = Lastfm.new('134cfa8d85cc010dbbba951622728fac', '897ace8ca619452b9efbe862e3adfb30')
# lastfm.track.get_similar( :artist => artist, :track => track)[0..9].each do |track|
# 	possible_suggestion = PossibleSuggestion.new( trim_lastfm_track(track) )
# 	b.add( possible_suggestion )
# end
# puts "blackboard pool size: #{b.get_pool.count}"
# b.user_lastfm_seed_track = lastfm.track.get_info(:artist => artist, :track => track)
# s = Playcount.new(b, artist, track)
# s.evaluate
