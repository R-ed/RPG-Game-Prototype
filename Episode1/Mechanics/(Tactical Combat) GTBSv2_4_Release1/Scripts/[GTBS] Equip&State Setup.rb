
module GTBS
  #=============================================================#
  #                      Weapon Setup                           #
  #=============================================================#  

  
  #-------------------------------------------------------------
  # default skill range modification for weapon, armors or state.
  # this should stay as no change
  # - fourth value is vertical range modifier for skill origin position
  # - fifth value is vertical range modifier for area of effect
  #-------------------------------------------------------------
  DEFAULT_Skill_Range_Mod = [0, 0, 0, 0, 0]
  #-------------------------------------------------------------
  # set weapon_range from character (all_to_target means it will affect all tiles to selected target)
  # [max_range, min_range, is_bow?, line_to_target?, AoE, vertical_range, vertical_range_aoe] 
  # AoE for weapons is not recommended, cause it lacks realism, but is available if desired.
  # Pattern, 0 = straight line only (-) while 1 = all between max range
  # Vertical range (in px) are used only in ISO mode
  #-------------------------------------------------------------
  # easy config (vertical ranges are optionnal):
  # range = [1, 0, false, false, 0] or [1, 0, false, false, 0, 24, 12]
  # is default range
  # Easy Config:
  #   'range=[max, min, bow, line, AOE(, vertical_range, vertical_range_aoe)]'
  #------------------------------------------------------------
  DEFAULT_Weapon_Range = [1, 0, false, false, 0, 24, 12]
  WEAPON_RANGE = {}
  
  #------------------------------------------------------------
  # Weapon Anchor Direction - Determines the direction in which the icon is 
  # anchored when the weapon is swung.  For example, 3, means to anchor in the 
  # lower right corner.  Meaning that that is the point of rotation for the weapon.
  #------------------------------------------------------------
  WEAPON_ANCHOR_DIR = {}
  
  #------------------------------------------------------------
  # Weapon Projectile
  #------------------------------------------------------------
  # This should be weaponid =>'arched' or 'normal' 
  # If another string is provided, it will be ignored
  # Easy Config:
  #   projectile=arched
  #   projectile=normal
  #------------------------------------------------------------
  WEAPON_PROJECTILE = {}

  #------------------------------------------------------------
  # Weapon Movement Modifier - Return the value to increase or decrease(-)
  # the movement for the character in which equips this weapon.
  #------------------------------------------------------------
  #easy config for move range modification
  # move_info = 0
  # is default 
  WEAPON_Move_Info = {}
  
  #------------------------------------------------------------
  # Chain Lightning Weapons
  #------------------------------------------------------------
  # [WeaponIDs...]
  # Easy Config: 'chain_lighting'
  #------------------------------------------------------------
  CHAIN_LIGHTNING_WEAPONS = []
  

  #------------------------------------------------------------
  # Weapon Skill Range Modification
  # THis allows you to modify the base skill range information by equipment 
  # allowing you to increase field area etc by the equip for the battler. 
  #------------------------------------------------------------
  #  WeaponID => [max_adj, min_adj, field_adj]
  # or WeaponID => [max_adj, min_adj, field_adj, vertical_adj, vertical_aoe_adj]
  #------------------------------------------------------------
  # easy config:
  # skill_range = [ 0, 0, 0] or skill_range = [0, 0, 0, 0, 0]
  # is default skill_range modification
  #------------------------------------------------------------
  Weapon_Skill_Range = {}
  
  #------------------------------------------------------------
  # Equip Skill Range Modification
  # THis allows you to modify the base skill range information by equipment 
  # allowing you to increase field area etc by the equip for the battler. 
  #------------------------------------------------------------
  # Return the following
  #   [max_adj, min_adj, field_adj]
  # or [max_adj, min_adj, field_adj, vertical_adj, vertical_aoe_adj]
  #------------------------------------------------------------
  # easy config:
  # skill_range = [0, 0, 0] or skill_range = [0, 0, 0, 0, 0]
  # is default skill_range modification
  #------------------------------------------------------------
  Equip_Skill_Range = {}
  
  
  #------------------------------------------------------------
  # Equipment Movement Modifier - Return the value to increase or decrease(-)
  # the movement for the character in which equips this armor*.
  #------------------------------------------------------------ 
  #easy config for move range modification
  # move_info = 0
  # is default  
  EQUIP_Move_Info = {}
  
  #------------------------------------------------------------
  # State Skill Range Modification
  # This Allows you to modify the base skill range information by state allowing 
  # you to increase field area etc by the states inflicted on the battler.
  #------------------------------------------------------------
  # Return the following
  #   [max_adj, min_adj, field_adj]
  # or [max_adj, min_adj, field_adj, vertical_adj, vertical_aoe_adj]
  #------------------------------------------------------------
  # DEFAULT is [0, 0, 0] = no change (or [0, 0, 0, 0, 0])
  # skill_range in state's page in the editor
  # Easy Config:
  #   'skill_range=[max, min, field]'
  # or 'skill_range=[max, min, field, vertical, vertical_aoe]'
  #------------------------------------------------------------
  STATE_SKILL_RANGE = {}
  
  #------------------------------------------------------------
  # State Movement Modifiers - Return the value to increase or decreate(-)
  # the movement for the affected character.
  #------------------------------------------------------------
  #easy config for move range modification
  # move_info = 0
  # is default
  STATE_Move_Info = {}
  
  #------------------------------------------------------------
  # Slip Damage Presets 
  # This feature allows manual entry of damage to occur during slip 
  # damage, this includes life gain when value is negative.  If item is false,
  # then the standard method of slip damage is used (10% of the afflicted maxhp)
  #------------------------------------------------------------
  #easy config:
  # drain = 0 is default
  # % is assumed
  #------------------------------------------------------------
  STATE_SLIP_DAMAGE = {}
  
  #------------------------------------------------------------
  # State Push Information
  #------------------------------------------------------------
  # This is used for push/pull state application.  
  # If the value is negative then it will PULL towards you.  Otherwise
  # it will push.
  #------------------------------------------------------------
  # STATE_PUSH_INFO[STATE_ID] = VALUE
  #------------------------------------------------------------
  # Easy Config:
  #   move=(-)3
  #------------------------------------------------------------
  STATE_PUSH_INFO = {}
  
  #------------------------------------------------------------
  # State View Info
  #------------------------------------------------------------
  # This is used to modify the "view_range" of a ai_controlled character
  # by the states that he currently has been inflicted with. 
  #------------------------------------------------------------
  # STATE_VIEW_INFO[ID] = modifier
  #------------------------------------------------------------
  # Easy Config:
  #   view=(-)5
  #------------------------------------------------------------
  STATE_VIEW_INFO = {}
  
  #------------------------------------------------------------
  # State Modify Tactic
  #------------------------------------------------------------
  # When this STATE is applied it will force the AI Tactic of the user to be
  # what is specified.  If Actor, it will force a NEUTRAL status on the actor 
  # (until the state is removed).  This can be used to imply "fear", "bloodlust" 
  # or other given the tactic options. 
  #------------------------------------------------------------
  # State_Modify_Tactic = {}
  # State_Modify_Tactic[STATE_ID] = "TACTIC_NAME"
  #------------------------------------------------------------
  # Easy Config:
  #  tactic=TACTIC_NAME
  #------------------------------------------------------------
  State_Modify_Tactic = {}
  
  #------------------------------------------------------------
  # Weapon/Equip Causes flight
  #------------------------------------------------------------
  # Pretty self explainitory.  Simply add the weapon/armor id to the list
  # When this is done, it will flag the actor as 'flying' when asked.  
  # Thus, you will be able to fly over obstables that would normally prevent
  # your movement. 
  #------------------------------------------------------------
  WeaponCausesFlight = []
  EquipCausesFlight = []
  StateCausesFlight = []
  
  WalkOnWater_Weapons = []
  WalkOnWater_Armors = []
  WalkOnWater_States = []
  

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# DO NOT CHANGE ANYTHING BELOW HERE!
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  #------------------------------------------------------------  
  # Anchor Dir For Weapon - Determines in the keypad direction that the icon 
  # should be anchored, for rotations.
  #------------------------------------------------------------
  def self.AnchorDirForWep(id)
    WEAPON_ANCHOR_DIR[id] || 3
  end  

  #------------------------------------------------------------
  # State Tactic
  #------------------------------------------------------------
  # Returns the string tactic associated with the given state
  #------------------------------------------------------------
  def self.state_tactic(state_id)
    State_Modify_Tactic[state_id] || ""
  end

  #------------------------------------------------------------
  # Equip Skill Range Modification
  # THis allows you to modify the base skill range information by equipment 
  # allowing you to increase field area etc by the equip for the battler. 
  #------------------------------------------------------------
  # Return the following
  #   [max_adj, min_adj, field_adj, vertical_adj, vertical_aoe_adj]
  #------------------------------------------------------------
  # easy config (vertical ranges are optionnal):
  # skill_range = [0, 0, 0] # is default 
  # or skill_range = [0, 0, 0, 0, 0]
  #------------------------------------------------------------
  def self.equip_skill_range_modification(equip_id, type=0)
    if type == 0
      if Equip_Skill_Range[equip_id]
        range = Equip_Skill_Range[equip_id]
        (range.size...DEFAULT_Skill_Range_Mod.size).each {|i|
          range << DEFAULT_Skill_Range_Mod[i]
        }
      else
        range = DEFAULT_Skill_Range_Mod
      end
    else
      if Weapon_Skill_Range[equip_id]
        range = Weapon_Skill_Range[equip_id]
        (range.size...DEFAULT_Skill_Range_Mod.size).each {|i|
          range << DEFAULT_Skill_Range_Mod[i]
        }
      else
        range = DEFAULT_Skill_Range_Mod
      end
    end
    return range
  end
    
  #-------------------------------------------------------------
  # set weapon_range from character (all_to_target means it will affect all tiles to selected target)
  # [max_range, min_range, is_bow?, line_to_target?, AoE, vertical_range, vertical_range_aoe] 
  # AoE for weapons is not recommended, cause it lacks realism, but is available if desired.
  # Pattern, 0 = straight line only (-) while 1 = all between max range
  # Easy Config: range=[max, min, bow, line, aoe]
  # or range=[max, min, bow, line, aoe, vertical_range, vertical_range_aoe]
  #-------------------------------------------------------------
  def self.weapon_range(id)
    #p "module weapon range check for id: #{id}, data for range: ", WEAPON_RANGE[id]
    if WEAPON_RANGE[id]
      range = WEAPON_RANGE[id]
      (range.size...DEFAULT_Weapon_Range.size).each {|i|
        range << DEFAULT_Weapon_Range[i]
      }
    else
      range = DEFAULT_Weapon_Range
    end
    return range
  end

  #------------------------------------------------------------
  # State Skill Range Modification
  # This Allows you to modify the base skill range information by state allowing 
  # you to increase field area etc by the states inflicted on the battler.
  #------------------------------------------------------------
  # Return the following
  #   [max_adj, min_adj, field_adj, vertical_adj, vertical_aoe_adj]
  # Easy Config:
  #   'skill_range=[max, min, field]'
  # or 'skill_range=[max, min, field, vertical, vertical_aoe]'
  #------------------------------------------------------------
  def self.state_skill_range_modification(state_id)
    if STATE_SKILL_RANGE[state_id]
      range = STATE_SKILL_RANGE[state_id]
      (range.size...DEFAULT_Skill_Range_Mod.size).each {|i|
        range << DEFAULT_Skill_Range_Mod[i]
      }
    else
      range = DEFAULT_Skill_Range_Mod
    end
    return range
  end   
  
  #------------------------------------------------------------
  # Equipment Movement Modifier - Return the value to increase or decrease(-)
  # the movement for the character in which equips this armor*.
  #------------------------------------------------------------  
  def self.equip_move_info(equip_id)
    EQUIP_Move_Info[equip_id] or 0
  end
  
  #------------------------------------------------------------
  # Weapon Movement Modifier - Return the value to increase or decrease(-)
  # the movement for the character in which equips this weapon.
  #------------------------------------------------------------
  def self.weapon_move_info(weapon_id)
    WEAPON_Move_Info[weapon_id] or 0
  end
  
  #------------------------------------------------------------
  # State Movement Modifiers - Return the value to increase or decreate(-)
  # the movement for the affected character.
  #------------------------------------------------------------
  def self.state_move_info(state_id)
    STATE_Move_Info[state_id] or 0
  end
  #------------------------------------------------------------
  # Weapon has projectile? - Return nil when no projectile referrence
  # otherwise return projectile arch type
  #------------------------------------------------------------
  def self.weapon_has_projectile?(id)
    if !(WEAPON_PROJECTILE.keys.include?(id))
      return nil
    else
      info = WEAPON_PROJECTILE[id]
      if info == 'arched'
        return info
      else
        return 'normal'
      end
    end
  end
  
end

