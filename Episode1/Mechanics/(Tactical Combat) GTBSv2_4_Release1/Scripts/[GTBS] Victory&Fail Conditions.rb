#===============================================================================
# This Script is made specfically for usage with GTBS version 1.5.1.4 by GubiD.
#===============================================================================

module GTBS
#----------------------------------------------------------------------------
# Victory Conditions
# Use this item to set the victory requirements for the next battle from within 
# an event.  From the event choose, "use script" then type:
#   "tbs_victory(condition, value)" (without the quotes)
# where condition is the word describing the battle type.
#----------------------------------------------------------------------------
# Conditions                 Value
# "reach"                    [x,y]
# "boss"                     Enemy_ID (1 for ghost, there should be only 1)
#                            otherwise, it wont trigger, until there are no ghost.
# "holdout"                  Turns
# if none specified          Defeat all enemies
#----------------------------------------------------------------------------
Vic_Reach = 'reach'
Vic_Boss = 'boss'
Vic_Holdout = 'holdout' 
Vic_Critical_Enemy =  'critical_enemy', 
Vic_Critical_Actor  = 'critical_actor'
#----------------------------------------------------------------------------
# Failure Conditions
# Use this item to set the failure requirements for the next battle from within 
# an event.  From the event choose, "use script" then type:
#   "tbs_failure(condition, value)" (without the quotes)
# where condition is the word describing the battle type.
#----------------------------------------------------------------------------
# Conditions                  Value
# if none specified           All dead
# "death" (Actor or Neutral)  Actor_ID(when actor dies, fail)
# "holdout"                   Turns - battle turns exceeds failure turn value
#----------------------------------------------------------------------------
Fail_Death = 'death'
Fail_Holdout = 'holdout'
#
#============================================================================
# Remember that when setting a victory or failure type that you MUST use "s or it 
# wont work or will likely error, below are some examples:
#--------------------
# Examples:
# 1.  tbs_victory("reach", [14,27], 87)
#     In this example, in order to achive victory you must reach 14,27, and when
#     you do, common event 87 will be run.
#
# 2.  tbs_victory("holdout", 10)
#     In this example your party must withstand 10 "turns" of battle at which time
#     you will achive a standard victory.
#
# 3.  tbs_failure("death", 6, 5)
#     In this example when actor 6 dies, then common event 5 will be run, and
#     then the standard fail event will be launched afterwords, unless you tranfered
#     elsewhere.
#
# You can find other examples in the demo for boss and other death variations.
# Dont be affraid to combine methods of victory and failure commands and individual
# actor death events together as it will add more varity to your game.
#============================================================================
end