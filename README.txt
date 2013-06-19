Alex Silva
3 June 2013
OO Lab Deliverable 3

For Lab 3 I used 'ruby-lastfm' as a Ruby Interface for Last.fm's API.
The ruby-lastfm GitHub is at the following address: https://github.com/youpy/ruby-lastfm
Run gem install 'lastfm' to install the gem.
Run the program from 'main.rb'.

QUESTIONS:

Section 1:
	1. The puzzle pieces of my blackboard are the blackboard objects, what I call a "possible_suggestion" object, which encapsulates a lastfm track object along with all the behavior that comes with being a subclass of the "dependant" class (i.e. having a collection of references to knowledge sources). The other pieces of the blackboard are the knowledge sources, which by the end of the assignment are Playcount, SimilarTracks, SameTopTracks, and the PopularTracksSimilarArtist. Finally there's the controller object which handles all the logically flow of the program, as well as the Affirmation and Assumption objects, which in my model kind of represent the same thing.

	2. No it is not. It took a while to realize that, while the SimilarTrack knowledge source was simply a object that added suggestions to the blackboards object pool, a knowledge source like Playcount behaves differently. It doesn't provide objects but rather makes judgements on objects. The way I had to adjust my code was mainly in the controller; in my loop code I had to make sure that the two knowledge sources evaluate at different times. Playcount would only evaluate once SimilarTrack had made sure to provide enough tracks to the blackboard pool.

	3. The controller has a lot of responsibilities, but its most important ones are to instruct each knowledge source to evaluate at the proper times, and to run logic at the end of an evaluation cycle to determine whether enough positive affirmations have been accumulated to return a recommendation to the UI.

	4. The knowledge sources definitely need some concept of an affirmation or assumption in order to encapsulate the reasons for why they might flag a suggestion as good or bad. Despite not really needing to, I used both in order to show that I understand that a knowledge source might want to issue judgements with more granularity (i.e. an affirmation could hold both an assumption as well as a more permanent assertion). I could have probably just used assertions without encapulating them in affirmations.

	5. The dependants on my blackboard are the PossibleSuggestion objects, which subclass the Dependant class.

Section 2:
	1. The controller loops through assumptions and assesses state of blackboard solution. If we can find two positive assumptions for a possible_suggestion, we choose it as a recommendation. The controller will also return a recommendation if when we subtract negative assumptions from positive assumptions for each suggestion, only one suggestion element in the difference array has positive value. See my code in the Controller's 'is_solved?' method. Additionally, at each pass the suggestion with the most negative assumptions is removed.

	2. The user can be thought of as a kind of knowledge source. Whenever a user rejects a track, the track is inserted into a global pool of 'rejected_objects', which the Blackboard object contains. This rejected pool can then be used by all the knowledge sources in the future to make decisions. In my program, no new suggestions are added to the blackboard pool if they exist in the reject pool.

	3. The short term solution is whatever logic is executed by the end of the Controller's main loop (i.e. tallying the assumptions on each suggestion ). The longer term solution is represented through the handling of user input. When a user rejects a track it is, as I mentioned, added to a global reject pool which is available and helpful to everyone. Additionally, a rejected suggestion will notify all of its "references", or knowledge sources which made an assumption on it. When notified, a knowledge can make any number of adjustments, though mine are pretty simple, linear adjustments. The main difference in how my knowledge sources affect the blackboard is between the knowledge sources which simple push new suggestion objects to the pool, and the ones that only make judgements on the suggestion objects. For instance, Playcount and SameTopTags evaluate only after PopularTracksSimilarArtist and SimilarTracks have filled blackboard object pool back to its proper size. However PopularTracksSimilarArtist and SimilarTracks CAN make positive assumptions, like when they notice they are about to push a track that has already been added to the pool.

Section 3:
	1. See attached UML scan titled "lab_3_ags_UML"
	2. I actually think this would be very simple to do. I would simply add another line to my "add_knowledge_source" method in my controller where I instantiate the new aural knowledge source, after writing up a new class called AuralExpert which subclasses KnowledgeSource. In the main controller loop I would group it with the other "judging" knowledge sources (lines 39 and 40) where it would evaluate each suggestion in the blackboard pool, inspecting its aural properties against the seed track. I would probably up the positive assumption threshold to 3, and maybe broaden the size of the object pool, but that's about it.
	3.
		a. See the file in this directory titled "lab_3_ags_terminal_saved_output"
		b. For loop count 1 (loop starts at 0; you can follow the lines that say "number of positive affirmations in loop ${x}"), loop count 3, and loop count 8, a recommendation is presented because a suggestion was found with a positive cumulative assumption count, meaning that when its negative assumption count was subtracted from its positive assumption count, it was the only suggestion with a positive assumption count. For loop counts 2, 6, 7 on the other hand, a recommendation was presented because a suggestion was found with a positive assumption count of 2.
		c. After each "no", the rejected suggestion notifies its knowledge source references. The Playcount KS responds by either lowering or raising its ideal playcount value by 10 and the SameTopTracks KS responds by broadening its tag pool by 1.
		d. By the time the user says "Yes", the ideal playcount would have been adjusted according to how the rejected tracks compared to the initial seed track playcount, and the SameTopTracks pool would have broadening to a size of 15.

	4. Yes the program does work better, and it fact I don't think it would work very well at all without at least two knowledge sources. In the first iteration the recommendations made were not that dynamic, only returning tracks which had the closest playcount. With two knowledge sources, there's more variability and interest.

