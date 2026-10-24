# Toll collector: "I need an escort" — draft lines (2026-10-21, awaiting owner approval)

Decisions (owner, 2026-10-21): free; no voice for now (subtitles only); one living hopeless escort at a time.

Conditions for the whole branch: speaker in `_SLS_TollCollectorFaction` (00A09C), player is female,
toll not paid (`_SLS_Main ::IsTollPaid_var == 0`).

## Player lines
- Top level: **Please, I need help.**
  - Collector answer (intro, random): see "HELP".
- Choice: **I can't leave without an escort. I need someone to go with me.**
  - If no living hopeless escort: one random line from "GIVE", then the escort spawns at the gate, joins as a follower
    and says his own intro line.
  - If she already has a living hopeless escort: one random line from "ALREADY".
- Choice: **Never mind.** (Goodbye)

## HELP (collector, after "Please, I need help.")
1. Help? Oh, this should be good. Go on, girl, what's the trouble?
2. A woman asking the gate for help. Shocking. What is it?
3. Look at that, it can talk. Quickly, I've got real work to do.
4. Let me guess - you want out and you can't do it on your own. What else is new.

## GIVE (collector, escort handed over)
1. Ha! Can't even walk through a gate without a man holding your hand. Fine. I've got just the fool for you - nobody else wants him either.
2. An escort, she says. Hey, lads, the little lady needs a minder! ... Here, take this one. He's useless, but so are you. You'll get on.
3. You know why we don't let your kind out alone? Because of exactly this. Wait here, I'll find you something with a pulse.
4. Free of charge, sweetheart. We pay to get rid of him. Now you're his problem and he's yours.
5. Look at you, all big eyes and empty hands. Pathetic. Fine, I'll fetch you the town's leftovers - suits you perfectly.
6. Gods, the begging. Alright, alright. One escort, slightly used, mostly drunk. Don't bring him back.
7. A grown woman who can't take ten steps past a wall by herself. Skyrim really has gone soft. Here - your new keeper.
8. Hah! Someone write this down. Fine, girl, you get the dregs. Try not to lose him before he loses you.

## ALREADY (collector, she already has a living hopeless escort)
1. You already have one, you greedy little thing. Use him.
2. One idiot per woman. Town rule. I just made it up, but it's a rule.
3. What, the first one ran off already? No? Then get out of my face.
