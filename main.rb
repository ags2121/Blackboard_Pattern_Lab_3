require_relative 'controller.rb'


class Main

	def start_program

		blackboard = Blackboard.new
		controller = Controller.new( blackboard )

		puts "\nAsk me for a recommendation based on a track of your choosing: "
		puts "Artist: "
		artist_string = gets.chomp
		puts "Track: "
		track_string = gets.chomp

		puts "Working.... initializing your recommendation engine."
		controller.add_user_input( artist_string , track_string )
		puts "Finished initializing your recommendation engine. Starting main loop."

		response = "poo"
		while response.downcase != "yes"
			res = controller.start_loop( true )
			if res == Constants::SOLUTION_FOUND
				rec = controller.push_recommendation_to_user
				puts "\nDo you like \"#{ rec[:track] }\" by #{ rec[:artist] }?"
				puts "Check it out: #{ rec[:url] }"
				response = gets.chomp
				if response.downcase != "yes"
					puts "\nOkay. I'll find another recommendation."
					controller.user_rejects_suggestion( rec )
				end
			end

		end

		puts "\nGreat! Would you like me to make another recommendation?"
		response = gets.chomp.downcase
	end

end

main = Main.new
res = main.start_program
while res == "yes"
	res = main.start_program
end
