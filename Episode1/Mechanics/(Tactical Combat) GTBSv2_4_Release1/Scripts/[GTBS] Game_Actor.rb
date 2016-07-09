#===============================================================================
# This Script is made specfically for usage with GTBS version 1.5.1.4 by GubiD.
#===============================================================================

#--------------------------------------------------------------------------
# Game Actor - Updates for GTBS
#--------------------------------------------------------------------------
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # Constants
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  # Performed Action
  #--------------------------------------------------------------------------
  def perf_action=(bool)
    if bool == false
      @skill_usage_turn = 0
    end
    super
  end
  #--------------------------------------------------------------------------
  # Skill Turn Usage
  # Updates the usage turn data.. and sets action performed to true if exceeded
  # max turn usage.
  #--------------------------------------------------------------------------
  def skill_turn_usage
    if @skill_usage_turn.nil?
      @skill_usage_turn = 0
    end
    return @skill_usage_turn
  end
  def skill_turn_usage=(val)
    if val >= GTBS::Max_Turn_Skill_Usage
      self.perf_action = true
    end
    @skill_usage_turn = val
  end
  def is_summoned?
    GTBS::ACTOR_SUMMONS.include?(@actor_id)
  end
  #--------------------------------------------------------------------------
  # Hide Info? - Used by Window_Status_TBS to determine if to hide hp/mp/at
  #--------------------------------------------------------------------------
  def hide_info?
    return false
  end
  #--------------------------------------------------------------------------
  # * Base Move Range - Returns the move range for the actor based on the class
  #--------------------------------------------------------------------------
  def base_move_range
    move = GTBS.move_range(@class_id)
    
    #read armors to determine extra/reduced move
    arms = armors
    for i in 0...arms.size
      arm = arms[i]
      arm = enhanced_armor_id(arm)
      move += GTBS.equip_move_info(arm.id)
    end
    
    #read weapons to determine extra/reduced move
    weps = weapons
    for i in 0...weps.size
      wep = weps[i]
      wep = enhanced_weapon_id(wep)
      move += GTBS.weapon_move_info(wep.id)
    end
    
    # Get State Modifiers
    for state_id in @states
      move +=  GTBS.state_move_info(state_id)
    end
    
    # If no move, ensure 0
    move = [0,move].max
    if GTBS::REQUIRED_TP_FOR_MOVE > 0
      move_can_make = self.tp/GTBS::REQUIRED_TP_FOR_MOVE
      return move_can_make if move > move_can_make
    end
    return move
  end
  #--------------------------------------------------------------------------
  # Adjust Range for Summon - Determines if skill is summon type and reduces field
  # range to 0
  #--------------------------------------------------------------------------
  def adjust_range_for_summon(range_data, skill_id)
    if range_data[1] > 0 and GTBS.is_summon?(skill_id, true) > 0
      range_data[1] = 0
    end
    return range_data
  end
  #--------------------------------------------------------------------------
  # State Skill Mod? - Returns the range data for skill modify by states
  #--------------------------------------------------------------------------
  def skill_range_mod?(range_data)
    #---------
    #range_data = [range_max, Field, LINE_SKILL?, exclude_caster?, range_min]
    #mod_data = [max_adj, min_adj, field_adj]
    #---------
    max   = range_data[0]
    min    = range_data[4]
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
    
    for arm in armors
      next if arm.nil?
      arm_id = enhanced_armor_id(arm.id)
      data = GTBS.equip_skill_range_modification(arm_id)
      max += data[0]
      min += data[1]
      field += data[2]
      v_range += data[3] # mod MGC
      v_range_aoe += data[4] # mod MGC
    end
    for wep in weapons
      wep_id = enhanced_weapon_id(wep.id)
      data = GTBS.equip_skill_range_modification(wep_id,1) 
      max += data[0]
      min += data[1]
      field += data[2]
      v_range += data[3] # mod MGC
      v_range_aoe += data[4] # mod MGC
    end
    
    #-------------------------
    # Ensure data is within valid ranges
    # Update Range Data
    #-------------------------
    range_data[0] = [0, max].max
    range_data[4] =  [0, [min, max].min].max
    range_data[1] =  [0, field].max
    range_data[5] =  v_range # mod MGC
    range_data[6] =  v_range_aoe # mod MGC
    return range_data
  end 
  #--------------------------------------------------------------------------
  # Determine weapon range based on id
  #--------------------------------------------------------------------------
  def weapon_range(test_lshape = GTBS::BOW_LSHAPE)
    weapon = weapons[0]
    if weapon.nil?
      weapon = 0
      range = GTBS.weapon_range(0)
      range[2] = false unless test_lshape
      return range
    end
    range = GTBS.weapon_range(weapon.id)
    range[2] = false unless test_lshape
    return range
  end
  #--------------------------------------------------------------------------
  # Return max attack skill range
  #--------------------------------------------------------------------------
  def attack_skill_range
    maxrange = []
    minrange = []
    for i in @skills
      skill = $data_skills[i]
      if skill.for_opponent?
        rng = GTBS::skill_range(i)
        maxrange.push(rng[0] + rng[1])
        minrange.push([rng[4] - rng[1], 0].max)
      end
    end
    return [maxrange.max, minrange.min] # [nil, nil] if getrange == []
  end
  #--------------------------------------------------------------------------
  # Return max help skill range
  #--------------------------------------------------------------------------
  def help_skill_range
    getrange = []
    for i in @skills
      skill = $data_skills[i]
      if !skill.for_opponent?
        rng = GTBS::skill_range(i)
        getrange.push(rng[0] + rng[1])
      end
    end
    return getrange.max  # nil if getrange = []
  end
  #--------------------------------------------------------------------------
  # Return down_x result from GTBS module for the actor id
  #--------------------------------------------------------------------------
  def down_x
    return GTBS.down_x(@id, "actor")
  end
  #--------------------------------------------------------------------------
  # Return down_y result from GTBS module for the actor id
  #--------------------------------------------------------------------------
  def down_y
    return GTBS.down_y(@id, "actor")
  end
  #--------------------------------------------------------------------------
  # Character Name - Used to produce the battler during gtbs battle
  #--------------------------------------------------------------------------
  
  def character_name
    if death_state? && $game_system.actors_bodies? && !animated?
      return @character_name + "_down" 
    else
      name = @character_name
      if in_gtbs_battle? 
        if SceneManager.scene.mini_showing
          name += GTBS::MINI_Battler_Suffix unless GTBS::Prevent_Actor_Mini.include?(self.id)
          name += kaduki_pose_suffix if anim_mode == :KADUKI#kaduki mini suffix add
        else
          name += kaduki_pose_suffix if anim_mode == :KADUKI#kaduki mini suffix add
        end
      end
      return name
    end
  end
  
  #-----------------------------------------------------------------
  #* will actor collapse?
  #----------------------------------------------------------------
  def will_collapse?
    if @neutral
      return true if !$game_system.neutrals_bodies?
    else
      return true if !$game_system.actors_bodies?
    end
    return true if self.is_summoned?
    return false
  end
  
  
  #--------------------------------------------------------------------------
  # Screen X - Returns battler position for battle
  #--------------------------------------------------------------------------
  alias gtbs_ga_screen_x screen_x
  def screen_x
    if $game_system.tbs_enabled
      super
    else
      return gtbs_ga_screen_x
    end
  end
  #--------------------------------------------------------------------------
  # Screen Y - Returns battler position for battle
  #--------------------------------------------------------------------------
  alias gtbs_ga_screen_y screen_y
  def screen_y
    if $game_system.tbs_enabled
      super
    else
      return gtbs_ga_screen_y
    end
  end
  alias gtbs_ga_screen_z screen_z
  def screen_z(*args)
    if $game_system.tbs_enabled
      super()
    else
      return gtbs_ga_screen_y(*args)
    end
  end
  
  #if !GTBS::ATTACK_ALLIES
    
    #----------------------------------------------------------------
    # Get Enemies 
    #----------------------------------------------------------------
    #def get_possible_targets(type = 'attack')
    #  if self.state?(GTBS::CONFUSE_ID) or type == 'help' #if confused or help skill
    #    targets = allies #BLARG
    #  else
    #    targets = opponents
    #  end
    #  return targets
    #end
  #end

  #--------------------------------------------------------------------------
  # * Animated - Returns if the current character sheet selected is animated
  #-------------------------------------------------------------------------- 
  def gtbs_entrance(x, y, neutral = false)
    super(x, y)
    if neutral
      @neutral = neutral
      $game_party.add_neutral(@actor_id)
      @originally_neutral = neutral
    end
    @hidden = false
  end
  #-------------------------------------------------------------------------- 
  # Recover After Battle?
  #-------------------------------------------------------------------------- 
  def recover_after_battle? 
    if 2 == GTBS::Recover_HPMP_After_Battle or
       (1 == GTBS::Recover_HPMP_After_Battle and @neutral)
      @hp = mhp
      @mp = mmp
    end
  end
  #-------------------------------------------------------------------------- 
  # Item Range - Returns the range in which you can 'throw' the item
  #-------------------------------------------------------------------------- 
  def item_range(item_id)
    range = GTBS.item_range(item_id)
    #------------------------------------------------------------
    # This is where it is determined if a range boost occurs due to info in 
    # CHEMIST_CLASS_ITEM Actor/Enemy.  Do not adjust this section or it may
    # produce errors
    #------------------------------------------------------------ 
    if GTBS::CHEMIST_CLASS_ITEM_ACTOR.keys.include?(actor.class_id)
      chemist_range = GTBS::CHEMIST_CLASS_ITEM_ACTOR[actor.class_id][item_id]
      if chemist_range
        range[0] += chemist_range
      end
    end
    return range
  end
  #--------------------------------------------------------------------------
  # Unit_size - returns the size for the unit
  #--------------------------------------------------------------------------
  def unit_size
     @unit_size ||=  (GTBS::Act_large_units[self.id] or 1)
  end
  def confused?
    state?(GTBS::CONFUSE_ID)
  end
  #------------------------------------------------------------ 
  #* is unit controlled by ai ?
  #------------------------------------------------------------ 
  def ai_controlled?
    return true if @neutral || confused? or 
    (self.team != "actor" && GTBS::Allow_User_Control_For_All_Teams == false)
    return false
  end
  
  #------------------------------------------------------------ 
  #* using_enhanced_weapons
  #------------------------------------------------------------ 
  #if GTBS::USING_ENHANCED_WEAPONS 
  #  #enhanced weapons
  #  def enhanced_weapon_id(wep_id = @weapon_id)
  #    if $data_weapons[wep_id].is_a?(Enhanced_Weapon)
  #      return $data_weapons[wep_id].ref_id
  #    else
  #      return wep_id
  #    end
  #  end
  #  #enhanced armors
  #  def enhanced_armor_id(arm_id)
  #    if $data_weapons[wep_id].is_a?(Enhanced_Weapon)
  #      return $data_armors[arm].ref_id
  #    else
  #      return arm_id
  #    end
  #  end
  #  
  #else# not using_enhanced_weapons
  
  #Leaving that code there and here so that if/when that script comes around again
  # it will be easier to implement it back in. 
    def enhanced_weapon_id(wep_id = weapons[0].id)
      return wep_id
    end
    def enhanced_armor_id(arm_id)
      return arm_id
    end
  #end
  #------------------------------------------------------------------------
  # if defined return the death animation
  #-------------------------------------------------------------------------
  def death_animation_id
    return GTBS.get_death_anim_actor(@actor_id)
  end
  #--------------------------------------------------------------------------
  # * Animated - Returns if the current character sheet selected is animated
  #--------------------------------------------------------------------------
  def animated?
    result = @character_name.include?(GTBS::DETERMINE_ANIM_KEY)
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
    return GTBS::EXTRA_ACTOR_FRAMES[self.id]
  end
  def anim_stances
    stances = GTBS::EXTRA_ACTOR_STANCES[self.id]
    stances = GTBS::DEFAULT_POSE_STANCES if stances.nil? && anim_mode == :GTBS
    stances = GTBS::MINKOFF_HOLDER_POSE_STANCES if stances.nil? && anim_mode == :MINKOFF
    return stances
  end
  def pose_path
    GTBS::ACTOR_POSE_PATH[self.id]
  end
  def stance_sound_association
    GTBS::STANCE_SOUND_ASSOCIATION_ACTOR[self.id]
  end
  def pose_frame_override
   GTBS::POSE_FRAME_OVERRIDE_ACTOR[self.id]
  end
  def cust_skill_pose 
    GTBS::CUST_SKILL_POSE_ASSIGN_ACTOR[self.id]
  end
  def near_death_percent 
    GTBS::ACTOR_ND_PERC_OVERRIDE[self.id] or GTBS::DEFAULT_ND_PERCENTAGE
  end
  def extra_attack_poses
    redefined = GTBS::EXTRA_ACTOR_ATTACK.keys.include?(self.id)
    if redefined
      return true, GTBS::EXTRA_ACTOR_ATTACK[self.id]
    else
      return false, nil
    end
  end
  #--------------------------------------------------------------------------
  # * Action List - Generates a list of available actions
  #--------------------------------------------------------------------------
  def action_list
    return [] if !self.movable?
    available_actions = []
    attack = RPG::Enemy::Action.new
    available_actions.push(attack)
    for skill in 0...skills.size
      next if skill == nil
      next if !skill_can_use?(skill)
      s = RPG::Enemy::Action.new
      s.kind = 1
      s.skill_id = skill.id
      available_actions.push(s)
    end
    return available_actions
  end
  #----------------------------------------------------------------------------
  #* calculate exp gained from targets array
  #---------------------------------------------------------------------------
  def calculate_exp(targets)
    exp = 0
    if GTBS::EXP_PER_HIT
      for target in targets
        pre_exp = 0
        amount = target.level - self.level
        if amount <= -10
          pre_exp += 1
        else
          pre_exp += 10 + amount
        end
        if target.death_state?
          pre_exp *= 2
        end
        exp += pre_exp
      end
    else
      for target in targets.uniq
        if target.enemy? && target.death_state?
          exp += target.exp 
        end
      end
    end
    return exp
  end
  #-------------------------------------------------------------------------
  #* Start Turn
  #-------------------------------------------------------------------------
  def start_turn
    super
    do_auto_recovery
  end
  
  #--------------------------------------------------------------------------
  # * Get Index
  #--------------------------------------------------------------------------   
  def index
    return $game_party.all_members.index(self)
  end
  #--------------------------------------------------------------------------
  # * AI Tactics - Return tactic code for actor
  #--------------------------------------------------------------------------
  def ai_tactic
    return @temp_tactic || GTBS::Actor_AI[@actor_id]
  end
  #--------------------------------------------------------------------------
  # * Perform Automatic Recovery (called at end of turn)
  #--------------------------------------------------------------------------
  def do_auto_recovery
    #if auto_hp_recover and not dead?
    #  self.hp += maxhp / 20
    #end
  end
  #--------------------------------------------------------------------------
  # * Determine if Action Conditions are Met
  #     action : battle action
  #--------------------------------------------------------------------------
  def tbs_conditions_met?(action)
    return true
  end
  #--------------------------------------------------------------------------
  # Allow wander 
  #--------------------------------------------------------------------------
  def allow_wander
    if (GTBS::PREVENT_ACT_WANDER.include?(@actor_id))
      return false
    else
      return true
    end
  end
end


