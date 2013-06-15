require 'lastfm'
require_relative 'blackboard.rb'
require_relative 'constants.rb'
Dir["./knowledge_sources/*.rb"].each {|file| require file }

class Controller
	include Constants

	#the actual positive assumption threshold value will be held in an instance variable so we can tune the value if we want to
	#while the controller is running
	POSITIVE_ASSUMPTION_THRESHOLD = 2

	def initialize( blackboard )
		@blackboard = blackboard
		@knowledge_sources = []
		@positive_assumption_threshold = POSITIVE_ASSUMPTION_THRESHOLD
		@while_loop_passes = 0
		@current_choice = nil
		@artist_string = nil
		@track_string = nil
		@return_val = nil
	end

	def start_loop( first_loop )
		while @return_val != Constants::SOLUTION_FOUND && @return_val != Constants::NO_REMAINING_SUGGESTIONS
			@return_val = nil
			#reset all of the possible_solutions which have assumptions made on them by either the similar_tag KS or the playcount KS
			#since the accuracy of those assumptions can change whenever a track in removed and a new one added to the pool.
			@knowledge_sources[2].reset #resets SameTopTags
			@knowledge_sources[3].reset #resets Playcount

			#instruct the SimilarTracks KS and PopularTracksSimilarArtist to evaluate
			#will return NO_REMAINING_SUGGESTIONS if they have no more tracks to give
			if not enough_suggestions?
				@return_val = fill_suggestion_pool
			end

			#instruct the SameTopTags KS and Playcount KS to evaluate
			@knowledge_sources[2].evaluate
			@knowledge_sources[3].evaluate

			#controller loops through assumptions and assesses state of blackboard solution
			#if we can find two positive assumptions for a possible_suggestion, we choose it as the solution
			#the possible_suggestion with the most negative assumptions is removed from the blackboard
			#if this is the 10th pass of the loop, we break and return the one with the most positive assumptions
			if solved?( false )
				puts "SOLUTION FOUND"
				@return_val = Constants::SOLUTION_FOUND
			end

			@while_loop_passes += 1
		end
		@return_val
	end

	def add_user_input( artist_string, track_string )
		@artist_string = artist_string
		@track_string = track_string
		load_user_seed_track_to_blackboard( artist_string, track_string)
		add_knowledge_sources
		fill_suggestion_pool
	end

	def load_user_seed_track_to_blackboard( artist_string, track_string )
		lastfm = Lastfm.new(Constants::API_KEY, Constants::API_SECRET)
		@blackboard.user_lastfm_seed_track = lastfm.track.get_info(:artist => artist_string, :track => track_string)
	end

	def add_knowledge_sources
		@knowledge_sources <<  SimilarTracks.new( @blackboard, @artist_string, @track_string )
		@knowledge_sources <<  PopularTracksSimilarArtist.new( @blackboard, @artist_string, @track_string )
		@knowledge_sources << SameTopTags.new( @blackboard, @artist_string, @track_string )
		@knowledge_sources << Playcount.new( @blackboard, @artist_string, @track_string )
	end

	def fill_suggestion_pool
		res = nil
		while !enough_suggestions? && res != Constants::NO_REMAINING_SUGGESTIONS
			res = @knowledge_sources[0].evaluate
			if !enough_suggestions? && res != Constants::NO_REMAINING_SUGGESTIONS
				res = @knowledge_sources[1].evaluate
			end
		end
		puts "pool size in loop pass: #{@while_loop_passes}, #{@blackboard.current_pool_size}"
		res
	end

	def solved?( first_loop )
		if first_loop
			return false
		end
		#loop through blackboard suggestion pool and tally the negative assumptions and positive assumptions
		positive_affirmations = []
		negative_affirmations = []
		 @blackboard.get_pool.each do |suggestion|
		 	if !suggestion.affirmations.empty?
		 		pos = suggestion.affirmations.map{ |affirm| affirm if (affirm.assumption.reason >= 0 && affirm.assumption.reason < 3) }.compact.count
		 		positive_affirmations << pos
		 		neg = suggestion.affirmations.map{ |affirm| affirm if (affirm.assumption.reason == 3 || affirm.assumption.reason == 4) }.compact.count
		 		negative_affirmations << neg
		 	else
		 		positive_affirmations << 0
		 		negative_affirmations << 0
		 	end
		 end

		 puts "pos affirmations array: #{positive_affirmations}"
		 puts "neg affirmations array: #{negative_affirmations}"

		 #retrieve the highest count of negative affirmations
		 neg_value_and_index = negative_affirmations.each_with_index.max
		 neg_index = neg_value_and_index[1]

		 #remove the suggestion with the most negative affirmation count, if different then track with positive
		@blackboard.get_pool.delete_at( neg_index )

		#retrieve the highest count of positive affirmations
		 pos_value_and_index = positive_affirmations.each_with_index.max
		 puts "number of positive affirmations in loop #{@while_loop_passes}: #{pos_value_and_index[0]}"

		 #if we have a suggestion that has reached the positive assumption threshold
		 if pos_value_and_index[0] >= @positive_assumption_threshold
		 	pos_index = pos_value_and_index[1]
		 	@current_choice = @blackboard.get_pool.delete_at( pos_index )
		 	return true
		 end

		 #or, if when we subtract negative assumptions from positive assumptions, only one element in the difference array has positive value
		 diffs = positive_affirmations.zip(negative_affirmations).map { |x, y| x - y }
		 if (diffs.find_all{ |x| x==1 }.count == 1)
		 	@current_choice = @blackboard.get_pool.delete_at( diffs.index(1) )
		 	return true
		 end

		 false
	end

	def enough_suggestions?
		@blackboard.pool_size_maintained?
	end

	def return_suggestion_pool
		@blackboard.get_pool
	end

	def reject_track( track )
		@blackboard.add_to_reject_pool( track )
	end

	def adjust_positive_assumption_threshold( val )
		@positive_assumption_threshold += val
	end

	def push_recommendation_to_user
		if @current_choice
			return {:artist => @current_choice.get_artist, :track => @current_choice.get_track, :url => @current_choice.get_url}
		end
	end

	def user_rejects_suggestion( suggestion )
		#when user rejects selection, we:
		#1. tune the Playcount and SameTopTags, which will be accomplished via the notify operation in the dependant class
		#2. add the track to the global rejected pool
		suggestion.notify(  )
		start_loop
	end

end

########## FOR TESTING ############

# b = Blackboard.new
# c = Controller.new( b )
# c.add_user_input("DJ Rashad", "CCP")
# puts "#{c.return_suggestion_pool[0].lastfm_track}"
