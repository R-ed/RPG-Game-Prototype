#===============================================================================
# This Script is made specfically for usage with GTBS version 1.5.1.4 by GubiD.
#===============================================================================
module GTBS
  #-------------------------------------------------------------    
  # Prevent Dead Leave of the Following Character ID's
  #-------------------------------------------------------------    
  # Prevent_Actor_Leave_List = [1,2,3,4,5...]
  #-------------------------------------------------------------    
  # Easy Config:
  #  prevent_leave
  #-------------------------------------------------------------    
  Prevent_Actor_Leave_List = []
  
  #-------------------------------------------------------------    
  # Increment variable friendly kill
  #-------------------------------------------------------------    
  # Will increase specified variable id specified when ally kills an ally
  # 0 for disabled
  #-------------------------------------------------------------    
  Increment_Variable_Friendly_Kill = 0
  
  #-------------------------------------------------------------    
  # Large Unit Configuration
  #-------------------------------------------------------------    
  # UNIT ID => SIZE, be sure to include comma if you are going to make another,
  # otherwise you may get a syntax error.
  # Easy Config:
  #  large=2
  #-------------------------------------------------------------    
  Act_large_units = { }
  
  #------------------------------------------------------------
  # Set base move_range for actor by Char class_id
  #------------------------------------------------------------
  # ClassID => Range
  # Easy Config:
  #   'move=4'
  #------------------------------------------------------------
  DEFAULT_CLASS_Move = 4
  CLASS_MOVE_RANGE = { }
  
  #-------------------------------------------------------------
  # DOOM_SUMMON_TURN
  #-------------------------------------------------------------
  # Turns until doom takes effect - especially for summons, so that 
  # its not so random.  Default is random value between 2 and 8 turns. 
  #-------------------------------------------------------------
  DOOM_SUMMON_TURN = {}
  
  #-------------------------------------------------------------
  # Death Animation Actor
  #-------------------------------------------------------------
  # Returns the Animation ID that should be played when this actor dies in battle
  #-------------------------------------------------------------
  DEATH_ANIMATION_ACTOR = {}
  
  #-------------------------------------------------------------
  # Actor AI
  # ActorID=>TACTIC_NAME (as defined in AI Setup)
  # Easy config:
  #  tactic=TACTIC_NAME
  #-------------------------------------------------------------
  Actor_AI = {}
  
  #-------------------------------------------------------------
  # Class View Range
  #-------------------------------------------------------------
  # ClassID=>RANGE
  # Easy Config: view=10
  #-------------------------------------------------------------
  # DEFAULT_VIEW_RANGE = 16, but is customized in AI_SETUP section
  #-------------------------------------------------------------
  CLASS_VIEW_RANGE = {}
  
  #----------------------------------------------------
  # PREVENT_ACT_WANDER - only applicable if ALLOW_AI_WANDER = true in AI setup
  #----------------------------------------------------
  # Prevent the following ACTOR_ID's from wandering
  # Easy Config:
  #  prevent_wander
  #----------------------------------------------------
  PREVENT_ACT_WANDER = []
  
  #----------------------------------------------------
  # Actor Traverse Type
  #----------------------------------------------------
  # 0 - Normal
  # 1 - TileTag 1 does not affect movement #assumed Thick/Forest
  # 2 - TileTag 2 does not affect movement #assumed Rocky/Mountain
  # 3 - TileTag 1,2 does not affect movement
  #----------------------------------------------------
  # Add like:
  #  ActorTraverseType[act_id] = TYPE
  # Easy Config:
  #  traverse=TYPE
  #----------------------------------------------------
  ActorTraverseType = {}
  
  #----------------------------------------------------
  # The following actors cannot be 'invited' to another team
  #----------------------------------------------------
  Cannot_Invite_Actors = []
  
  #----------------------------------------------------
  # Prevent Actor Mini
  #----------------------------------------------------
  # Add ACTOR_ID to the list
  # Easy Config:
  #   no_mini
  #----------------------------------------------------
  Prevent_Actor_Mini = []
  
  #----------------------------------------------------
  # Actor Animation Mode
  #----------------------------------------------------
  # If unspecified, it will utilize DEFAULT_ANIMATION_METHOD from 
  # the animation config. Remember, this will only work with the MINI
  # scene enabled within GTBS.  Additionally, the text "_mini" will be added
  # to your battler image name when the mini is called.  While technically the 
  #----------------------------------------------------
  # ACTOR_ID => ANIM_MODE
  # Easy Config: AnimMode=MINKOFF   
  # When using easy config, dont add the : at the front
  #----------------------------------------------------
  # Valid values
  # :GTBS
  # :MINKOFF (This should be used for HOLDER sprites) #only valid for mini!
  # :KADUKI
  # :CHARSET
  #----------------------------------------------------
  # In game code for updating the animation mode
  #  $game_actors[ID].anim_mode="GTBS" 
  #  $game_actors[ID].anim_mode_mini="GTBS" 
  #  This will also accept: "HOLDER", "MINKOFF", "KADUKI"
  #----------------------------------------------------
  ACTOR_Animation_Mode = {}
  ACTOR_Animation_Mode[1] = :GTBS
  #ACTOR_Animation_Mode[2] = :KADUKI
  
  #----------------------------------------------------
  # Same as above, but applies to the mini scene
  #----------------------------------------------------
  ACTOR_Animation_Mode_MINI = {}
  ACTOR_Animation_Mode_MINI[1] = :CHARSET

  
  
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Please do NOT change settings below this point
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  
  #------------------------------------------------------------
  # Set base move_range for actor by Char class_id
  #------------------------------------------------------------
  def self.move_range(class_id) 
    CLASS_MOVE_RANGE[class_id] or DEFAULT_CLASS_Move
  end
  
  #-------------------------------------------------------------
  # Turns until doom takes effect - especially for summons, so that 
  # its not so random
  #-------------------------------------------------------------
  def self.doom_turn?(actor_id)
    return (DOOM_SUMMON_TURN[actor_id] or [2,rand(8)].max)
  end
  #-------------------------------------------------------------
  # Get Death Anim - Actor
  #-------------------------------------------------------------
  def self.get_death_anim_actor(actor_id)
    return ( DEATH_ANIMATION_ACTOR[actor_id] or 0 )
  end
  #-------------------------------------------------------------
  # Get Actor Traverse Type
  #-------------------------------------------------------------
  def self.get_act_traverse(id)
    return (ActorTraverseType[id] || 0)
  end
end

