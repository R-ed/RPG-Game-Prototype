#===============================================================================
# This Script is made specfically for usage with GTBS version 1.5.1.4 by GubiD.
#===============================================================================

#--------------------------------------------------------------------------
# Game Enemy - Updates for GTBS
#--------------------------------------------------------------------------
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  attr_reader :enemy_id
  #--------------------------------------------------------------------------
  # Constants
  #--------------------------------------------------------------------------

  #--------------------------------------------------------------------------
  # Object Initialization - Get name and set character_hue
  #--------------------------------------------------------------------------
  alias initialize_enemy initialize
  def initialize(*args)
    initialize_enemy(*args)
    enemy = $data_enemies[@enemy_id]
    @name = enemy.name
  end
  #--------------------------------------------------------------------------
  # Init Team
  #--------------------------------------------------------------------------
  def init_team
    @team = "enemy"
  end
  def nickname
    return name
  end
  #--------------------------------------------------------------------------
  # Returns list of weapons this enemy carries
  #--------------------------------------------------------------------------
  def weapons
    if @weapons.nil?
      @weapons = []
      weps = GTBS::Enemy_Weapon[@enemy_id] || []
      for i in 0...weps.size
        @weapons << $data_weapons[weps[i]]
      end
    end
    return @weapons
  end
  #--------------------------------------------------------------------------
  # Enemy Index within Troop
  #--------------------------------------------------------------------------
  def index
    $game_troop.members.index(self)
  end
  #--------------------------------------------------------------------------
  # State Skill Mod? - Returns the range data for skill modify by states
  #--------------------------------------------------------------------------
  def skill_range_mod?(range_data)
    #---------
    #range_data = [range_max, Field, LINE_SKILL?, exclude_caster?, range_min]
    #---------
    max     = range_data[0]
    min     = range_data[4]
    field   = range_data[1]
    v_range = range_data[5] # mod MGC
    v_range_aoe = range_data[6] # mod MGC
    #-------------------------
    # Update range data by state
    #-------------------------
    for state in states
      data = GTBS.state_skill_range_modification(state.id)
      max += data[0]
      min += data[1]
      field += data[2]
      v_range += data[3] # mod MGC
      v_range_aoe += data[4] # mod MGC
    end
    #-------------------------
    # Update Range Data
    # Ensure data is within valid ranges
    #-------------------------
    range_data[0] = [max, 0].max
    range_data[4] = [[min, max].min, 0].max
    range_data[1] = [field, 0].max
    range_data[5] =  v_range # mod MGC
    range_data[6] =  v_range_aoe # mod MGC
    return range_data
  end
  #--------------------------------------------------------------------------
  # Adjust Range for Summon - Determines if skill is summon type and reduces field
  # range to 0
  #--------------------------------------------------------------------------
  def adjust_range_for_summon(range_data, skill_id)
    if range_data[1] > 0 and GTBS.is_summon?(skill_id, false) > 0
      range_data[1] = 0
    end
    return range_data
  end
  #--------------------------------------------------------------------------
  # Hide Info? - Used by Window_Status_TBS to determine if to hide hp/mp/at
  #--------------------------------------------------------------------------
  def hide_info?
    return Unknown_HP_MP.include?(@enemy_id)
  end
  #-----------------------------------------------------------------
  #* will enemy show his move ?
  #-----------------------------------------------------------------
  def hide_move?
    return GTBS::HIDE_EN_MOVE
  end
  #--------------------------------------------------------------------------
  # Character Name - returns the battler name during battle
  #--------------------------------------------------------------------------
  def character_name
    return "$" + @battler_name + "_down" if death_state? && $game_system.enemies_bodies? && !animated?
    name = "$" + @battler_name
    if in_gtbs_battle? 
      if SceneManager.scene.mini_showing
        name += GTBS::MINI_Battler_Suffix unless GTBS::Prevent_Enemy_Mini.include?(self.enemy_id)
        name += kaduki_pose_suffix if anim_mode == :KADUKI#kaduki mini suffix add
      else
        name += kaduki_pose_suffix if anim_mode == :KADUKI#kaduki mini suffix add
      end
    end
    return name
  end
  #-----------------------------------------------------------------
  #* will actor collapse?
  #----------------------------------------------------------------
  def will_collapse? 
    return true if !$game_system.enemies_bodies?
    return true if self.is_summoned?
    return false
  end
  #--------------------------------------------------------------------------
  # * Get Normal Attack Element
  #--------------------------------------------------------------------------
  def element_set
    return self.en_element(@enemy_id)
  end
  #--------------------------------------------------------------------------
  # * Get Normal Attack State Change (+)
  #--------------------------------------------------------------------------
  def plus_state_set
    return self.en_state_add(@enemy_id)
  end
  #--------------------------------------------------------------------------
  # returns the battler hue during battle
  #--------------------------------------------------------------------------
  def character_hue
    return @battler_hue
  end
  #--------------------------------------------------------------------------
  # returns weapon range based on enemy_id 
  #--------------------------------------------------------------------------
  def weapon_range(test_lshape = GTBS::BOW_LSHAPE)
    range = GTBS.monster_range(@enemy_id)
    range[2] = false unless test_lshape
    return range
  end
  #--------------------------------------------------------------------------
  # returns move range based on enemy_id
  #--------------------------------------------------------------------------
  def base_move_range
    move = GTBS::enemy_move(@enemy_id)
        # If no move, ensure 0
    move = [0,move].max
    if GTBS::REQUIRED_TP_FOR_MOVE > 0
      move_can_make = self.tp/GTBS::REQUIRED_TP_FOR_MOVE
      return move_can_make if move > move_can_make
    end
    return move
  end
  #--------------------------------------------------------------------------
  # Return max attack skill range based on action_list
  #--------------------------------------------------------------------------
  def attack_skill_range
    actions = action_list
    skillrange = []
    min_range = []
    for act in actions
      if act.kind == 1
        skill = $data_skills[act.skill_id]
        if skill.for_opponent?
          rng = GTBS::skill_range(act.skill_id)
          skillrange.push(rng[0]+rng[1])
          min_range.push([rng[4] - rng[1], 0].max)
        end
      end
    end
    return [skillrange.max, min_range.min] # return [nil, nil if skillrange == []
  end
  #--------------------------------------------------------------------------
  # Return max help skill range based on action list
  #--------------------------------------------------------------------------
  def help_skill_range
    skillrange = []
    for act in action_list
      if act.kind == 1
        skill = $data_skills[act.skill_id]
        if !skill.for_opponent?
          rng = GTBS::skill_range(act.skill_id)
          skillrange.push(rng[0]+rng[1])
        end
      end
    end
    return skillrange.max         # return nil if skillrange == []
  end
  
  #--------------------------------------------------------------------------
  # Screen X - Returns battler position for battle
  #--------------------------------------------------------------------------
  def screen_x
    if $game_system.tbs_enabled
      return super
    else
      return @screen_x
    end
  end
  #--------------------------------------------------------------------------
  # Screen Y - Returns battler position for battle
  #--------------------------------------------------------------------------
  def screen_y
    if $game_system.tbs_enabled
      return super
    else
      return @screen_y
    end
  end

  #--------------------------------------------------------------------------
  # Return gtbs down_x based on enemy_id
  #--------------------------------------------------------------------------
  def down_x
    return GTBS.down_x(@enemy_id, "enemy")
  end
  #--------------------------------------------------------------------------
  # Return gtbs down_y based on enemy_id
  #--------------------------------------------------------------------------
  def down_y
    return GTBS.down_y(@enemy_id, "enemy")
  end
    
  #if GTBS::ATTACK_ALLIES
  #  #----------------------------------------------------------------
  #  # Get Enemies 
  #  #----------------------------------------------------------------
  #  def get_possible_targets(type = 'attack')
  #    if self.state?(GTBS::CONFUSE_ID) or type == 'help' #if confused
  #      targets = enemies
  #    else
  #      targets = opponents
  #    end
  #    return targets
  #  end
  #end
  
  #--------------------------------------------------------------------------
  # * Animated - Returns if the current character sheet selected is animated
  #-------------------------------------------------------------------------- 
  def gtbs_entrance(x, y)
    super
    @hidden = false
  end
  
  #------------------------------------------------------------
  # This is where it is determined if a range boost occurs due to info in 
  # CHEMIST_CLASS_ITEM Actor/Enemy.  Do not adjust this section or it may
  # produce errors
  #------------------------------------------------------------
  def item_range(item_id)
    range = GTBS.item_range(item_id)
     if GTBS::CHEMIST_CLASS_ITEM_ENEMY.keys.include?(@enemy_id)
      info = GTBS::CHEMIST_CLASS_ITEM_ENEMY[@enemy_id]
      if info.keys.include?(item_id)
        range[0] = range[0] + info[item_id]
      end
    end
    return range
  end
  #--------------------------------------------------------------------------
  # Unit_size - returns the size for the unit
  # this code looks funny, isn't it?
  # @unit_size store the value
  # it is calculated only if @unit_size == nil and the default value is 1
  #--------------------------------------------------------------------------
  def unit_size
    @unit_size ||= (GTBS::En_large_units[self.enemy_id] or 1)
  end    

  #------------------------------------------------------------ 
  #* is unit controlled by ai ?
  # allways true for enemy
  #------------------------------------------------------------ 
  def ai_controlled?
    return true 
  end
  #------------------------------------------------------------ 
  #* is unit summoned?
  #------------------------------------------------------------ 
  def is_summoned?
    GTBS::SUMMON_ENID.include?(self.enemy_id)
  end
  #------------------------------------------------------------------------
  # if defined return the death animation
  #-------------------------------------------------------------------------
  def death_animation_id
    return GTBS.get_death_anim_enemy(@enemy_id)
  end
  #--------------------------------------------------------------------------
  # * Animated - Returns if the current character sheet selected is animated
  #--------------------------------------------------------------------------
  def animated?
    result = @battler_name.include?(GTBS::DETERMINE_ANIM_KEY)
    if result && anim_mode == :CHARSET
      result = false;
    end
    return result
  end
  
  #----------------------------------------------------------------------------
  # Check Frame/Pose Overrides
  #----------------------------------------------------------------------------
  # Returns the number of frames and poses for the current battler
  #----------------------------------------------------------------------------
  def frame_hash
    GTBS::EXTRA_ENEMY_FRAMES[self.enemy_id]
  end
  def anim_stances
    stances = GTBS::EXTRA_ENEMY_STANCES[self.enemy_id]
    stances = GTBS::DEFAULT_POSE_STANCES if stances.nil? && anim_mode == :GTBS
    stances = GTBS::MINKOFF_HOLDER_POSE_STANCES if stances.nil? && anim_mode == :MINKOFF
    return stances
  end
  
  def pose_path
    GTBS::ENEMY_POSE_PATH[self.enemy_id]
  end
  def stance_sound_association
    GTBS::STANCE_SOUND_ASSOCIATION_ENEMY[self.enemy_id]
  end
  def pose_frame_override
    GTBS::POSE_FRAME_OVERRIDE_ENEMY[self.enemy_id]
  end
  def cust_skill_pose 
    GTBS::CUST_SKILL_POSE_ASSIGN_ENEMY[self.enemy_id]
  end
   def near_death_percent 
    GTBS::ENEMY_ND_PERC_OVERRIDE[self.enemy_id] or GTBS::DEFAULT_ND_PERCENTAGE
  end 
  def extra_attack_poses
    redefined = GTBS::EXTRA_ENEMY_ATTACK.keys.include?(self.enemy_id)
    if redefined
      return true, GTBS::EXTRA_ENEMY_ATTACK[self.enemy_id]
    else
      return false, nil
    end
  end

  #--------------------------------------------------------------------------
  # * Action List - Generates a list of available actions
  #--------------------------------------------------------------------------
  def action_list
    available_actions = []
    for action in enemy.actions
      next unless conditions_met?(action)
      if action.kind == 1
        next unless skill_can_use?($data_skills[action.skill_id])
      end
      available_actions.push(action) 
    end
  
    if available_actions.empty?
      act = Game_Action.new(self)
      available_actions << act
    end
    return available_actions
  end
  #--------------------------------------------------------------------------
  # * if defined, return the ai_tactic set for this enemy troop
  #   else return nil
  #--------------------------------------------------------------------------
  def ai_tactic
    return @temp_tactic || AI_Tactic[self.enemy_id]
  end
end

class Enemy_Class
  attr_reader :name
  def initialize(name)
    @name = name
  end
end
class Game_Enemy < Game_Battler
  def class
    return Enemy_Class.new(class_name)
  end
  #--------------------------------------------------------------------------
  # * Determine if Action Conditions are Met
  #     action : battle action
  #--------------------------------------------------------------------------
  def tbs_conditions_met?(action)
    return conditions_met?(action)
    #case action.condition_type
    #when 1  # Number of turns
    #  n = $game_troop.turn_count
    #  a = action.condition_param1
    #  b = action.condition_param2
    #  return false if (b == 0 and n != a)
    #  return false if (b > 0 and (n < 1 or n < a or n % b != a % b))
    #when 2  # HP
    #  hp_rate = hp * 100.0 / maxhp
    #  return false if hp_rate < action.condition_param1
    #  return false if hp_rate > action.condition_param2
    #when 3  # MP
    #  mp_rate = mp * 100.0 / maxmp
    #  return false if mp_rate < action.condition_param1
    #  return false if mp_rate > action.condition_param2
    #when 4  # State
    #  return false unless state?(action.condition_param1)
    #when 5  # Party level
    #  return false if $game_party.max_level < action.condition_param1
    #when 6  # Switch
    #  switch_id = action.condition_param1
    #  return false if $game_switches[switch_id] == false
    #end
    #return true
  end
  #--------------------------------------------------------------------------
  # Allow wander 
  #--------------------------------------------------------------------------
  def allow_wander
    if (GTBS::PREVENT_EN_WANDER.include?(self.enemy_id))
      return false
    else
      return true
    end
  end
end