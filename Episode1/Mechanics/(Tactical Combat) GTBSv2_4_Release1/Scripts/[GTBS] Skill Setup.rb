module GTBS
  #-------------------------------------------------------------
  # Chain Lightning Effects - You can change the length of the curve and it 
  # will use it accordingly.  All values are percentages of effect. 80% normal 
  # effect on 2nd target and 40% on 3rd and 20% on all others.
  #-------------------------------------------------------------
  CHAIN_LIGHTNING_CURVE = [80, 40, 20]
  
  #-------------------------------------------------------------
  # Chain Lightning Effect Skills
  # Easy Config: 'chain_lightning'
  #-------------------------------------------------------------
  CHAIN_LIGHTNING_SKILLS = []
  
  #-------------------------------------------------------------
  # Auto Doom Summons?
  #-------------------------------------------------------------
  DOOM_SUMMONS = true
  
  #-------------------------------------------------------------
  # Controlable Summons - summons that can be controlled instead of AI controlled
  # Easy Config: 'controllable'
  #-------------------------------------------------------------
  CONTROLABLE_SUMMONS = []
  
  #-------------------------------------------------------------
  # Actors that are summons
  # Easy Config: 'summon'
  #-------------------------------------------------------------
  ACTOR_SUMMONS = [] #ID's of actors that are summons. 
  
  #-------------------------------------------------------------
  # Summon Instances Allowed
  #-------------------------------------------------------------
  # This allows you to say that SummonID can be called X amount of times on 
  # current map. 
  # Use SummonID => AmountInstances
  # Easy Config => 'allowed=2' # 1 by default
  #-------------------------------------------------------------
  SUMMON_INSTANCES_ALLOWED = {  }  #actor_id => CountAllowed
  
  #-------------------------------------------------------------
  # Summon Gain EXP?
  #-------------------------------------------------------------
  # Enabling this option causes 'SUMMON INSTANCES ALLOWED' to never
  # allow more than 1.
  #-------------------------------------------------------------
  SUMMON_GAIN_EXP = true
  
  #-------------------------------------------------------------
  # Skill -> Summon Character ID
  #-------------------------------------------------------------
  # easy config: add this tag
  # summon = 36
  # to summon actor #36 with this skill
  #------------------------------------------------------------
  SKILL_TO_ACTOR_SUMMON = {  } #skill_id => ActorID
  SKILL_TO_ENEMY_SUMMON = {  } #skill_id => EnemyID

  #------------------------------------------------------------
  # Does skill use current turn's "Action"
  #------------------------------------------------------------
  # This setting allows you to state if this skill will use your turn action.  
  # Use by setting 'When SKILL_ID; return false", where false means that it will 
  # not use your 'action' for the given turn.  It will simply perform the action
  # then return you to the select phase. 
  #------------------------------------------------------------
  Max_Turn_Skill_Usage = 2 # The # of skills that can be perform in any given turn
  
  #------------------------------------------------------------
  # Skill Wait
  #  This item determines the Casting Time for a skill.  
  #  Items set for 0 are immediate action skills
  # [Cast_time, ATB_recover, End_Turn]
  #------------------------------------------------------------
  # easy config:
  # skill_wait = [0, 100, false]
  # is default
  #------------------------------------------------------------
  DEFAULT_Skill_Wait = [0, 100, false]
  SKILL_WAIT_TIME = {}
  
  #------------------------------------------------------------
  # Set range and field by skill_id.  Line Skills are skills in which affect the 
  # entire range in the specified direction.  This means that the range is really 
  # a line itself, instead of the area.   Line Skills are not currently available!
  # This value is same for both characters and enemies
  #[range_max, Field, LINE_SKILL?, exclude_caster?, range_min(, vertical_range, vertical_range_aoe)]
  # Vertical ranges (in px) are used only in ISO mode
  #------------------------------------------------------------  
  # easy config (vertical ranges are optionnal):
  # range = [1, 0, false, false, 0] or [1, 0, false, false, 0, 24, 24]
  # is default range
  DEFAULT_Skill_Range = [1, 0, false, false, 0, 24, 24]
  SKILL_RANGE = {}
  
  #------------------------------------------------------------
  # SKILL_PROJECTILE
  #------------------------------------------------------------
  # SKILL_ID => 'arched' or 'normal'
  #------------------------------------------------------------
  SKILL_PROJECTILE = {}
  
  #------------------------------------------------------------
  # Get Skill Rating - Determines the 'rating' in which a actor/neutral will 
  # rate the given skill when under AI control.  Note the higher the rating the 
  # higher its likelyhood of being selected by the AI. 
  #------------------------------------------------------------ 
  #------------------------------------------------------------
  # easy config:
  # ai_rating = 4 #means this skill is 4x more likely to be used 
  # is default skill_range modification
  DEFAULT_Skill_Rating = 1
  SKILL_AI_RATING = {}
  
  #------------------------------------------------------------
  # Secret_Hunt_Skill_List
  # Maintains list of skills that are secret hunt* enabled. 
  #----
  # Example: Secret_Hunt_Skill_List[skill_id...]
  # Easy Config: secret_hunt
  #------------------------------------------------------------
  Secret_Hunt_Skill_List = []
  
  #------------------------------------------------------------
  # Drain Skill
  #------------------------------------------------------------
  # When SKILL_ID; return DrainAmt%
  #------------------------------------------------------------
  #easy config:
  # drain = 0
  # is default 
  SKILL_DRAIN = {}
  
  #------------------------------------------------------------
  # Does skill use current turn's "Action"
  #------------------------------------------------------------
  # SkillID => true/false
  # Easy Config:
  #  use_action=true
  #  use_action=false
  #------------------------------------------------------------
  DEFAULT_Skill_Usage = true; #Defines that all skills, unless defined
  # here, will use (or not use) the turns 'action phase'.
  SKILL_USE_ACTION = {}
  
  
  
  #------------------------------------------------------------
  # Prevent Friendly Damage Skills
  #------------------------------------------------------------
  # Skills that, when attack allies, would normally cause damage
  # should still not deliver damage to friendly units. 
  #------------------------------------------------------------
  PREVENT_SKILL_FRIENDLY_DMG = []
  
  #------------------------------------------------------------
  # Target Friendly Only Skils
  #------------------------------------------------------------
  # Forces skill to only return target allies in the area when 
  # Attack_Allies option is enabled. 
  #------------------------------------------------------------
  TARGET_FIENDLY_ONLY_SKILLS = []
  
  
  #------------------------------------------------------------
  # When a hit is delivered, this skill has a chance of 'capturing' 
  # enemy unit
  #------------------------------------------------------------
  # Easy Config:
  #  capture
  #------------------------------------------------------------
  Capture_Skill_List = []
  
  #------------------------------------------------------------
  # Capture Animation ID
  #------------------------------------------------------------
  # The Animation_ID to be played when a 'capture' occurs
  # If 0, then no animation will be played. 
  #------------------------------------------------------------
  CAPTURE_ANIMATION = 0
  
  #------------------------------------------------------------
  # Charm Skill ID list
  #------------------------------------------------------------
  # This list contains all the SKILL_ID's that will set a charm state
  # Add items to here using Charm_Skill_List[SKILL_ID] = TURNS TO CHARM
  #------------------------------------------------------------
  Charm_Skill_List = {}
  
  #------------------------------------------------------------
  # Default Charm Time
  #------------------------------------------------------------
  # Integer equal to or greater than 0
  # If value is less than zero it may not function
  #------------------------------------------------------------
  DEFAULT_CHARM_TIME = 2
  
  #------------------------------------------------------------
  # Invite Skill ID List
  #------------------------------------------------------------ 
  # This list contains all the SKILL_ID's that will invite a player from 
  # another team to the acting party.  If successful, the target will join
  # that team permanently. Even if an actor was invited to an enemy team. 
  #------------------------------------------------------------
  Invite_Skill_List = []
  
  #------------------------------------------------------------
  # Prevent Actors from Leaving Party when invited to enemy troop at end of battle
  #------------------------------------------------------------
  Prevent_Invite_Leave = false
  
  #------------------------------------------------------------
  # Prevent Skill Equip/State Range Modification
  #------------------------------------------------------------
  # Add Skills to this list to prevent them from being modified
  # by equipment or state. 
  #------------------------------------------------------------
  Prevent_Skill_Range_Mod = []
  
  #------------------------------------------------------------
  # Ignore Directional DMG Modification
  #------------------------------------------------------------
  # In Script Insertion:
  #  Skill_Ignore_DirectionalDmg << SKILL_ID
  #------------------------------------------------------------
  # Easy Config:
  #  ignore_dir
  #------------------------------------------------------------
  Skill_Ignore_DirectionalDmg = []
  
  #------------------------------------------------------------
  # Reset Move Flag Skills
  #------------------------------------------------------------
  # Add skill id's that should reset the actor/enemies move flag for the current
  # turn.  Only Applicable when TEAM_MODE
  #------------------------------------------------------------
  # Reset_Move_Flag_Skills[1,2,3,4,5...]
  #------------------------------------------------------------
  # Easy Config:
  #   reset_move
  #------------------------------------------------------------
  Reset_Move_Flag_Skills = []
  
  #------------------------------------------------------------
  # Reset Action Flag Skills
  #------------------------------------------------------------
  # Add skill id's that should reset the actor/enemies action flag for the current
  # turn.  Reseting the current players action will NOT allow them to act more 
  # than once.  If you want them to not use their action, then setup the skill
  # uses action section.  Only Applicable when TEAM_MODE. 
  #------------------------------------------------------------
  # Reset_Action_Flag_Skills[1,2,3,4,5...]
  #------------------------------------------------------------
  # Easy Config:
  #   reset_action
  #------------------------------------------------------------
  Reset_Action_Flag_Skills = []
  
  DEFAULT_SKILL_USER_ANIMATION = 107
  
  
  #------------------------------------------------------------
  # Default ACTION_LIST constants
  #------------------------------------------------------------
  # Only modify these if you know what your doing.  As it these are utilized by 
  # the battle system to determine what should be done when you start an action.
  #------------------------------------------------------------
  DEFAULT_ACTION_LIST_PHYSICAL = []
  DEFAULT_ACTION_LIST_PHYSICAL << ["message", "", ["show"]]
  DEFAULT_ACTION_LIST_PHYSICAL << ["animation", "user", ["pose approach"]]
  DEFAULT_ACTION_LIST_PHYSICAL << ["move", "user", ["target body", "jump 2", "time 20"]]
  DEFAULT_ACTION_LIST_PHYSICAL << ["wait", "", ["16"]]
  DEFAULT_ACTION_LIST_PHYSICAL << ["animation", "user",["pose attack"]]
  DEFAULT_ACTION_LIST_PHYSICAL << ["wait", "", ["32"]]
  DEFAULT_ACTION_LIST_PHYSICAL << ["animation", "user", ["wep1"]]
  DEFAULT_ACTION_LIST_PHYSICAL << ["animation", "user", ["wep2"]]
  DEFAULT_ACTION_LIST_PHYSICAL << ["animation", "target", ["skill"]]
  DEFAULT_ACTION_LIST_PHYSICAL << ["move", "target", ["away 10", "time 3"]]
  DEFAULT_ACTION_LIST_PHYSICAL << ["wait", "", ["6"]]
  DEFAULT_ACTION_LIST_PHYSICAL << ["animation", "target", ["pose retreat"]]
  DEFAULT_ACTION_LIST_PHYSICAL << ["move", "target", ["return", "time 20"]]
  DEFAULT_ACTION_LIST_PHYSICAL << ["animation", "user", ["pose retreat"]]
  DEFAULT_ACTION_LIST_PHYSICAL << ["move", "user", ["return", "time 20"]]
  #------------------------------------------------------------
  DEFAULT_ACTION_LIST_MAGICAL  = []
  DEFAULT_ACTION_LIST_MAGICAL << ["message", "", ["show"]]
  DEFAULT_ACTION_LIST_MAGICAL << ["animation", "user", ["pose approach"]]
  DEFAULT_ACTION_LIST_MAGICAL << ["move", "user", ["forward 64"]]
  DEFAULT_ACTION_LIST_MAGICAL << ["wait", "", ["16"]]
  DEFAULT_ACTION_LIST_MAGICAL << ["animation", "user",["pose magic"]]
  DEFAULT_ACTION_LIST_MAGICAL << ["wait", "", ["32"]]
  DEFAULT_ACTION_LIST_MAGICAL << ["animation", "target", ["skill"]]
  DEFAULT_ACTION_LIST_MAGICAL << ["move", "target", ["away 10", "time 3"]]
  DEFAULT_ACTION_LIST_MAGICAL << ["wait", "", ["6"]]
  DEFAULT_ACTION_LIST_MAGICAL << ["animation", "target", ["pose retreat"]]
  DEFAULT_ACTION_LIST_MAGICAL << ["move", "target", ["return", "time 10"]]
  DEFAULT_ACTION_LIST_MAGICAL << ["animation", "user", ["pose retreat"]]
  DEFAULT_ACTION_LIST_MAGICAL << ["move", "user", ["return", "time 20"]]
  
  
  
  #------------------------------------------------------------
  # Default Action List Skill
  #------------------------------------------------------------
  # The action list that will be executed if no category is defined for
  # the skill.  Effectively the default skill action list for all skills
  # unless otherwise defined. 
  #------------------------------------------------------------
  DEFAULT_ACTION_LIST_SKILL = DEFAULT_ACTION_LIST_PHYSICAL
  
  
  
  #------------------------------------------------------------
  # Skill Category Default Action List
  #------------------------------------------------------------
  # As each skill can be assigned to the desired skill category, you may want to 
  # have a default action that is applied to all skills in that category.  Hence 
  # not requiring you to type it out in every skill note!  If you however, do
  # provide a 'action_list' in the skill, that will be used regardless of the 
  # default assigned here. 
  #------------------------------------------------------------
  # If no default for the skill category is defined here, the DEFAULT_ACTION_LIST_SKILL
  # will be utilized as defined above as a failsafe. 
  #------------------------------------------------------------
  SKILL_CATEGORY_DEFAULT_ACTION_LIST = {}
  #------------------------------------------------------------
  # Add to this using [CATEGORY_ID] = ACTION_LIST
  #------------------------------------------------------------
  #SKILL_CATEGORY_DEFAULT_ACTION_LIST[1] = [];
  #SKILL_CATEGORY_DEFAULT_ACTION_LIST[1] << ["ACTION_TYPE", "ACTION_TARGET", ["EXTRA_PARAMS"]]
  SKILL_CATEGORY_DEFAULT_ACTION_LIST[2] = DEFAULT_ACTION_LIST_MAGICAL #Magic (by default)
  
  
  
  
  #------------------------------------------------------------
  # DO NOT CHANGE ANYTHING BELOW HERE!
  #------------------------------------------------------------
  
  
  
  
  
  
  
  
  
  
  
  
  
  #------------------------------------------------------------
  # DO NOT CHANGE ANYTHING BELOW HERE!
  #------------------------------------------------------------
  
  #------------------------------------------------------------
  # Prevent Invite
  #------------------------------------------------------------
  # Prevents the particular enemy/actor from being invited to any 
  # other team/troop.
  #------------------------------------------------------------
  def self.prevent_invite(id, is_enemy)
    return Cannot_Invite_Enemies.include?(id) if is_enemy
    return Cannot_Invite_Actors.include?(id)
  end
  
  #------------------------------------------------------------
  # Skill Has Charm - returns true/false if the skill id is a charm skill
  #------------------------------------------------------------
  def self.skill_has_charm?(skill_id)
    return Charm_Skill_List.keys.include?(skill_id)
  end
  
  #------------------------------------------------------------
  # Charm Turns - returns the turn count for the skill id.  If none, then 
  # return default value.
  #------------------------------------------------------------
  def self.charm_turns(skill_id)
    return (Charm_Skill_List[skill_id] || DEFAULT_CHARM_TIME)
  end
  
  #------------------------------------------------------------
  # Skill Has Invite - returns true/false if the skill id is a invite skill
  #------------------------------------------------------------
  def self.skill_has_invite?(skill_id)
    return Invite_Skill_List.include?(skill_id)
  end
  
  #------------------------------------------------------------
  # Skill Has Capture - returns true/false if the skill id is a capture skill
  #------------------------------------------------------------
  def self.skill_has_capture?(skill_id)
    return Capture_Skill_List.include?(skill_id)
  end

  #------------------------------------------------------------
  # Get Animation Data for skill_id
  #------------------------------------------------------------ 
  def self.get_anime_animation_data(skill_id)
    # old method
    # return (ANIME_ACTION_SEQUENCE[ACTION_ANIME[skill_id]] or DEFAULT_ACTION_ANIME)
    #------
    #p "Skill id #{skill_id}"
    #p GTBS::ACTION_SKILLS[skill_id]
    #p "Skill Category #{$data_skills[skill_id].stype_id}"
    #p SKILL_CATEGORY_DEFAULT_ACTION_LIST[$data_skills[skill_id].stype_id]
    #p DEFAULT_ACTION_LIST_SKILL
    act_list = GTBS::ACTION_SKILLS[skill_id]
    if act_list == []
      act_list = (SKILL_CATEGORY_DEFAULT_ACTION_LIST[$data_skills[skill_id].stype_id] || DEFAULT_ACTION_LIST_SKILL)
    end
    return  act_list
  end
  
  #------------------------------------------------------------
  # Set range and field by skill_id.  Line Skills are skills in which affect the 
  # entire range in the specified direction.  This means that the range is really 
  # a line itself, instead of the area.   Line Skills are not currently available!
  # This value is same for both characters and enemies
  #[range_max, Field, LINE_SKILL?, exclude_caster?, range_min, vertical_range, vertical_range_aoe]
  #------------------------------------------------------------
  def self.skill_range(id)
    if SKILL_RANGE[id]
      range = SKILL_RANGE[id]
      (range.size...DEFAULT_Skill_Range.size).each {|i|
        range << DEFAULT_Skill_Range[i]
      }
    else
      range = DEFAULT_Skill_Range
    end
    return range
  end
  #------------------------------------------------------------
  # Get Skill Rating - Determines the 'rating' in which a actor/neutral will 
  # rate the given skill when under AI control.  Note the higher the rating the 
  # higher its likelyhood of being selected by the AI. 
  #------------------------------------------------------------
  def self.get_skill_rating(skill_id)
    SKILL_AI_RATING[skill_id] or DEFAULT_Skill_Rating
  end
  
  #------------------------------------------------------------
  # Drain Skill
  #------------------------------------------------------------
  # When SKILL_ID; return DrainAmt%
  #------------------------------------------------------------
  def self.drain_skill?(skill_id)
    SKILL_DRAIN[skill_id] or 0
  end
  
  #------------------------------------------------------------
  # Skill Wait
  #  This item determines the Casting Time for a skill.  
  #  Items set for 0 are immediate action skills
  # default is immediat skill
  #------------------------------------------------------------ 
  def self.skill_wait(id)
    return (sk_wait = SKILL_WAIT_TIME[id] or DEFAULT_Skill_Wait)
  end
  
  #------------------------------------------------------------
  # Skill use action
  #------------------------------------------------------------
  def self.skill_use_action?(skill_id)
    return (SKILL_USE_ACTION[skill_id] or DEFAULT_Skill_Usage)
  end 
  
  #-------------------------------------------------------------
  # Skill -> Summon Character ID
  #-------------------------------------------------------------
  def self.is_summon?(skill_id, is_for_actor)
    skill = $data_skills[skill_id]
    if is_for_actor and skill and (summon = SKILL_TO_ACTOR_SUMMON[skill_id])
      return summon
    elsif !is_for_actor and skill and (summon = SKILL_TO_ENEMY_SUMMON[skill_id])
      return summon
    else
      return 0
    end
  end
  #------------------------------------------------------------
  # Skill Has Secret Hunt? 
  # Will return if the current skill id has secret hunt attribute
  # Set manually in the "Secret_Hunt_Skill_List" has using 
  # Secret_Hunt_Skill_List[id] = true
  # Or use easy config (skill note entry) - "secret_hunt=true"
  # Default is FALSE
  #------------------------------------------------------------
  def self.skill_has_secret_hunt?(skill_id)
    return Secret_Hunt_Skill_List.include?(skill_id)
  end
  #------------------------------------------------------------
  # Get Summon Instance Count
  #------------------------------------------------------------
  def self.get_summon_instance_count(summon_id)
    return (SUMMON_INSTANCES_ALLOWED[summon_id] or 1 )
  end
  #------------------------------------------------------------
  # Skill has projectile? - Returns nil if no projectile data
  # otherwise returns projectile type
  #------------------------------------------------------------
  def self.skill_has_projectile?(id)
    if !(SKILL_PROJECTILE.keys.include?(id))
      return nil
    else
      result = SKILL_PROJECTILE[id]
      if result == 'arched'
        return result
      else
        return 'normal'
      end
    end
  end
  
  def self.skill_ignore_dmg_dir(skill_id)
    return !Skill_Ignore_DirectionalDmg.include?(skill_id)
  end
end
