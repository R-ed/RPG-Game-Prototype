module GTBS
  #========================================================================
  #          PROJECTILES SETUP
  #========================================================================
  
  #-------------------------------------------------------------
  # Default Animation Method
  #-------------------------------------------------------------
  # Valid animation methods:
  #   :GTBS
  #   :KADUKI
  #   :MINKOFF #Use this for Holder sprites
  #   :CHARSET
  #
  #-------------------------------------------------------------
  # Only used IF the character image is marked as animated
  # See DETERMINE_ANIM_KEY
  #-------------------------------------------------------------
  DEFAULT_ANIMATION_METHOD = :GTBS
  
  #-------------------------------------------------------------
  # How animated is determined?
  #-------------------------------------------------------------
  # Character image to be used should contain...
  #-------------------------------------------------------------
  DETERMINE_ANIM_KEY = "ANIM" #    <---- Case Sensitive!!!!
  
  #----------------------------------------------------
  # Mini Battler Suffix
  #----------------------------------------------------
  # The TEXT to be appended to the battler name when you enter MINI battle.
  #----------------------------------------------------
  # Leave empty for NO Suffix (as in it will utilize the same graphic for map/mini)
  #----------------------------------------------------
  # Note: Changing this to ANIM will NOT produce an animated battler!  This is 
  # added to the name after the animated battler check and would cause circular
  # logic if done that way (as in bad).  You have been notified.
  #----------------------------------------------------
  MINI_Battler_Suffix = "_MINI"
  
  #-------------------------------------------------------------
  # Follow projectile with y carema?
  #-------------------------------------------------------------
  PROJECTILE_CAM = true
  
  #-------------------------------------------------------------
  # Miss AnimationID - to be used when no target can be hit (attack/skill)
  #-------------------------------------------------------------
  MISS_ANIMATION = 111
  
  #-------------------------------------------------------------
  # Summon AnimationID - AnimationID from DB that should be used when a summon is
  # called to the current battle map.
  #-------------------------------------------------------------
  SUMMON_ANIMATION = 75
  
  #-------------------------------------------------------------
  # Doom ANIM ID
  #-------------------------------------------------------------
  DOOM_ANIM_ID = 104
  
  #-------------------------------------------------------------
  # Teleport Animation ID (used when player has teleport state
  #-------------------------------------------------------------
  TELEPORT_ANIM = 2
  
  #-------------------------------------------------------------
  # Animation ID for Attack/Special 1&2/Casting/Cast/Heal
  # These Animation ID's, when assigned as the user animation, will trigger
  # the stated pose from the animated battler template.  Keep in mind that this
  # animation will do nother other than trigger the stated animation.  If you 
  # want to assign an 'animation' from the database to a particular pose, based
  # on battler, use the 
  #-------------------------------------------------------------
  # All animations not listed below (Pain/Defend/Walk/Wait/Dead) are auto assigned
  ANIM_ATK = 105
  ANIM_SPEC1 = 106
  ANIM_CASTING = 108
  ANIM_CAST = 109
  ANIM_HEAL = 110
  
  #-------------------------------------------------------------
  # Default Pose Numbers
  #-------------------------------------------------------------
  # Allows you to define which pose, from your template, should be used as the 
  # default for the following actions.   
  #
  # The pose NAME defined  can be used to call up that particular pose during 
  # a action note.  Use "animation user: pose NAME"
  #
  #-------------------------------------------------------------
  # Note: If more than one ROW is specified in the array, one will be chosen
  # at random when delivered.
  #-------------------------------------------------------------
  # Note: If you enter a pose number that exceeds the "STANCES" then it will 
  # not display during battle.  (If the default is 11, and this character alone
  # has more.  Use EXTRA_ACTOR_STANCES or EXTRA_ENEMY_STANCES for the additional 
  # stances assignment.
  #-------------------------------------------------------------
  # Do not remove any of these, but feel free to add to them!  
  # Some are marked as REQUIRED.  This means, if removed that pose will not automatically
  # be called by the battle system.  For example, 'PAIN', 'WAIT', 'WALK' and 'COLLAPSE'.  
  # Each of those are applied as the system see's fit, but it calls them by NAME
  # So if you remove the name, it wont be able to locate a pose and will just stay
  # in the current one as a result. 
  #-------------------------------------------------------------
  DEFAULT_POSE_STANCES = 9 # Although there is only 8 because 9th is credits
  DEFAULT_POSE_FRAMES  = 4 # The Default number of Frames per pose
  DEFAULT_POSE_NUMBERS = { #these ones are for GTBS usage
  #-------------------------------------------------------------
  # NAME           ROW   
  #-------------------------------------------------------------
  "Wait"        => [1],  #required!
  "Idle"        => [1],
  "Walk"        => [2],  #required! 
  "Advance"     => [2], 
  "Retreat"     => [2], 
  "Attack"      => [3],  #required!
  "Special"     => [3],  #required! 
  "Skill"       => [3], 
  "Defend"      => [4],  #required!
  "Guard"       => [4],
  "Heal"        => [5],  #required!
  "Item"        => [5],
  "Use"         => [5],
  "Cast Charge" => [5],
  "Casting"     => [5],  #required!
  "Cast"        => [5],
  "Magic"       => [5],
  "Pain"        => [6],  #required!
  "Hurt"        => [6],
  "Damaged"     => [6],
  "Near Death"  => [7],
  "Critical"    => [7],
  "Danger"      => [7],  #required!  
  "Death"       => [8],
  "Dead"        => [8],
  "Collapse"    => [8]   #required!  
  }
  #-------------------------------------------------------------
  # Looping Stance
  #-------------------------------------------------------------
  # This is an array [1,2,3,4...] of each STANCE that should repeatably loop until
  # otherwise assigned.  All other poses, those not specified, should play once 
  # and stop.  If
  #-------------------------------------------------------------
  LOOPING_STANCE = [] + 
      DEFAULT_POSE_NUMBERS['Wait'] + 
      DEFAULT_POSE_NUMBERS['Walk'] + 
      DEFAULT_POSE_NUMBERS['Defend'] + 
      DEFAULT_POSE_NUMBERS['Dead'] +
      DEFAULT_POSE_NUMBERS['Near Death'];
  
      
  #-------------------------------------------------------------
  # Settings for Minkoff/Holder sprites
  #-------------------------------------------------------------
  MINKOFF_HOLDER_POSE_STANCES = 14  #Although there are only 13 as 14 is credits
  MINKOFF_HOLDER_POSE_FRAMES = 4
  
  #-------------------------------------------------------------
  # Note that many of these are duplicated.  This is only so that you can 
  # provide additional names to each pose.  It is done this way so that you can 
  # call the pose (by name) within an action using "animation user: pose NAME"
  #
  # Of course, however, you can always call the row manually as well using the 
  # row code:  "animation user: pose 3" 
  #-------------------------------------------------------------
  # Do not remove any of these, but feel free to add to them!  
  #-------------------------------------------------------------
  MINKOFF_HOLDER_POSE_NUMBERS = {
  #-------------------------------------------------------------
  # NAME        ROW   #Description
  #-------------------------------------------------------------
    "Wait"      => [1],   # REQUIRED
    "Idle"      => [1],   # Idle pose
    "Defend"    => [2],   # REQUIRED
    "Guard"     => [2],   # Guard pose
    "Evade"     => [2],   # Evade pose
    "Danger"    => [3],   # Low HP pose
    "Near Death"=> [3],   # REQUIRED 
    "Hurt"      => [4],   # Damage pose
    "Pain"      => [4],   # REQUIRED
    "Attack"    => [5],   # REQUIRED - Physical attack pose
    "Heal"      => [6],   # REQUIRED
    "Use"       => [6],   # No type use pose
    "Item"      => [6],   # Item use pose
    "Skill"     => [7],   # Skill use pose
    "Special"   => [7],   # Skill use pose
    "Magic"     => [8],   # Magic use pose
    "Advance"   => [9],   # REQUIRED - Advance pose
    "Retreat"   => [10],  # REQUIRED - Retreat pose
    "Escape"    => [10],  # Escape pose
    "Victory"   => [11],  # Victory pose
    "Intro"     => [12],  # Battle start pose
    "Dead"      => [13],  # Incapacited pose
    "Collapse"  => [13]   # REQUIRED
  }
  
  #-------------------------------------------------------------
  # Looping Stance MINKOFF
  #-------------------------------------------------------------
  # This is an array [1,2,3,4...] of each STANCE that should repeatably loop until
  # otherwise assigned.  All other poses, those not specified, should play once 
  # and stop.  
  #-------------------------------------------------------------
  LOOPING_STANCE_MINKOFF = [] + 
      MINKOFF_HOLDER_POSE_NUMBERS['Idle'] + 
      MINKOFF_HOLDER_POSE_NUMBERS['Advance'] + 
      MINKOFF_HOLDER_POSE_NUMBERS['Retreat'] + 
      MINKOFF_HOLDER_POSE_NUMBERS['Defend'] + 
      MINKOFF_HOLDER_POSE_NUMBERS['Dead'] +
      MINKOFF_HOLDER_POSE_NUMBERS['Near Death'];
  
  #-------------------------------------------------------------
  # Animation Speed Options
  #-------------------------------------------------------------
  DEFAULT_FRAME_SPEED       = 5 # The Default Framerate speed of the Battlers
  POSE_FRAME_OVERRIDE_ACTOR = {} # Use ActorID => {PoseID => FrameRate}
  POSE_FRAME_OVERRIDE_ENEMY = {} # Use EnemyID => {PoseID => FrameRate}
  
  
  #====================================================================#
  #***=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-***#
  # * Remaining settings apply to all animation types except Kaduki! * #
  #***=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-***#
  #====================================================================#
  
  #-------------------------------------------------------------
  # Custom Pose Setup - Applies to GTBS/Minkoff/Holder sprite types
  #-------------------------------------------------------------
  # This section allows you to customize your animated battlers further.  You can
  # expand the number of frames per pose, define additional poses, or setup a 
  # 'animation path' which allows you to use the same image portion more than once 
  # to reduce template sizes and make for more complex animations.
  #-------------------------------------------------------------
  EXTRA_ACTOR_STANCES = {}  #use ID => total number of stances for template
  EXTRA_ENEMY_STANCES = {}  #use ID => total number of stances for template
  EXTRA_ACTOR_FRAMES  = {}  #use PoseID(defined above) => number of frames
  EXTRA_ENEMY_FRAMES  = {}  #use PoseID(defined above) => number of frames
  
  # * Path Setup
  #-------------------------------------------------------------
  # If no path is defined, the system will assume direct left to right animation
  # Remember that 0 is the index of first frame while 1 is the second
  #-------------------------------------------------------------
  # Note: If you switch animation type this will still be used for the given pose
  # If you happen to referrence 6 frames and there are only 4, then the last 2
  # will be blank. 
  #-------------------------------------------------------------
  #Use ACT/EN_ID => { PoseID(defined above) => [frameindex, frameindex...]} }
  #-------------------------------------------------------------
  ACTOR_POSE_PATH = {1=> {5=>[5,4,3,2,1,0,1,2,3,4] } }
  ENEMY_POSE_PATH = {               }  #use PoseID(defined above) => [frameindex, frameindex...]
  
  #-------------------------------------------------------------
  # Randomized Attack - If POSE_NUMBERS["Attack"] contains more than one attack 
  # pose possiblity, or you want there to be an extra one for a particular actor
  # or enemy, they can be defined here.  Each Actor/Enemy ID must exist in here
  # for it to even be considered.  If the value is nil, then you are saying that 
  # you want it to randomize the POSE_NUMBERS["Attack"] pose selection, but if 
  # any other number is specified, it adds the number as a POSE_NUMBER to be used
  # when they attack.  
  #-------------------------------------------------------------
  # Exmaple:
  # EXTRA_ACTOR_ATTACK  = {1=>nil}  
  # ^ would mean that Actor1 should randomly choose an attack pose from the 
  # DEFAULT_POSE_NUBMERS["Attack"], if only one exist, then it will always be used
  # Example2:
  # EXTRA_ACTOR_ATTACK  = {1=>[12,13]}   
  # ^ would mean that Actor1 should take DEFAULT_POSE_NUBMERS["Attack"] and add
  # pose 12 and 13 to the list of possible random attack animations.  
  #-------------------------------------------------------------
  EXTRA_ACTOR_ATTACK  = {}
  EXTRA_ENEMY_ATTACK  = {}
  
  
  #-------------------------------------------------------------
  # Near Death Settings:  1-100
  #-------------------------------------------------------------
  # Allows you to define 'Near Death' management
  #-------------------------------------------------------------
  # Use Act/EN_ID => 1-100, which will be used as percent
  #-------------------------------------------------------------
  DEFAULT_ND_PERCENTAGE = 30
  ACTOR_ND_PERC_OVERRIDE = {}   
  ENEMY_ND_PERC_OVERRIDE = {}   
  
  #-------------------------------------------------------------
  # CUSTOM POSE ASSIGNMENT
  #-------------------------------------------------------------
  # This is where you can finish assigning how these additional poses
  # should be triggered, if any are defined.  
  #-------------------------------------------------------------
  # Dont forget however, that you can call the desired pose manually via 
  # action note text of "animation user: pose NAME" where NAME correspondes with 
  # a given animation pose.  If it is unrecognized, it will be ignored.
  #-------------------------------------------------------------
  # Use BattlerID => {DBAnimationId => PoseID}
  #-------------------------------------------------------------
  CUST_SKILL_POSE_ASSIGN_ACTOR = {}
  #CUST_SKILL_POSE_ASSIGN_ACTOR[ACTORID] = { ANIM_ID1 => POSE_ID, ANIM_ID2 => POSE_ID }
  CUST_SKILL_POSE_ASSIGN_ENEMY = {}
  
  #-------------------------------------------------------------
  # Pose Sound Association
  #-------------------------------------------------------------
  # As each spriteset stance, be it attack or defend, doesn't actually play any 
  # sound, this method will help you associate each 'animation' with a sound.  
  # Each sound is not just a sound filename or whatever.. what you will do is 
  # actually put in a different animation from the database which has the 
  # appropriate sounds to it(the stance), if any.  Be sure that whatever
  # animation id is selected, that it doesn't re-trigger the stance to play
  # again.  (Otherwise it would loop indefinitely)
  #-------------------------------------------------------------
  # Example:
  # ActorID => {POSE_ID => AnimationID}
  #-------------------------------------------------------------
  STANCE_SOUND_ASSOCIATION_ACTOR = {1=>{10=>2}}
  STANCE_SOUND_ASSOCIATION_ENEMY = {}
  
  

  
  
  
  
  
  
  
  
  
  #------------------------------------------------------------
  # Do not touch anything below here!
  #------------------------------------------------------------
  ANIMID_CHECK = [ANIM_ATK, ANIM_SPEC1, ANIM_CASTING, ANIM_CAST, ANIM_HEAL]
  for batkey in CUST_SKILL_POSE_ASSIGN_ACTOR.keys
    for animid in CUST_SKILL_POSE_ASSIGN_ACTOR[batkey].keys
      ANIMID_CHECK.push(animid)
    end
  end
  for batkey in CUST_SKILL_POSE_ASSIGN_ENEMY.keys
    for animid in CUST_SKILL_POSE_ASSIGN_ENEMY[batkey].keys
      ANIMID_CHECK.push(animid)
    end
  end
  
  ACTION_SKILLS  = {}
  ACTION_ITEMS   = {}
  ACTION_WEAPONS = {}
end