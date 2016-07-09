#===============================================================================
# This Script is made specfically for usage with GTBS version 1.5.1.4 by GubiD.
#===============================================================================
module GTBS
  #------------------------------------------------------------
  # When ENEMY_ID; return [[ITEM_TYPE, ID]]
  #-----
  # ITEM_TYPES:  
  #     0   -   Item
  #     1   -   Weapon
  #     2   -   Armor (Any type)
  #-----
  # EXAMPLE:  when 5; return [[0,1]] #this will give you a potion when enemy #5 is 
  #   killed by a "secret hunt" skill.
  #
  # Use Easy Config "hunt_result=[[item_type, id, rate]]"
  #
  # Use Easy Config 3 item: "hunt_result=[[0, 1,80], [2, 1,50], [1, 1,10]]"
  # Easy Config only allows up to 3 items returned.  More has to be configured
  # manually here.  Dont forget that NOTE overrides Manual, so delete note entry
  #------------------------------------------------------------
  DEFAULT_Secret_Hunt_Result = []
  Secret_Hunt_Results = {}
  
  #------------------------------------------------------------
  # Set move_range by monster_id
  #------------------------------------------------------------
  # MonsterID=>MoveAmt
  #------------------------------------------------------------
  #easy config for move enemy
  # move = 4
  # is default
  #------------------------------------------------------------
  Default_Enemy_Move = 4
  Enemy_Move = {} 
  
  #-------------------------------------------------------------    
  # Large Unit Configuration
  #-------------------------------------------------------------    
  # UNIT ID => SIZE (1=>3 is 3**2=9 squares in size
  #-------------------------------------------------------------    
  # Easy Config:
  #  large=2
  #-------------------------------------------------------------  
  En_large_units  = { }
  
  #------------------------------------------------------------
  # Enemies who fly - A list of enemy id's which always have flight
  #------------------------------------------------------------
  # Easy Config:
  #  fly = true
  #------------------------------------------------------------
  EnemiesWhoFly = []
  EnemiesWithWalkOnWater = []
  
  #------------------------------------------------------------
  # set initial range for monster by enemy_id  (this is the same 
  # as weapon checks for actors).  Technically no monster actually 
  # carries a weapon.
  # [Far_range, min_range, is_bow?, line to target?, AoE, vertical_range, vertical_range_aoe]
  # - is_bow is only used when "LSHAPE_BOWS" is enabled.
  # Vertical ranges (in px) are used only in ISO mode
  #------------------------------------------------------------
  # easy config:
  # w_range = [1,0, false, false, 0] or [1,0, false, false, 0, 24, 12]
  #------------------------------------------------------------
  DEFAULT_Monster_Range = [1, 0, false, false, 0, 24, 12]
  Enemy_Weapon_Range = {}
  
  #------------------------------------------------------------
  # EnemyID should cast projectile 
  #------------------------------------------------------------
  # EnemyID => 'arched' or 'normal'
  # Easy config:
  #  projectile=arched
  #  projectile=normal
  #------------------------------------------------------------
  En_Atk_Projectile = {}
  
  #------------------------------------------------------------
  # Capture Enemy to ActorID
  #------------------------------------------------------------
  # * ID is Enemy ID; return ActorID they should turn into
  #------------------------------------------------------------
  CAPTURE_TO_ACTOR = {}

  #-------------------------------------------------------------
  # Summon ENEMY_ID - List of database enemies that are summons
  #-------------------------------------------------------------
  # Easy Config
  # 'summon'
  #-------------------------------------------------------------
  SUMMON_ENID = []
  #-------------------------------------------------------------
  # Death Animation Enemey - Animation to be played when enemy dies in battle
  #-------------------------------------------------------------
  # Enemy_ID => AnimationID
  # Easy Config:
  #   death_anim=100
  #-------------------------------------------------------------
  DEATH_ANIMATION_ENEMY = {}
  
  #-------------------------------------------------------------
  # Enemy View Range
  #-------------------------------------------------------------
  # EnemyID=>RANGE
  # Easy Config: view=10
  #-------------------------------------------------------------
  # DEFAULT_VIEW_RANGE = 16, but is customized in AI_SETUP section
  #-------------------------------------------------------------
  ENEMY_VIEW_RANGE = {}
  
  #----------------------------------------------------
  # PREVENT_EN_WANDER - only applicable if ALLOW_AI_WANDER = true in AI setup
  #----------------------------------------------------
  # Prevent the following ENEMY_ID's from wandering
  # Easy Config:
  #  prevent_wander
  #----------------------------------------------------
  PREVENT_EN_WANDER = []
  
  #----------------------------------------------------
  # Enemy Weapon - The weapon id that should be used when they attack
  # easy config:
  # weapon=WepID, WepID,etc 
  # If only one, then only specify one.
  #----------------------------------------------------
  Enemy_Weapon = {}
  
  #----------------------------------------------------
  # Enemy Traverse Type
  #----------------------------------------------------
  # 0 - Normal
  # 1 - TileTag 1 does not affect movement #assumed Thick/Forest
  # 2 - TileTag 2 does not affect movement #assumed Rocky/Mountain
  # 3 - TileTag 1,2 does not affect movement
  #----------------------------------------------------
  # Add like:
  #  EnemyTraverseType[en_id] = TYPE
  # Easy Config:
  #  traverse=TYPE
  #----------------------------------------------------
  EnemyTraverseType = {}
  
  #----------------------------------------------------
  # The following Enemies cannot be invited to another troop/team
  #----------------------------------------------------
  Cannot_Invite_Enemies = []
  
  #----------------------------------------------------
  # Prevent Enemy Mini
  #----------------------------------------------------
  # Add ENEMY_ID to the list
  # Easy Config:
  #   no_mini
  #----------------------------------------------------
  Prevent_Enemy_Mini = []
  
  #----------------------------------------------------
  # Enemy Animation Mode
  #----------------------------------------------------
  # If unspecified, it will utilize DEFAULT_ANIMATION_METHOD from 
  # the animation config.
  #----------------------------------------------------
  # ENEMY_ID => ANIM_MODE
  # Easy Config: AnimMode=MINKOFF   
  # When using easy config, dont add the : at the front
  #----------------------------------------------------
  # Valid values
  # :GTBS
  # :MINKOFF (This should be used for HOLDER sprites)
  # :KADUKI
  # :CHARSET
  #----------------------------------------------------
  ENEMY_Animation_Mode = {}
  ENEMY_Animation_Mode[1] = :CHARSET
  
  
  #----------------------------------------------------
  # Same as above but for mini scene
  #----------------------------------------------------
  ENEMY_Animation_Mode_MINI = {}
  ENEMY_Animation_Mode_MINI[1] = :MINKOFF
end

class Game_Enemy < Game_Battler
  #----------------------------------------------------
  # AI Tactic to be used
  #----------------------------------------------------
  # ENEMY_ID => TACTIC_NAME
  # easy setup: tactic=TACTIC_NAME
  #----------------------------------------------------
  AI_Tactic = {}
  #----------------------------------------------------
  # Setup Unknown HP/MP for enemies
  #----------------------------------------------------
  # Use [EnemyID, EnemyID,...]
  #easy setup: unknown_hp
  #----------------------------------------------------
  Unknown_HP_MP = [33]
  
  #----------------------------------------------------
  # Enemy Element - Sets the Enemies Elemental Attack values
  # Use when id; return [elem_id1, elem_id2, etc]
  #----------------------------------------------------
  #easy setup: element=[elem_id]
  
  #----------------------------------------------------
  # Enemy State Add - Adds the state id's specified to the enemies attack
  # Use when id; return [state_id1, state_id2, etc]
  #----------------------------------------------------
  #easy setup: state_add= [state_id]
  
  EN_Desc_Default = "A cruel creature"
  EN_Descriptions = {} # use EN_ID => "A fowl beast from the depths of hell"
  
  DEFAULT_ENEMY_CLASS = "Monster"
  Enemy_Classes = {}
  
  Enemy_Levels = {}
  DEFAULT_EN_LVL = 1 #If 0 then it will be $game_party.highest_level-2
  
  Enemy_Face = {}
  DEFAULT_EN_FACE = ""
  
  Enemy_Face_Index = {}
  DEFAULT_EN_FACE_INDEX = 0
  
  Enemy_State_Add = {} #add using ENEMY_ID => [1st, 2nd, 3rd.. etc]
  DEFAULT_EN_STATES_TO_ADD = []
  
  
  #----------------------------------------------------
  # Dont touch this part please
  #----------------------------------------------------
  def weapon
    return (GTBS::Enemy_Weapon[@enemy_id] or 0)
  end
  def description
    return (EN_Descriptions[@enemy_id] or EN_Desc_Default)
  end
  def class_name
    return (Enemy_Classes[@enemy_id] or DEFAULT_ENEMY_CLASS)
  end
  def level
    return [1, $game_party.highest_level - 2].max if  DEFAULT_EN_LVL == 0
    return (Enemy_Levels[@enemy_id] or DEFAULT_EN_LVL)
  end
  def face_name
    return (Enemy_Face[@enemy_id] or DEFAULT_EN_FACE)
  end
  def face_index
    return (Enemy_Face_Index[@enemy_id] or DEFAULT_EN_FACE_INDEX)
  end
  def states_to_add
    return (Enemy_States_Add[@enemy_id] or DEFAULT_EN_STATES_TO_ADD)
  end
end
module GTBS
  #------------------------------------------------------------
  # set initial range for monster by enemy_id  (this is the same 
  # as weapon checks for actors).  Technically no monster actually 
  # carries a weapon.
  # [Far_range, min_range, is_bow?, line to target?, AoE, projectile?] - is_bow is only used when "LSHAPE_BOWS" 
  # is enabled.
  # MGC : seems projectile? isn't used
  # => [Far_range, min_range, is_bow?, line to target?, AoE, vertical_range, vertical_range_aoe]
  #------------------------------------------------------------
  # easy config:
  # w_range = [1,0, false, false, 0]
  # or w_range = [1,0, false, false, 0, 24, 12]
  # is default skill_range
  def self.monster_range(id) 
    if Enemy_Weapon_Range[id]
      range = Enemy_Weapon_Range[id]
      (range.size...DEFAULT_Monster_Range.size).each {|i|
        range << DEFAULT_Monster_Range[i]
      }
    else
      range = DEFAULT_Monster_Range
    end
    return range
  end
  #------------------------------------------------------------
  # Secret Hunt Result
  # returns the secret hunt items gained, if any. 
  # Manually edit Secret_Hunt_Results above or use easy config
  # 'hunt_result=[[item_type, id], [type, id]]'
  # Valid item_types are (0=item, 1=weapon, 2=armor)
  #------------------------------------------------------------
  def self.secret_hunt_result?(enemy_id)
    return (Secret_Hunt_Results[enemy_id] or DEFAULT_Secret_Hunt_Result)
  end
  
  #------------------------------------------------------------
  # Capture Enemy to ActorID
  #------------------------------------------------------------
  # * ID is Enemy ID; return ActorID they should turn into
  #------------------------------------------------------------
  def self.capture_to_actor(id)
    return ( CAPTURE_TO_ACTOR[id] or 0 )
  end
  
  #------------------------------------------------------------
  # Set move_range by monster_id
  #------------------------------------------------------------
  #easy config for large enemy
  # move = 4
  #------------------------------------------------------------
  def self.enemy_move(enemy_id)
    Enemy_Move[enemy_id] or Default_Enemy_Move
  end
  #-------------------------------------------------------------
  # Get Death Anim - Enemy
  #-------------------------------------------------------------
  def self.get_death_anim_enemy(actor_id)
    return ( DEATH_ANIMATION_ENEMY[actor_id] or 0 )
  end
  #-------------------------------------------------------------
  # Get View range by enemy-id
  #-------------------------------------------------------------
  def self.get_view_range(id, is_actor=false)
    if !is_actor
      range = (ENEMY_VIEW_RANGE[id] or DEFAULT_VIEW_RANGE)
    else
      range = (CLASS_VIEW_RANGE[id] or DEFAULT_VIEW_RANGE)
    end
  end
  #-------------------------------------------------------------
  # Enemy has projectile? - returns nil if no projectile data
  # otherwise returns projectile type (string)
  #-------------------------------------------------------------
  def self.enemy_has_projectile?(id)
    if (!En_Atk_Projectile.keys.include?(id))
      return nil
    else
      value = En_Atk_Projectile[id]
      if value == 'arched'
        return value
      else
        return 'normal'
      end
    end
  end
  #-------------------------------------------------------------
  # Get Enemy Traverse Type
  #-------------------------------------------------------------
  def self.get_en_traverse(id)
    return (EnemyTraverseType[id] || 0)
  end
end