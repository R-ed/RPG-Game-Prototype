#===============================================================================
# This Script is made specfically for usage with GTBS version 1.5.1.4 by GubiD.
#===============================================================================
module GTBS
  
  Font = "Tahoma";
  def self.font
    return Font
  end
  
  STOPPED_ANIM = true
  
  #=============================================================================
  # Transition Image - Image used to draw transition 
  #=============================================================================
  TRANSITION_IMAGE = "BattleStart"
  
  #=============================================================================
  # MODE - This setting controls how GTBS determines turn order.  
  # 0 - Active Time Battle (ATB)
  # 1 - TEAM (All members of the team act in a single 'TURN')
  #=============================================================================
  MODE = 1
  
  #=============================================================================
  # ACTOR# events use party position(INDEX) for placement
  #=============================================================================
  # If false ACTOR# is actor # from DB rather than considering 'who is in party'
  #=============================================================================
  ACTOR_PLACE_USES_INDEX = true #not fully implemented yet!
  
  #=============================================================================
  # Font size for status window
  #=============================================================================
  Status_Gauge_Font_Size = 16
  
  #-------------------------------------------------------------
  # Recover After Battle?
  #-------------------------------------------------------------
  # Set based upon the below criteria
  # 0 - Never Recover #default
  # 1 - Neutrals Recover
  # 2 - All Units Recover
  #-------------------------------------------------------------
  Recover_HPMP_After_Battle = 0
  
  #-------------------------------------------------------------
  # Dead Actors leave party After Battle
  #-------------------------------------------------------------
  Dead_Actors_Leave = false
  
  #-------------------------------------------------------------
  # Test Battle Map ID ( used for battle test in database )
  #-------------------------------------------------------------
  BTEST_ID = 1
  BTEST_TBS = true
  
  #-------------------------------------------------------------
  # Force Move then Action method
  #-------------------------------------------------------------
  FORCE_MOVE_THEN_ACT = false
  #-------------------------------------------------------------
  # Defend when unable to attack?
  #-------------------------------------------------------------
  AUTO_DEFEND = false
  #-------------------------------------------------------------
  # Face Enemy When Battle Begins?
  #-------------------------------------------------------------
  FACE_ENEMY = true
  
  #-------------------------------------------------------------
  # Default Victory Common Event
  #-------------------------------------------------------------
  VIC_COM = 2
  #-------------------------------------------------------------
  # Default Failure Common Event
  #-------------------------------------------------------------
  FAIL_COM = 1
  
  #-------------------------------------------------------------    
  # Escape Cooldown - The amount of "battle turns" required to pass before
  # another escape can be attempted. 
  #-------------------------------------------------------------    
  ESCAPE_COOLDOWN = 1
  
  #-------------------------------------------------------------    
  # Sets ability to attack allies along with enemies
  # Default is TRUE
  #------------------------------------------------------------
  ATTACK_ALLIES = true
  
  #-------------------------------------------------------------
  # Set ability for characters to walk through other team member squares
  # Default is TRUE
  #-------------------------------------------------------------
  TEAM_THROUGH = true
  
  #-------------------------------------------------------------
  # Sets Damage Display during battle to POP individually or not
  # Default is TRUE
  #-------------------------------------------------------------
  POP_DAMAGE_IND = true
  
  #-------------------------------------------------------------
  # Show Item/Gold Gain immediately when enemy is killed
  #-------------------------------------------------------------
  SHOW_ITEMGOLD_IMMEDIATELY = true
  
  #-------------------------------------------------------------
  # Remove Dead from map upon death?
  # 0 = Do NOT remove any dead
  # 1 = Remove Enemies Only
  # 2 = Remove ALL dead
  #-------------------------------------------------------------
  REMOVE_DEAD = 0
  #-------------------------------------------------------------
  # Select a dead unit to revive:
  # if REVIVE_ANY_DEAD = true, you can revive units from anywhere
  # if false the unit have to be in the range of the item or skill
  REVIVE_ANY_DEAD = false;
    # only used if REVIVE_ANY_DEAD = false
    # if TARGET_DEAD_UNIT = true, the unit must be at the selected position
    # if false, any unit in range can be revive and will revive at the cursor's position
    TARGET_DEAD_UNIT = false
  
  #-------------------------------------------------------------
  # Large Line
  #-------------------------------------------------------------
  # Here for compatibility with Large Units.  This causes LINE skills to affect
  # all units within a direct line of the 'large unit cells' instead of just
  # their upper left as in previous verisons
  #-------------------------------------------------------------
  LARGE_LINE = true
  
  #-------------------------------------------------------------
  # USE_WAIT_SKILLS 
  #-------------------------------------------------------------
  # This is so when a skill has been used it will check if it has a "casting time"
  # If so, then the users skill will be queued for that user until the "casting time"
  # has elapsed, thus casting the spell.  
  USE_WAIT_SKILLS = true
  
  #-------------------------------------------------------------
  # ALLOW_SKILL_TARGET of enemy not just tile
  #-------------------------------------------------------------
  # This option allows you to choose to cast your spell on the target.. thus, if
  # they move it could affect others as well. (Just like in FFT for PSX!) 
  # This option only used when USE_WAIT_SKILLS enabled and using ATB system.
  ALLOW_SKILL_TARGET = true

  #-------------------------------------------------------------
  # EXP GAIN OPTIONS
  #-------------------------------------------------------------
  LEVEL_GAIN_SE = "Applause" #when level is gained.. SE to play.
  EXP_ALL = false #when true, all party receives exp - BLARG
  EXP_PERC_FOR_PARTY = 100 #Should receive same as who delivered action
  EXP_PER_HIT = true
    POP_EXP = true #display EXP as popup (like damage), not intended to work with EXP_ALL
    NEUTRAL_EXP = true #neutrals gain exp also?
  GAIN_EXP_ON_MISS = true
  
  EXP_WAIT_TIME = 30 #Just a little bit of extra wait when exp is given to make the
  #scene flow a little nicer. 
  
  #-------------------------------------------------------------
  # State ID Setup
  #-------------------------------------------------------------
  # Set these to the state id created in the database
  DEF_STATE_ICON = "001-Weapon01"
  #Core ID's by default
  CONFUSE_ID     =  5   
  SLEEPING_ID    =  6   
  PARALYZED_ID   =  7   
  COUNTER_ID     = 18
  
  
  # New States to consider
  CHARM_ID       = 27
  SLOW_ID        = 29  
  HASTE_ID       = 30
  CASTING_ID     = 31
  DONT_MOVE_ID   = 33
  DONT_ACT_ID    = 34
  DOOM_ID        = 35 
  TELEPORT1_ID   = 36
  TELEPORT2_ID   = 37
  
  #-------------------------------------------------------------
  # Knock Back states
  #-------------------------------------------------------------
  # Add to main array between [] such as.. [28,29]
  #-------------------------------------------------------------
  # Easy Config:
  # knockback
  #-------------------------------------------------------------
  KNOCK_BACK_STATES  = []  
  
  #-------------------------------------------------------------
  # ALLOW_LSHAPE_FOR BOWS
  #-------------------------------------------------------------
  # This option will allow bows users to shoot in non straight lines
  #-------------------------------------------------------------
  BOW_LSHAPE = true

  #-------------------------------------------------------------
  # Reduce AT on Attack - reduces actor and enemy AT when attacked
  #-------------------------------------------------------------
  # This new interesting feature can cause you to utterly get wipped out if you
  # dont plan your stategies well.
  # set value at 0 to disable 
  #------------------------------------------------------------- 
  REDUCE_AT_PERC      = 5
  
  #-------------------------------------------------------------
  # Counter All - Forces defender to always return attack if physical and in 
  # attackable range
  #-------------------------------------------------------------
  COUNTER_ALL = true
  COUNTER_TEAM = false
  COUNTER_WHEN_CHARMED = false
  COUNTER_WHEN_KNOCKED_BACK = true
  
  #-------------------------------------------------------------
  # Enable Move as variable - DO NOT USE THIS YET, IT IS STILL BUGGY AND NOT COMPLETE
  #-------------------------------------------------------------
  MOVE_VARIABLE = false
  
  #-------------------------------------------------------------
  # Use Encounter Position Moving?
  #-------------------------------------------------------------
  # This method works like this.  The gist of it is that if you touch an enemy
  # you must stop moving.  So if you want to get to the back of an enemy you must
  # walk 6 tiles to get from infront to behind them, instead of the normal 4. 
  # An example would be like this:
  #  new method:  ###   old method:  ##
  #               # E                #E
  #               ##A                #A
  #  If the old move was attemped you would be forced to stop at the side of the 
  # enemy.  Anyway, there is nothing like experimenting to understand something
  # better.  Best of luck!
  #-------------------------------------------------------------
  ENCOUNTER_MOVING_METHOD = true
  
  #-------------------------------------------------------------
  # Required TP for move - 0 is disabled
  #-------------------------------------------------------------
  REQUIRED_TP_FOR_MOVE = 0
  
  #-------------------------------------------------------------
  # Show Action time Value
  #-------------------------------------------------------------
  # This setting affects whether the Status Dialog will display the AT value
  #-------------------------------------------------------------
  Show_Action_Time_value = false
  
  #### DONT TOUCH THIS PLEASE ####
  BTEST_TBS = true if BTEST_ID == 0 
  REVIVE_ANY_DEAD = true if REMOVE_DEAD == 2 #force revive any if remove all
end