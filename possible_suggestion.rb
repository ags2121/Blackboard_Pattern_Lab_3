require_relative 'dependent.rb'

class PossibleSuggestion < Dependent

	attr_accessor :lastfm_track, :affirmations

	def initialize( lastfm_track )
		super()
		@lastfm_track= lastfm_track
		@affirmations = []
	end

	def add_affirmation( affirmation )
		@affirmations << affirmation
	end

	def get_artist
		@lastfm_track["artist"]["name"]
	end

	def get_track
		@lastfm_track["name"]
	end

	def get_top_tag
		@lastfm_track["toptags"]["tag"][0]["name"]
	end

	def get_url
		@lastfm_track["url"]
	end

end
