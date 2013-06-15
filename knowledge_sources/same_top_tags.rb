require_relative 'knowledge_source'

class SameTopTags < KnowledgeSource

	#we use these values just to seed instance variables at the beginning of the program, so we can tune the variables later if we want
	#see 'adjust_tag_pool_size' and 'recompute_seed_track_top_tags'
	TAG_POOL_SIZE = 10

	def initialize( blackboard, artist_name, track_name )
		super(blackboard, artist_name, track_name)
		@tag_pool_size = TAG_POOL_SIZE
		@user_lastfm_seed_track_top_tags = @lastfm.track.get_top_tags(:artist=>artist_name, :track=>track_name)[0..@tag_pool_size-1].collect{|t| t["name"]}
	end


	def evaluate
		overlap_count = []
		@blackboard.get_pool.each do |suggestion|
			#get tag pool for suggestion track
			top_tags = @lastfm.track.get_top_tags(:artist=>suggestion.get_artist, :track=>suggestion.get_track)

			#if the track has no tags, skip the evaluation
			if top_tags == nil
				return
			end

			tags = top_tags[0..@tag_pool_size-1].collect{|t| t["name"]}
			#compute tag pool overlap count between seed track and suggestion track
			overlap_count << (tags & @user_lastfm_seed_track_top_tags).count
		end

		#find indices of suggestions with most and least tag overlap
		min_max = overlap_count.minmax { |a, b| a <=> b }
		index_of_least_tag_overlap = overlap_count.index( min_max[0] )
		index_of_most_tag_overlap = overlap_count.index( min_max[1] )

		track_with_least_tag_overlap = @blackboard.get_pool[index_of_least_tag_overlap]
		track_with_most_tag_overlap = @blackboard.get_pool[index_of_most_tag_overlap]

		least_tag_overlap_assumption = Assumption.new(self, Constants::SMALLEST_TAG_OVERLAP, track_with_least_tag_overlap)
		most_tag_overlap_assumption = Assumption.new(self, Constants::GREATEST_TAG_OVERLAP, track_with_most_tag_overlap)

		track_with_least_tag_overlap.add_affirmation( Affirmation.new(least_tag_overlap_assumption) )
		track_with_most_tag_overlap.add_affirmation( Affirmation.new(most_tag_overlap_assumption) )

		puts "track with the most tag matches #{track_with_most_tag_overlap.get_track}, overlap count: #{overlap_count[index_of_most_tag_overlap]}"
		puts "track with the least tag matches #{track_with_least_tag_overlap.get_track}, overlap count: #{overlap_count[index_of_least_tag_overlap]}"
	end

	def adjust_tag_pool_size( val )
		@tag_pool_size += val
	end

	def recompute_seed_track_top_tags
		@user_lastfm_seed_track_top_tags = @lastfm.track.get_top_tags(:artist=>artist_name, :track=>track_name)[0..@tag_pool_size-1].collect{|t| t["name"]}
	end

	def reset
		 @blackboard.get_pool.each do |suggestion|
		 	if !suggestion.affirmations.empty?
		 		suggestion.affirmations.delete_if do |affirm|
		 			if affirm.assumption.creator == self
		 				puts "affirmation succesfully retracted from tag KS"
		 				true
		 			end
		 		end
		 	end
		 end
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
# s = SameTopTags.new(b, artist, track)
# s.evaluate
