class Blackboard

	IDEAL_POOL_SIZE = 3

	attr_accessor :user_lastfm_seed_track, :object_pool

	#maintain set size pool in blackboard
	def initialize
		@object_pool = []
		@reject_pool = []
		@user_lastfm_seed_track = nil
	end

	def add( possible_suggestion )
		@object_pool << possible_suggestion
	end

	def remove( possible_suggestion )
		@object_pool.remove( possible_suggestion )
	end

	def current_pool_size
		@object_pool.count
	end

	def get_pool
		@object_pool
	end

	def pool_size_maintained?
		current_pool_size == IDEAL_POOL_SIZE
	end

	def add_to_reject_pool( possible_suggestion )
		@reject_pool << possible_suggestion
	end

	def return_suggestion_with_traits( artist_name, track_name )
		res = @object_pool.map{ |s| s if (s.get_artist == artist_name and s.get_track == track_name) }.compact
		if res.count > 0
			return res[0]
		end
		nil
	end

	def reject_pool_contains_suggestion_with_traits( artist_name, track_name )
		res = @reject_pool.map{ |s| s if (s.get_artist == artist_name and s.get_track == track_name) }.compact
		if res.count > 0
			return true
		end
		false
	end

end

