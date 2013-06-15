module Constants
	API_KEY = '134cfa8d85cc010dbbba951622728fac'
	API_SECRET = '897ace8ca619452b9efbe862e3adfb30'

	#positive assumptions
	CLOSEST_MATCH_PLAYCOUNT = 0
	GREATEST_TAG_OVERLAP = 1
	TRACK_RECOMMENDED_MORE_THAN_ONCE = 2

	#Negative assumptions
	FARTHEST_MATCH_PLAYCOUNT = 3
	SMALLEST_TAG_OVERLAP = 4

	#will cause main controller loop to break
	NO_REMAINING_SUGGESTIONS = 5
	SOLUTION_FOUND = 6

	#misc
	SUGGESTION_REJECTED = 7
end
