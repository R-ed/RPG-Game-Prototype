
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#
# GTBS Game Battler edits - Part 1 (New/revised variables/methods)
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#
class Game_Battler < Game_BattlerBase
  
  alias gtbs_battler_initialize initialize
  alias item_user_effect_gtbs item_user_effect
  alias add_state_gtbs add_state
  alias rem_state_gtbs_charm remove_state
  
  #--------------------------------------------------------------------------
  # Constants
  #--------------------------------------------------------------------------  
  TILESIZE = 256
  POSE_HASH = GTBS::DEFAULT_POSE_NUMBERS
  POSE_HASH_MINKOFF = GTBS::MINKOFF_HOLDER_POSE_NUMBERS
  
  HEAL_SCOPES   = [7,8,11]
  #-----------------------------------------------------------------------------
  # * GTBS new stuff
  #-----------------------------------------------------------------------------
  attr_accessor :atb                      # Current ATB
  attr_reader   :pattern                  # GTBS pattern reader
  attr_accessor :moved                    # Moved flag
  attr_accessor :neutral                  # GTBS Neutral Flag
  attr_accessor :perf_action              # GTBS Performed Action flag
  attr_reader   :run_route                # GTBS Route Control for battler
  attr_accessor :skill_cast               # GTBS Skill Casting container
  attr_accessor :collapsed                # GTBS collapsed flag
  attr_reader   :pose                     # GTBS Animated Battler Pose reader
  attr_accessor :pause                    # Used to Pause battle during true(usually for event)
  attr_reader   :skillcasting             # TIME remaining to cast skill
  attr_reader   :timer                    # Pose Timer
  attr_accessor :doom_counter             # GTBS Doom Counter
  attr_accessor :targeted                 # Targeted array
  attr_accessor :damage
  attr_accessor :damage_pop
  attr_accessor :move_route
  attr_accessor :move_actions           #Action Queue - Will be nil when no actions
  attr_accessor :weapon_actions
  attr_accessor :cost_for_move
  attr_accessor :temp_team              #Team in which this actor resides on. 
  attr_accessor :tbs_battler            #Work-around variable for 'available members'
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(*args)
    gtbs_battler_initialize(*args)
    #--------------------------------------------------------------------------
    # * GTBS Extra info
    #--------------------------------------------------------------------------
    @neutral = false                              #GTBS - Neutral Flag
    @atb = 0                                      #GTBS - Current ATB rating during battle, used to determine when each turn occurs
    @skillcasting = 0                             #GTBS - Remaining casting time for Skill_cast
    @skill_cast = nil                             #GTBS - Current Skill that is being cast
    @tactic = 1                                   #GTBS - Decide best tactic for attack (Aggressive, Passive, Defensive)
    @moved = false              
    @perf_action = false
    @collapsed = false
    @pause = false                                #GTBS - State assigned during event processing
    @attacker_dir = -1                            #GTBS - Used to rotate images
    
    @run_route = []                               #GTBS - Used to store GTBS route calculations
    @offset = 0                             # Dodge offset
    @dodge_count = 0                        # Dodge Counter
    @tbs_battler = false                    # Used to identify the battler is in battle
    @originally_neutral = false             # Identifies the battler as being called to battle as neutral
    #--------------------------------------------------------------------------
    # * GTBS Animation variables
    #--------------------------------------------------------------------------
    @pose = 0
    @timer = 0
    @move_actions = []   
    #@weapon_actions = [] 
    #--------------------------------------------------------------------------
  end
  #--------------------------------------------------------------------------
  # Init Team
  #--------------------------------------------------------------------------
  def init_team
    @team = "actor"
    self.temp_team = nil
  end
  #--------------------------------------------------------------------------
  # Returns the TEAM in which the player currently resides
  #--------------------------------------------------------------------------
  def team
    return self.temp_team if self.temp_team != nil
    return @team
  end
  #--------------------------------------------------------------------------
  # * Team=
  #--------------------------------------------------------------------------
  def set_team(value)
    @temp_team = nil
    @team = value
  end
  
  #--------------------------------------------------------------------------
  # Determines if current scene is gtbs battle
  #--------------------------------------------------------------------------
  def in_gtbs_battle?
    SceneManager.scene_is?(Scene_Battle_TBS)
  end
  
  #--------------------------------------------------------------------------
  # Animated Battler Type
  #--------------------------------------------------------------------------
  # Returns :GTBS, :MINKOFF or :KADUKI
  #--------------------------------------------------------------------------
  def anim_mode
    if SceneManager.scene.mini_showing
      return GTBS::ACTOR_Animation_Mode_MINI[self.id] || GTBS::DEFAULT_ANIMATION_METHOD if actor?
      return GTBS::ENEMY_Animation_Mode_MINI[self.enemy_id] || GTBS::DEFAULT_ANIMATION_METHOD
    end
    return GTBS::ACTOR_Animation_Mode[self.id] || GTBS::DEFAULT_ANIMATION_METHOD if actor?
    return GTBS::ENEMY_Animation_Mode[self.enemy_id] || GTBS::DEFAULT_ANIMATION_METHOD
  end
  
  
  
  #--------------------------------------------------------------------------
  # Animated Battler Type = 
  #--------------------------------------------------------------------------
  # Valid values
  #   "GTBS"
  #   "MINKOFF"
  #   "HOLDER"
  #   "KADUKI"
  #--------------------------------------------------------------------------
  # If supplied an invalid value, it will be ignored. 
  #--------------------------------------------------------------------------
  def anim_mode=(value)
    return if !value.is_a?(String)
    result = nil
    case value.to_upper
    when 'GTBS'
      reuslt = :GTBS
    when 'MINKOFF', 'HOLDER'
      result = :MINKOFF
    when 'KADUKI'
      result = :KADUKI
    end
    if reuslt != nil
      #Update the module value
      if actor?
        GTBS::ACTOR_Animation_Mode[self.id] = result 
      else
        GTBS::ENEMY_Animation_Mode[self.id] = result 
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Pos - Returns x,y of current position as array
  #--------------------------------------------------------------------------
  def pos
    return [@x, @y]
  end
  #--------------------------------------------------------------------------
  # View Range
  #--------------------------------------------------------------------------
  def view_range
    if !actor?
      range = GTBS.get_view_range(@enemy_id) 
    else
      range = GTBS.get_view_range(@class_id, true)
    end
    range += state_view_mod
    return range;
  end
  #--------------------------------------------------------------------------
  # State
  #--------------------------------------------------------------------------
  def state_view_mod
    range = 0
    # Get State Modifiers
    for state_id in @states
      val = GTBS::STATE_VIEW_INFO[state_id]
      if val != nil
        range += val
      end
    end
    return range
  end
  #--------------------------------------------------------------------------
  # * Positions - Returns an array of all currently occupied tiles
  #--------------------------------------------------------------------------
  def positions(x=@x,y=@y) 
    return [[x,y]]  if unit_size == 1
    tiles = [] 
    for ox in x...(x+unit_size)
      for oy in y...(y+unit_size)
        tiles.push([ox,oy])
      end
    end
    return tiles
  end
  #--------------------------------------------------------------------------
  # * At XY (used for large units especially)
  #-------------------------------------------------------------------------- 
  def at_xy_coord(x,y)
    return (@x == x and @y == y) if unit_size == 1
    size = unit_size - 1
    return( x.between?(@x, @x + size) and y.between?(@y, @y + size))
  end
  
  #--------------------------------------------------------------------------
  # * Animated - Returns if the current character sheet selected is animated
  #-------------------------------------------------------------------------- 
  def battle_entrance(neutral = false)
    @damage = nil
    @damage_pop = false
    adjust_special_states
    @step_anime = GTBS::STOPPED_ANIM
    current_action.clear
    @perf_action = false
    @moved = false
  end
  
  #--------------------------------------------------------------------------
  # * check for death animation
  #----------------------------------------------------------------------------
  def death_animation?
    death_anim_id = self.death_animation_id
    if death_anim_id
      @animation_id = death_anim_id 
      return true
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Collapse
  #--------------------------------------------------------------------------
  def collapse
    return @collapse  
  end
  #--------------------------------------------------------------------------
  # * Iso? - returns if the Game_Map is Isometric
  #--------------------------------------------------------------------------
  def iso?
    return $game_map.iso?
  end
  #--------------------------------------------------------------------------
  # * Counter Result - Used to determine if char can COUNTER the attack
  #--------------------------------------------------------------------------
  def counter?(attacker, preview = false)
    #--------------------------------------------------------------------------
    # Return false if not counter state, self == attacker, or self is a actor and attacker is actor..etc
    #--------------------------------------------------------------------------
    if self == attacker || self.death_state?
      return nil 
    end
  
    # if not team counter allowed and not opponent
    if !GTBS::COUNTER_TEAM && attacker.friends.include?(self)
      return  nil
    end
    
    for state in states
      if !GTBS::COUNTER_WHEN_CHARMED && state.id == GTBS::CHARM_ID
        return nil 
      end
      if !GTBS::COUNTER_WHEN_KNOCKED_BACK && 
        GTBS::KNOCK_BACK_STATES.include?(state.id) 
        #Counter not valid when bein knocked back && that type of counter is not allowed
        return nil 
      end
    end
  
    max, min = self.weapon_range[0, 2]
    atk_pos = self.calc_pos_attack(max, min, [self.pos])
    
    #--------------------------------------------------------------------------
    # Return false you can't attack enemy positions
    #--------------------------------------------------------------------------
    atk_positions = preview ? attacker.positions(*preview) : attacker.positions
    return nil if (atk_pos & atk_positions).empty?
    return self if GTBS::COUNTER_ALL

    #--------------------------------------------------------------------------
    # Set default percentage
    #--------------------------------------------------------------------------
    return cnt if preview
    
    #--------------------------------------------------------------------------
    #Figure counter based on %
    #--------------------------------------------------------------------------
    if rand(100) < cnt  #if rand less than %, counter = true
      return  self
    else                 #failed to counter
      return  nil
    end  
  end

  #--------------------------------------------------------------------------
  # * Check if battler is paused by event
  #--------------------------------------------------------------------------
  def paused?
    return @pause
  end
  #--------------------------------------------------------------------------
  # * Dodging?
  #--------------------------------------------------------------------------
  def dodging?
    return (@dodge_count > 0)
  end
  #--------------------------------------------------------------------------
  # * Dodge - Creates offset so that graphic is adjusted for a "dodge" motion
  #--------------------------------------------------------------------------
  def dodge
    @offset = 0
    @dodge_count = 30
  end 
  #--------------------------------------------------------------------------
  # * Checks states for Doom
  #--------------------------------------------------------------------------
  def has_doom?
    for i in @states
      if $data_states[i].is_doom_state?
        if self.doom_counter != nil
          self.doom_counter -= 1
          if self.doom_counter < 0
            self.doom_counter = nil
            self.hp -= self.hp
            self.result.set_doom_text
            perform_death
            return
          end
          self.result.set_doom_text(self.doom_counter)
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Sets actors current pose based on id
  #--------------------------------------------------------------------------
  def set_pose(type)
    #if self.moving?
    #  return 6 unless self.dead?
    #end
    case type
    when Numeric
      @pose = type
    else
      @pose = get_pose_number_from_name(type)
    end
    #when /^(wait|idle)/i 
    #  @pose = POSE_HASH["Wait"][0]-1
    #when /^(walk|advance|retreat|escape)/i
    #  @pose = POSE_HASH["Walk"][0]-1
    #when /^(attack)/i
    #  redefined, extra_poses = self.extra_attack_poses
    #  if redefined
    #    result = extra_poses
    #    if result != nil
    #      possible = result + POSE_HASH["Attack"]
    #    else
    #      possible = POSE_HASH["Attack"]
    #    end
    #  else
    #    possible = [POSE_HASH["Attack"][0]]
    #  end
    #  set = possible[rand(possible.size)]
    #  @pose = set-1
    #when /^(special|skill)/i
    #  @pose = POSE_HASH["Special"][0]-1
    #when /^(defend|guard|evade)/i
    #  @pose = POSE_HASH["Defend"][0]-1
    #when /^(pain|hurt)/i
    #  @pose = POSE_HASH["Pain"][0]-1
    #when /^(heal|use|item)/i     
    #  @pose = POSE_HASH["Heal"][0]-1
    #when /^(casting|magiccast)/i
    #  @pose = POSE_HASH["Cast Charge"][0]-1
    #when /^(cast|magic)/i    
    #  @pose = POSE_HASH["Cast"][0]-1
    #when /^(near(?:_| )death|danger)/i
    #  @pose = POSE_HASH["Near Death"][0]-1
    #  raise Exception.new
    #when /^(collapse|dead)/i
    #  @pose = POSE_HASH["Dead"][0]-1
    #else; set_pose("wait")
    #end
  end
  def get_pose_number_from_name(name)
    #clone the hash so that it doesnt change the actual object as it is inspected.
    case anim_mode
    when :GTBS
      hash = POSE_HASH.clone
    when :MINKOFF
      hash = POSE_HASH_MINKOFF.clone
    when :KADUKI
      msgbox "Kaduki not implemented yet"
      hash = {}
    when :CHARSET
      hash = {} #No need to set animated values as this is not an animated option
    end
    for key in hash.keys
      if (key.casecmp(name) == 0) #performs case insensitive comparison
        pose_array = hash[key]
        if !pose_array.nil?
          result = pose_array[0]
          if key =~ /attack/i
            redefined, extra_poses = extra_attack_poses
            if redefined
              result += extra_poses
            end
          end
          if pose_array.size > 1
            result = pose_array[rand(pose_array.size)]
          end
        end
      end
    end
    
    if result != nil
      return result-1
    else
      result = @pose #no match, return current pose
    end
  end
  #--------------------------------------------------------------------------
  # Kaduki Pose Suffix 
  #--------------------------------------------------------------------------
  # Used to return the suffix that should be utilized for the current 'pose'
  # when the battler animated type is Kaduki.
  #--------------------------------------------------------------------------
  def kaduki_pose_suffix
    #This method needs to be extended. 
    return ""
  end
  #--------------------------------------------------------------------------
  # * Resets animation frame to start
  #--------------------------------------------------------------------------
  def reset_frame
    @pattern = 0
  end
  #--------------------------------------------------------------------------
  # * Checks current pose
  #--------------------------------------------------------------------------
  def pose?
    return @pose
  end
  alias upd_gm_bat_run_route update
  def update
    upd_gm_bat_run_route
    if @move_route and @move_route.size > 0
      run_path unless moving?
    end
    update_dodge
    update_floating
  end
  #--------------------------------------------------------------------------
  # * Update While Stopped
  #--------------------------------------------------------------------------
  alias upd_stop_gm_bat_2 update_stop
  def update_stop
    if animated?
      @timer -= 1 if @timer > 0 
      if @step_anime
        @anime_count += 2
      elsif @pattern != @original_pattern
        @anime_count += 2.5
      end
    else
      upd_stop_gm_bat_2
    end
    #update animation speeds depending on state of hast/slow
    if is_slow? 
      if @step_anime
        @anime_count -= 0.5
      else
        @anime_count -= 0.75
      end
    elsif is_haste?
      if @step_anime
        @anime_count += 1
      else
        @anime_count += 1.5
      end
    end
    #@stop_count += 1 unless @locked #this was moved to another method
  end
  #--------------------------------------------------------------------------
  # Is Slow
  #--------------------------------------------------------------------------
  def is_slow?
    state?(GTBS::SLOW_ID) #slow
  end
  #--------------------------------------------------------------------------
  # Is Haste
  #--------------------------------------------------------------------------
  def is_haste?
    state?(GTBS::HASTE_ID) #haste
  end
  #--------------------------------------------------------------------------
  # * Knock Back - performs "knock back"
  #--------------------------------------------------------------------------
  def knock_back(direction)
    case direction
    when 2 ; @y += 1
    when 4 ; @x -= 1
    when 6 ; @x += 1
    when 8 ; @y -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * Prepare wait skill
  #--------------------------------------------------------------------------
  def setup_skill
    @skillcasting = GTBS::skill_wait(@skill_cast[0].id)[0]
  end
  #--------------------------------------------------------------------------
  # * In the act of Casting?
  #--------------------------------------------------------------------------
  def casting?
    return true if @skillcasting > 0
    return false
  end
  #--------------------------------------------------------------------------
  # * Returns what you are "Casting"
  #--------------------------------------------------------------------------
  def cast
    return @skill_cast
  end
  #--------------------------------------------------------------------------
  # * Updates current casting time, or resets it
  #--------------------------------------------------------------------------
  def up_cast(reset = false)
    if reset == false
      #TODO: Is Magical Attack rate good enough to determine casting rate?
      @skillcasting -= self.mat 
    else
      @skillcasting = 0
    end
  end 
  #--------------------------------------------------------------------------
  # * update state if Casting? or not
  #--------------------------------------------------------------------------
  def check_casting
    args = GTBS::CASTING_ID
    if casting? and !muted?
      add_state(*args)
    else
      remove_state(*args)
    end
  end
  #--------------------------------------------------------------------------
  # * Returns if actor has moved completely or not
  #--------------------------------------------------------------------------
  def moved?
    if GTBS::MOVE_VARIABLE
      if remain_move[0] != $game_temp.battle_turn
        reset_move
      end
      return false if state?(GTBS::DONT_MOVE_ID)
      if @remain_move[1] > 0
        return false
      else
        return true
      end
    else
      #return true if casting?
      return @moved
    end
  end
  #--------------------------------------------------------------------------
  # * Used with variable move - not fully implemented yet.
  #--------------------------------------------------------------------------
  def reset_move
    if remain_move[0] != $game_temp.battle_turn
      remain_move[0] = $game_temp.battle_turn
      move = base_move_range
      for s_id in @states
        case s_id
        when 11 #delay (slow)
          move -= 2
        end
      end
      remain_move[1] = move
    end
  end
  #--------------------------------------------------------------------------
  # * Returns true if you have ACTED
  #--------------------------------------------------------------------------
  def perfaction?
    return @perf_action
  end
  #-------------------------------------------------------------
  #* set moved flag as true automaticaly when action is performed
  #----------------------------------------------------------------------------------
  def perf_action=(bool)
    @perf_action = bool
    if bool == true and GTBS::FORCE_MOVE_THEN_ACT
      @moved = true
    end
  end
  #--------------------------------------------------------------------------
  # Return ATB
  #--------------------------------------------------------------------------
  def atb
    return @atb
  end
  #--------------------------------------------------------------------------
  # Update ATB using AGI for the actor
  #--------------------------------------------------------------------------
  def atb_update
    @atb += 1 #promptness.to_i
  end
  #--------------------------------------------------------------------------
  # Update ATB using AGI for the actor
  #--------------------------------------------------------------------------
  def promptness
    return self.agi * (casting? ? GTBS.skill_wait(@skill_cast[0].id)[1] / 100.0 : 1.0)
  end
  def recuperation_time
    return (4096 / promptness).to_i
  end
  #--------------------------------------------------------------------------
  # * Resets ATB
  #--------------------------------------------------------------------------
  def reset_atb
    @atb = 0
    return @atb
  end
  #--------------------------------------------------------------------------
  # Initialize atb
  #--------------------------------------------------------------------------
  def setup_atb(atb = nil)
    @atb =(recuperation_time * atb / 100)
  end
  #--------------------------------------------------------------------------
  # * Determine if Passable - original passable, with edits
  #     d : Direction (2,4,6,8)
  #--------------------------------------------------------------------------
  def passable?(x, y, d, adtnlParam=false)
    x2 = $game_map.round_x_with_direction(x, d)
    y2 = $game_map.round_y_with_direction(y, d)
    
    return false  unless $game_map.valid?(x2, y2)
    return false  if !move_climbable?(x2, y2, x, y, d, adtnlParam)
    return true   if @through || debug_through? 
    return false  if collide_with_battlers?(x2,y2)
    return true   if can_fly_over?(x2, y2) #Fly Tech
    return true   if can_walk_over?(x2,y2) #Walk on Water Tech
    return false  unless map_passable?(x, y, d)
    return false  unless map_passable?(x2, y2, reverse_dir(d))
    return (additional_pass_check(x,y,d,adtnlParam) || true)
  end
  #--------------------------------------------------------------------------
  # Additional Pass Check - This is an additional pass check for advanced move
  # function scripts.
  #--------------------------------------------------------------------------
  def additional_pass_check(x,y,d,adtnlParam)
    return nil
  end
  #--------------------------------------------------------------------------
  # * Determine if Passable
  #     x : x-coordinate
  #     y : y-coordinate
  #     d : direction (0,2,4,6,8)
  #         * 0 = Determines if all directions are impassable (for jumping)
  #--------------------------------------------------------------------------
  alias passable_gm_bat_large_unit passable?
  def passable?(x, y, d, adtnlParam=false)
    #--------------------------------------------------------------------------
    # Large Unit Passable? Update
    #--------------------------------------------------------------------------
    for ux, uy in self.positions(x, y)
      result = passable_gm_bat_large_unit(ux, uy, d, adtnlParam) #check passable for each 'moving' position
      return result if result == false
    end
    return true
  end
  
  #--------------------------------------------------------------------------
  # Can Fly Over? - Returns true if flying and tile is movable for that type of movement. 
  #--------------------------------------------------------------------------
  def can_fly_over?(x, y)
    return flying_unit
  end

  #--------------------------------------------------------------------------
  # Can Walk Over? - Returns true if WWater State and tile is water
  # If character can "walk on water" and tile is water, return true
  #-------------------------------------------------------------------------- 
  def can_walk_over?(x,y)
    return (walk_on_water? and $game_map.boat_passable?(x,y))
  end
  
  #--------------------------------------------------------------------------
  # Move Climbable? - Stub for advanced movement techniques
  #--------------------------------------------------------------------------
  def move_climbable?(nu_x, nu_y, last_x=@x, last_y=@y, dir=@direction, adt_param=false)
    return true 
  end
  
  #-------------------------------------------------------------
  # Can Occupy - Used for large units
  #  Actor : Game_Battler
  #  Pos   : [x,y]
  #-------------------------------------------------------------
  def can_occupy?(pos) 
    for ps in self.positions(pos[0],pos[1])
      occ = $game_map.occupied_by?(ps[0],ps[1])
      if occ and occ != self 
        return false
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Determine Character Collision
  #     x : x-coordinate
  #     y : y-coordinate
  #    Detects normal character collision, including the player and vehicles.
  #--------------------------------------------------------------------------
  if GTBS::TEAM_THROUGH
    def collide_with_battlers?(x, y)
      for event in $game_system.tactical_events               # Matches event position
        next if event == self # Skip self
        if event.at_xy_coord(x,y)
          unless event.through or event.character_name == ""  # Passage OFF? 
            return true if event.is_a?(Game_Event)
            return false if self.team == event.team
            if event.is_a?(Game_Battler)
              if (event.is_a?(Game_Enemy))
                return (GTBS::REMOVE_DEAD > 0 && event.death_state?) ? false : true
              elsif (event.is_a?(Game_Actor))
                return (GTBS::REMOVE_DEAD > 1 && event.death_state?) ? false : true
              end
            end
            return true unless event.death_state? && GTBS::REMOVE_DEAD == 2
          end      
        end
      end
      return false
    end
  else
    def collide_with_battlers?(x, y)
      for event in $game_system.tactical_events               # Matches event position
        next if event == self # Skip self
        if event.at_xy_coord(x,y)
          unless event.through or event.character_name == ""  # Passage OFF?
          return true if event.is_a?(Game_Event)
            if event.is_a?(Game_Battler)
              if (event.is_a?(Game_Enemy))
                return (GTBS::REMOVE_DEAD > 0 && event.death_state?) ? false : true
              elsif (event.is_a?(Game_Actor))
                return (GTBS::REMOVE_DEAD > 1 && event.death_state?) ? false : true
              end
            end
          end      
        end
      end
      return false
    end
  end

  #--------------------------------------------------------------------------
  # Run Route - Used to receive a route from the battle system
  #--------------------------------------------------------------------------
  def run_route(route)
    self.set_pose("Walk") 
    @move_route = route
  end
  #--------------------------------------------------------------------------
  # * Turn to (who?)
  #--------------------------------------------------------------------------
  def turn_to(who, ty = nil)
    return if !who
    if ty.nil?
      sx = @x - who.x
      sy = @y - who.y
    else
      sx = @x - who
      sy = @y - ty
    end
    return 0 if sx == 0 and sy == 0
    if sx.abs > sy.abs
      sx > 0 ? @direction = 4 : @direction = 6
      return sx.abs
    else
      sy > 0 ? @direction = 8 : @direction = 2
      return sy.abs
    end
  end
  #--------------------------------------------------------------------------
  # * Class Name - returns the class name of the character
  #--------------------------------------------------------------------------
  def class_name
    return $data_classes[@class_id].name
  end
  #--------------------------------------------------------------------------
  # Adjust the X placement by dodge offset
  #--------------------------------------------------------------------------
  def apply_x_dodge_offset(val)
    val += (@direction == 8 ? @offset : @direction == 6 ? -(@offset) : 0)
    return val
  end
  #--------------------------------------------------------------------------
  # Adjust the Y placement by dodge offset
  #--------------------------------------------------------------------------
  def apply_y_dodge_offset(val)
    val += (@direction == 6 ? @offset: @direction == 4 ? -(@offset) : 0)
    return val
  end
  #--------------------------------------------------------------------------
  # Reset Floating
  #--------------------------------------------------------------------------
  def reset_float
    @floating_dir = nil
    @float_offset = nil
  end
  #--------------------------------------------------------------------------
  # Floating - Returns if the actor is floating/flying
  #--------------------------------------------------------------------------
  def floating? 
    return (@float_offset != nil)
  end
  #--------------------------------------------------------------------------
  # Float Count - Returns the current float count
  #--------------------------------------------------------------------------
  def float_count
    return @float_offset
  end
  #--------------------------------------------------------------------------
  # Flying unit - determines if this unit is currently in flight or not.
  #--------------------------------------------------------------------------
  def flying_unit
    if actor?
      #check weapons for flight flag
      for wep in weapons
        if (GTBS::WeaponCausesFlight.include?(wep.id))
          return true
        end
      end
      #check armors for flight flag
      for arm in armors
        if (GTBS::EquipCausesFlight.include?(arm.id))  
          return true
        end
      end
    else #enemies
      if (GTBS::EnemiesWhoFly.include?(self.enemy_id))
        return true
      end
    end
    #check states for flight flag
    for state in @states
      if (GTBS::StateCausesFlight.include?(state))
        return true
      end
    end
    return false
  end
  def walk_on_water?
    if actor?
      #check weapons for flight flag
      for wep in weapons
        if (GTBS::WalkOnWater_Weapons.include?(wep.id))
          return true
        end
      end
      #check armors for flight flag
      for arm in armors
        if (GTBS::WalkOnWater_Armors.include?(arm.id))
          return true
        end
      end
    else #enemies
      if (GTBS::EnemiesWithWalkOnWater.include?(self.enemy_id))
        return true
      end
    end
    #check states for flight flag
    for state in @states
      if (GTBS::WalkOnWater_States.include?(state))
        return true
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # Update Floating
  #--------------------------------------------------------------------------
  def update_floating
    return unless flying_unit
    if @floating_dir.nil?
      @floating_dir = 1
      @float_offset = 0
    end
    if (Graphics.frame_count % 5) == 0
      if @floating_dir == 0
        @float_offset -= 1
        if @float_offset == 2
          @floating_dir = 1
        end
      else
        @float_offset += 1
        if @float_offset == 6
          @floating_dir = 0
        end
      end
    end
  end

  #--------------------------------------------------------------------------
  # Update Dodge - Updates offset for dodge
  #--------------------------------------------------------------------------
  def update_dodge
    case @dodge_count
    when 5..13
      @offset -= 1
    when 17..25
      @offset += 1
    end
    @dodge_count -= 1
  end
  #--------------------------------------------------------------------------
  # Run Path - Used to process the determined path
  #--------------------------------------------------------------------------
  def run_path
    if @move_route.size > 0
      action = @move_route.shift
      instance_eval("move_straight(#{action})")
    end
  end
  #--------------------------------------------------------------------------
  # * Update While Moving
  #--------------------------------------------------------------------------
  alias upd_bat_move update_move
  def update_move
    upd_bat_move
    if @walk_anime
      @anime_count += 3.0
    elsif @step_anime
      @anime_count += 2.0
    end
    if animated?
      set_pose("Walk") unless @pose == POSE_HASH["Pain"][0]-1
    end
    
  end
  #--------------------------------------------------------------------------
  # * Determine Usable Skills
  #     skill : skill
  #--------------------------------------------------------------------------
  def skill_can_use?(skill)
    result = usable?(skill)
    if result
      if tbs_skill_can_use(skill) == false
        return false
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # TBS Skill Can Use - Additional checks for summons and dead units
  #--------------------------------------------------------------------------
  def  tbs_skill_can_use(skill)
    return true if !$scene.is_a?(Scene_Battle_TBS)
    #test if can't use in TBS
    sum = GTBS::is_summon?(skill.id, self.is_a?(Game_Actor))
    if sum > 0
      name = $game_actors[sum].name.to_s
      max_amount = GTBS.get_summon_instance_count(sum)
      max_amount = 1 if GTBS::SUMMON_GAIN_EXP
      is = 0
      for bat in $game_party.existing_members + $game_troop.existing_members + $game_party.neutrals
        if bat.name.to_s == name
          is += 1
        end
      end
      return false if is >= max_amount
    end
    if skill.for_dead_friend? and $scene.tactics_dead.size == 0
      return false
    end 
    return true
  end
  #--------------------------------------------------------------------------
  # Get the angle the attacker and battler from each other
  #--------------------------------------------------------------------------
  def get_direction(attacker, target = self)
    case attacker.x <=> target.x
    when 0
      case attacker.y <=> target.y
      when 1
        return 2
      when 0
        return 0
      when -1
        return 8
      end
    when 1
      coef = (attacker.y - target.y)/(attacker.x - target.x).to_f
      if coef < -1
        return 8
      elsif coef > 1
        return 2
      else
        return 6
      end
    when -1
      coef = (attacker.y - target.y)/(attacker.x - target.x).to_f
      if coef < -1
        return 2
      elsif coef > 1
        return 8
      else
        return 4
      end
    end 
  end
  #--------------------------------------------------------------------------
  # Determine if attacker is attacking back
  #--------------------------------------------------------------------------
  def from_back?(attacker) 
    return (self.direction == 10 - get_direction(attacker))
  end
  #--------------------------------------------------------------------------
  # Determine if attacker is attacking front
  #--------------------------------------------------------------------------
  def from_front?(attacker)
    return (self.direction == get_direction(attacker))
  end
  #--------------------------------------------------------------------------
  # Determine if attacker is attacking from side (not used, back? and front? are tested)
  #--------------------------------------------------------------------------
  def from_side?(attacker)
    return false if from_front?(attacker)
    return false if from_back?(attacker)
    return true
  end 
  #--------------------------------------------------------------------------
  # Apply direction - for direction based attack enhance/decrements
  #--------------------------------------------------------------------------
  def apply_direction(damage, attacker)
    if self.from_back?(attacker)
      damage *= 1.3
    elsif self.from_front?(attacker)
      damage *= 0.8
    end
    return damage.to_i
  end
  #--------------------------------------------------------------------------
  # Reduce AT
  #--------------------------------------------------------------------------
  def reduce_at?
    if $game_system.cust_battle == Game_System::ATB_Mode && GTBS::REDUCE_AT_PERC > 0
      self.atb -= self.atb * GTBS::REDUCE_AT_PERC / 100
    end
  end
  #--------------------------------------------------------------------------
  # Check for Chain Effect
  #--------------------------------------------------------------------------
  def check_for_chain_effect(damage)
    if $scene.is_a?(Scene_Battle_TBS)
      affected = $scene.hit_count
      if affected > 0
        curve = GTBS::CHAIN_LIGHTNING_CURVE
        chain_perc = (curve[affected -1] or curve.last)
        damage *= chain_perc/100.to_f
        return damage.to_i
      end
    end
    return damage
  end
  
  #--------------------------------------------------------------------------
  # Make Damage Value
  #--------------------------------------------------------------------------
  # Returns the dmg that would be delivered if this item were applied.
  #--------------------------------------------------------------------------
  alias mk_gtbs_dmg_value make_damage_value
  def make_damage_value(user, item)
    mk_gtbs_dmg_value(user, item)
    if(@result.hp_damage > 0 && item.apply_direction)
      @result.hp_damage = apply_direction(@result.hp_damage, user)  
    end
  end
  
  #--------------------------------------------------------------------------
  # Execute Damage - Secret Hunt additions
  #--------------------------------------------------------------------------
  alias exec_dmg_gtbs execute_damage
  def execute_damage(user)
    #now execute original dmg
    exec_dmg_gtbs(user)
    
    #now process special events(secret hunt etc)
    execute_post_dmg_events(user)
  end
  #--------------------------------------------------------------------------
  # Secret Hunt addition checking / Allies dead counting
  #--------------------------------------------------------------------------
  def execute_post_dmg_events(user)    
    a = user.current_action 
    if a != nil && !a.item? && !a.guard? #Is not item or guard
      check_special_events(user, a.item) 
    end
    increment_ally_death(user)
  end
  #--------------------------------------------------------------------------
  # On Damage additions
  #--------------------------------------------------------------------------
  alias on_dmg_gtbs on_damage
  def on_damage(value)
    on_dmg_gtbs(value)
    reduce_at? #apply at lose (if feature is enabled)
  end
  
  #--------------------------------------------------------------------------
  # Check Secret Hunt Results
  #--------------------------------------------------------------------------
  def check_special_events(user, skill)
    return if !SceneManager.scene_is?(Scene_Battle_TBS)
    secret_hunt_results(user, skill)
    capture_results(user, skill)
  end
  #--------------------------------------------------------------------------
  # Capture Enemy Results
  #--------------------------------------------------------------------------
  def capture_results(user, skill)
    if !dead? && @result.missed == false && @result.evaded == false
      # should now check for Charm/Capture/Invite logic
      if (GTBS.skill_has_capture?(skill.id))
        set_team(user.team)
        hide
        SceneManager.scene.dispose_character(self)
        obj = Anim_Miss.new(3, GTBS::CAPTURE_ANIMATION)
        obj.place(self.x, self.y)
        obj.start_anim
      elsif (GTBS.skill_has_charm?(skill.id))
        if (user.team == (self.temp_team != nil ? self.temp_team : self.team))
          self.remove_state(GTBS::CHARM_ID)
        else
          self.add_state(GTBS::CHARM_ID)
          self.temp_team = user.team
          @state_turns[GTBS::CHARM_ID] = GTBS.charm_turns(skill_id) 
        end
      elsif (GTBS.skill_has_invite?(skill.id))
        if GTBS.prevent_invite(self, self.enemy?)
          obj = Anim_Miss.new
          obj.place(self.x, self.y)
          obj.start_anim
          return
        end
        obj = Anim_Miss.new(3, GTBS::CAPTURE_ANIMATION)
        obj.place(self.x, self.y)
        obj.start_anim
        set_team(user.team)
      end
    end
  end
  #--------------------------------------------------------------------------
  # Secret Hunt results
  #--------------------------------------------------------------------------
  def secret_hunt_results(user, skill)
    if dead? and @result.hp_damage > 0 and user.actor? and self.enemy?
      if GTBS.skill_has_secret_hunt?(skill.id)
        itemlist = GTBS.secret_hunt_result?(self.enemy_id)
        perc = rand(100)
        for i in -(itemlist.size-1)..0
          item = itemlist[i]
          if item != []
            next if !(perc < item[2])
            case item[0]
            when 0 #item
              _item = $data_items[item[1]]
            when 1 #weapon
              _item = $data_weapons[item[1]]
            when 2 #armor
              _item = $data_armors[item[1]]
            end
            next if _item.nil?
            $game_party.gain_item(_item,1)
            $game_message.add(sprintf(Vocab::ObtainItem, _item.name))
            break;
          end
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Increment Ally Death Variable
  #--------------------------------------------------------------------------
  def increment_ally_death(user)
    return if !SceneManager.scene_is?(Scene_Battle_TBS)
    varid = GTBS::Increment_Variable_Friendly_Kill
    if varid > 0 and dead? and is_ally_target(user)
      $game_variables[varid] += 1
    end
  end
  #--------------------------------------------------------------------------
  # Skill Range - Determines range for skills
  #--------------------------------------------------------------------------
  def skill_range(skill_id)
    base_range = GTBS.skill_range(skill_id).clone
    return base_range if GTBS::Prevent_Skill_Range_Mod.include?(skill_id)
    base_range = skill_range_mod?(base_range)
    base_range = adjust_range_for_summon(base_range, skill_id)
    return base_range
  end
  #----------------------------------------------------------------------------
  # Return Opponent units
  #----------------------------------------------------------------------------
  def opponents 
    if SceneManager.scene_is?(Scene_Battle_TBS)
      return SceneManager.scene.opponents_of(self)
    end
  end
  #----------------------------------------------------------------------------
  # Return Friend units
  #----------------------------------------------------------------------------
  def friends
    if SceneManager.scene_is?(Scene_Battle_TBS)
      return SceneManager.scene.friends_of(self)
    end
  end
  #----------------------------------------------------------------------------
  # Returns Dead Friends
  #----------------------------------------------------------------------------
  def dead_friends
    if SceneManager.scene_is?(Scene_Battle_TBS)
      return SceneManager.scene.dead_friends_of(self)
    end
  end
  #----------------------------------------------------------------------------
  # Move to new_pos if teleport success to position? 
  # 
  #----------------------------------------------------------------------------
  def teleport?( new_pos)
    dist = (@x - new_pos.x).abs + (@y - new_pos.y).abs
    if dist > 10
      chance = 30-(dist*rand(5))
    elsif dist > 8
      chance = 40-(dist*rand(5))
    elsif dist > 6
      chance = 60 -(dist*rand(5))
    elsif dist > 4
      chance = 80 -(dist*rand(5))
    else
      chance = 100-((dist*rand(2))+5)
    end
    chance += 30 if self.state?(GTBS::TELEPORT2_ID)
    return rand(100) < chance
  end
  #-----------------------------------------------------------------
  #* battler can teleport?
  #----------------------------------------------------------------
  def can_teleport?
    state?(GTBS::TELEPORT2_ID) or state?(GTBS::TELEPORT1_ID)
  end
  
  #-------------------------------------------------------------------------
  #* encounter_enemy?
  # Is the battler near an enemy ?
  # return always false if the ENCOUNTER_MOVING_METHOD == false
  #------------------------------------------------------------------------- 
  def encounter_enemy?( nu_x, nu_y, no_test)
    return false unless GTBS::ENCOUNTER_MOVING_METHOD
    return false if no_test
    for enemy in opponents
      next if enemy.death_state?
      if (enemy.x - nu_x).abs + (enemy.y - nu_y).abs == 1
        return true 
      end
    end 
    return false
  end 
  
  #--------------------------------------------------------------------------
  # Adjust Special States - Applies Flying or WWater states to actors and enemies alike
  #--------------------------------------------------------------------------
  def adjust_special_states
    self.reset_float
  end
  
  #-------------------------------------------------------------
  # GTBS Entrance
  #-------------------------------------------------------------
  def gtbs_entrance(x,y)
    moveto(x,y)
    @damage = nil
    @damage_pop = false
    appear
    @tbs_battler = true
    @step_anime = GTBS::STOPPED_ANIM
    adjust_special_states
  end
  #-------------------------------------------------------------
  # Closest Enemey
  #-------------------------------------------------------------
  def closest_enemy
    return  self.opponents.min{|enemy1, enemy2|
      $game_map.distance( self, enemy1) <=> $game_map.distance(self, enemy2) }
  end
  #-------------------------------------------------------------
  # Face Closest Enemey - AI function to set 'wait' or 'defend' direction 
  #-------------------------------------------------------------
  def face_closest_enemy
    self.turn_to(closest_enemy)
  end
  

  
  #----------------------------------------------------------------
  # Get Enemies 
  #----------------------------------------------------------------
  #def get_possible_targets(type = 'attack')
  #  return opponents + allies
  #end
  
  #Array of [dir, dx, dy] to test the 4 directions
  TEST_DIR = [ [2, 0, 1], [4, -1, 0], [6, 1, 0], [8, 0, -1] ]
  #--------------------------------------------------------------------------------------------------------------
  #* calc_pos_move
  #-------------------------------------------------------------------------------------------------------------
  def calc_pos_move( move_range = base_move_range)
    #initialize the encounter method
    start_move = true
    
    #start position initialization 
    start_pos = self.pos    #push starting position
    route = {start_pos => []}                                  #initialize route #Push empty route for starting postion
    cost = {start_pos => 0}                                       #start position cost = 0
    more_step = [start_pos]                                  #initialize array
    
    for pos in more_step                              #each step in position
      x, y = pos                          #set x, y for index
      c = cost[pos]                                  #set cost for current postion index
      
      for dir,dx,dy in TEST_DIR   # loop for the four directions
        nu_pos = (nu_x, nu_y = x + dx, y + dy)    # nu_pos = [nu_x, nu_y]
        
        next if !self.passable?(x, y, dir) and !override_passable?( x, y, dir, nu_x, nu_y, flying_unit)     # can battler go to new position ? 
          
        nu_cost = c+1+ $game_map.add_cost_move(self, x, y, dir, nu_x, nu_y, flying_unit, passable?(x, y, dir)) 
        next if nu_cost > move_range          # Abort tests if current route cost is bigger than move_range
        
        old_cost = cost[nu_pos]
        # if not reached yet or old_cost is bigger
        if !old_cost or old_cost > nu_cost
          route[nu_pos] = route[pos] + [dir]
          cost[nu_pos] = nu_cost
          if nu_cost < move_range   and    #can one more step?
            !encounter_enemy?(nu_x, nu_y, start_move)   # always false if ENCOUNTER_METHOD disabled
            #push more step for position if no close to enemy
            more_step.push(nu_pos)
          end
        #switch 1/2 times if equal cost
        elsif cost[nu_pos] == nu_cost
          if rand(2) == 0
            route[nu_pos] = route[pos] + [dir]
          end
        end
      end#4dir loop for
      start_move = false       if start_move # at the end of the tests of the start position, this flag is set to false
    end
    
    for pos in cost.keys #check all positions 
      if !can_occupy?(pos)
        route.delete(pos)
      end
    end
    return route, cost
  end
  #-----------------------------------------------------------------------------
  # Calculate Positions For Teleport
  #-----------------------------------------------------------------------------
  def set_teleport_positions
    posArray = []
    for x in 0...$game_map.width
      for y in 0...$game_map.height
        if $game_map.passable?(x, y, 0)
          posArray << [x, y]
        end
      end
    end
    deleteme = []
    for pos in posArray #check all positions 
      if !can_occupy?(pos)
        deleteme << pos
      end
    end
    return posArray - deleteme;
  end
  
  #-----------------------------------------------------------------------------
  # Override Passable? - Method stub for advanced movement types.
  #-----------------------------------------------------------------------------
  def override_passable?( x, y, dir, nu_x, nu_y, flying_unit)
    return false
  end
  
  #-----------------------------------------------------------------------------
  #* clac_pos for bow range
  #-----------------------------------------------------------------------------
  def calc_pos_bow( range_max, range_min, move_positions = [self.pos] )
    return [] unless range_max
    
    #Clarabel: I'm not sure that this method is efficient:
    # This method let a 2-size unit shoot from its left pos to the right with a range lesser than range_min... 
    all_pos = []
    rem_pos = []
    atk_pos = []
    for x, y in move_positions
      for ox, oy in self.positions(x, y)
        atk_pos.clear
        rem_pos.clear
        for mx in -range_max..range_max
          for my in (-range_max+mx.abs)..(range_max-mx.abs)
            nu_x, nu_y = ox + mx, oy + my
            next unless $game_map.valid?(nu_x, nu_y)
            #save prohibited positions for positions (x, y)
            if mx.abs + my.abs < range_min
              rem_pos.push [nu_x, nu_y]
              next
            end
            #don't check tile_height for non iso map
            if bow_position_cost(mx, my, ox, oy) <= range_max
              atk_pos.push([nu_x, nu_y])
            end
          end#my
        end#mx
        all_pos |= atk_pos - rem_pos                 #no duplicated positions or prohibited positions
      end#battler_pos
    end
    return all_pos
  end
  #--------------------------------------------------------------------------------------------------------------
  # Bow Position Cost
  #--------------------------------------------------------------------------------------------------------------
  def bow_position_cost(offset_x, offset_y, sx, sy)
    return offset_x.abs + offset_y.abs
  end
  #--------------------------------------------------------------------------------------------------------------
  #* calc_pos_attack 
  # use to draw attackable positions for a weapon with line area
  #-------------------------------------------------------------------------------------------------------------
  def calc_pos_attack( range_max, range_min, move_positions = [self.pos])
    return [] unless range_max
    # store all attackable_positions from all move_positions
    positions = []
    table_positions =  Table.new($game_map.width, $game_map.height)

    for x, y in move_positions
      #save battler.positions for calculate one time
      battler_positions = self.positions(x, y)#all square of a large unit
      if range_max == 0 and range_min == 0 
        positions.push [battler_positions]
      end
      #prevent for attack self 
      for ox, oy in battler_positions
        test_dir = []
        for i in 0..3
          unless battler_positions.include?([[ox, oy+1], [ox, oy-1], [ox-1,oy], [ox+1,oy]][i])
            test_dir.push(i)
          end
        end
        for atk_r in (range_min+1)..(range_max)
          test_pos = []
          for i in test_dir
            case i
            when 0 ;  test_pos.push([ox, oy+atk_r]) #attack down 
            when 1 ;  test_pos.push([ox, oy-atk_r])   #attack  up
            when 2 ;  test_pos.push([ox-atk_r, oy]) #attack left
            when 3 ;  test_pos.push([ox+atk_r, oy]) #attack  right
            end 
          end
          for tx, ty in test_pos
            next unless $game_map.valid?(tx, ty)
            positions.push [tx, ty] if valid_attack_pos?(tx, ty, ox, oy) && !positions.include?([tx, ty])
          end
        end
      end
    end
    return positions
  end
  #--------------------------------------------------------------------------------------------------------------
  # Valid Attack Position - Returns if the position is valid
  #--------------------------------------------------------------------------------------------------------------
  def valid_attack_pos?(tx, ty, sx, sy)
    return false unless $game_map.valid?(tx, ty) 
    return true
  end
  #--------------------------------------------------------------------------------------------------------------
  #* calc_pos_spell
  #  use to draw area of effect for spell or weapon attack
  #-------------------------------------------------------------------------------------------------------------
  def calc_pos_spell(range_max, range_min, move_positions = [self.pos], v_range = 0) # mod MGC
    return [] if range_max == nil
    return self.positions  if range_max == 0

    rem_pos = []
    #prevents items from being pushed if height change between core and outer is less than range/2
    normal_h_max = [2, range_max/2].max
    long_h_max = [2, range_max/1.5].max 
    positions = []
    for x, y in move_positions
      #save battler.positions for calculate one time
      battler_positions = self.positions(x, y)#all square of a large unit

      #save position for later processing 
      for x, y in battler_positions
        
        #prevents items from being pushed if height change between core and outer is less than range/1.5
        h_max = long_h_max
        for i in 0..range_max
          it = range_max - i  
          #test all couples (it, oy) like: 0 <= it+oy <= range_max
          for oy in 0..i
            next if it+oy < range_min 
            for ux, uy in[ [x - it, y - oy], [x - it, y + oy], [x + it, y + oy], [x + it, y - oy] ]
              positions.push([ux, uy]) if valid_new_spell_pos(ux, uy, x, y, v_range) and not positions.include?([ux, uy]) # mod MGC
            end
          end
          #prevents items from being pushed if height change between core and outer is less than range/2
          h_max = normal_h_max
        end
        #-------------  -------------  -------------  -------------  -------------  -------------  
        # Do min processing to remove positions if needed
        #Clarabel: no need to test rem_pos, if they are not valid, they are not in positions
        #let the array method @- make the job one time
        for mx in -range_min..range_min
          for my in (-range_min+mx.abs+1)..(range_min-mx.abs-1)
            rem_pos.push([x + mx, y + my])
          end
        end
      end#positions loop
    end#move_posions loop
    return positions - rem_pos
  end
  #------------------------------------------------------------------------
  #* determine the area hitted when the action act in pos
  #----------------------------------------------------------------------
  def target_zone(move_pos = self.pos, act_pos = current_action.position, type = nil)
    return [] unless type.is_a?(Array) and type[0] != nil
    line, field, range, exclude_caster, v_range_aoe = type 
    if line #line skill
      result = []
      d = get_direction(POS.new(act_pos[0], act_pos[1]), POS.new(move_pos[0], move_pos[1]))
      for x, y in range
        if (d == 2 and y > move_pos[1] + (unit_size-1) ) or 
           (d == 6 and x > move_pos[0] + (unit_size-1)) or 
           (d == 4 and x < move_pos[0] ) or 
           (d == 8 and y < move_pos[1] )
          result.push([x, y]) if GTBS::LARGE_LINE or x == act_pos[0] or y == act_pos[1]
        end
      end 
    else#spell area
      result = $tbs_cursor.calculate_aoe( field, 0,  act_pos[0], act_pos[1], v_range_aoe) # mod MGC
    end 
    #remove caste
    result -= self.positions(move_pos[0], move_pos[1]) if exclude_caster 
    return result
  end

  #------------------------------------------------------------------------------
  #* check if ux, uy is a valid position
  #------------------------------------------------------------------------------
  def valid_new_spell_pos(tx, ty, sx, sy, v_range) # mod_MGC
    return false unless $game_map.valid?(tx, ty) 
    return true
  end 

  #----------------------------------------------------------------------------
  # Check Frame/Pose Overrides
  #----------------------------------------------------------------------------
  # Returns the number of frames and poses for the current battler
  #----------------------------------------------------------------------------
  def check_frame_pose_overrrides
    case anim_mode
    when :GTBS
      #------------------------------------------------------------
      # * Stances
      #------------------------------------------------------------
      stances = self.anim_stances
      frames = GTBS::DEFAULT_POSE_FRAMES
      #------------------------------------------------------------
      # * Frames
      #------------------------------------------------------------
      framhash = self.frame_hash
      if framhash != nil
        for key in framhash.keys
          if framhash[key] > frames
            frames = framhash[key]
          end
        end
        # If a frame hash exist for all of the stances, ensure that total frames is
        # not less than default.  If so, set to be lower than default.  
        if (framhash.keys.size == stances) and frames == GTBS::DEFAULT_POSE_FRAMES
          frames = 0
          for key in framhash.keys
            frames = framhash[key] if framhash[key] != nil
          end
        end
      end
      return frames, stances
    when :MINKOFF
      #------------------------------------------------------------
      # * Stances
      #------------------------------------------------------------
      stances = self.anim_stances
      frames = GTBS::MINKOFF_HOLDER_POSE_FRAMES
      
      #------------------------------------------------------------
      # * Frames
      #------------------------------------------------------------
      framhash = self.frame_hash
      if framhash != nil
        for key in framhash.keys
          if framhash[key] > frames
            frames = framhash[key]
          end
        end
        # If a frame hash exist for all of the stances, ensure that total frames is
        # not less than default.  If so, set to be lower than default.  
        if (framhash.keys.size == stances) and frames == GTBS::MINKOFF_HOLDER_POSE_FRAMES
          frames = 0
          for key in framhash.keys
            frames = framhash[key] if framhash[key] != nil
          end
        end
      end
      return frames, stances
    when :KADUKI
      frames = 3, stances = 4  
      #Sizes are hard coded.  This method actually adds 
      # suffix entries to character name
      return frames, stances
    end
  end
    #-------------------------------------------------------------------------
  # Get Targets - Determines targets in target_cursor area  
  #-------------------------------------------------------------------------
  def get_targets
    return self.current_action.tbs_make_targets
  end
  #-------------------------------------------------------------------------
  # battler will hide his move?
  #-------------------------------------------------------------------------
  def hide_move?
    return false
  end
  #--------------------------------------------------------------
  #* Check for possible action/move when activated
  #-------------------------------------------------------------
  def start_turn
    @sprite_effect_type = :whiten
    if casting?
      @moved = true if GTBS.skill_wait(@skill_cast[0].id)[2]
      @perf_action = true
    end
    if state?(GTBS::DONT_ACT_ID)
      @perf_action = true
    end
    if state?(GTBS::DONT_MOVE_ID)
      @moved = true
    end
    clear_actions
    @actions << Game_Action.new(self)
  end
  
  def end_turn
  end
  
  #------------------------------------------------------------------
  #* set_wait 
  #------------------------------------------------------------------
  def set_wait
    self.has_doom?
    if !perfaction? and GTBS::AUTO_DEFEND
      self.current_action.set_guard
    end
    clear_tbs_actions
  end
  #----------------------------------------------------------------
  #* count usage and consequence of the skill
  #---------------------------------------------------------------
  def count_skill_usage(spell) 
    if GTBS.skill_wait(spell.id)[2]
      self.perf_action = true
      self.moved = true
    elsif GTBS.skill_use_action?(spell.id)
      self.perf_action = true
    else
      self.skill_turn_usage += 1
    end
  end

  #--------------------------------------------------------------------------
  # * Recover All
  #--------------------------------------------------------------------------
  alias vx_recover_all recover_all
  def recover_all
    vx_recover_all
    #BLARG - this needs to be revised to use the new HP pop method
    if SceneManager.scene_is?(Scene_Battle_TBS) and self.damage_pop != true
      self.animation_id = 40 #recover
      self.damage = "Recover"
      self.damage_pop = true
    end
  end
  #--------------------------------------------------------------------------
  # * Perform_death
  #--------------------------------------------------------------------------
  def perform_death
    return unless dead?
    @skill_cast = nil
    self.up_cast(true)
    if will_collapse?
      SceneManager.scene.queue_collapse(self)
    end
  end
  def opacity
    return @opacity
  end
  def opacity=(value)
    @opacity = value
  end
  def current_action=(action)
    @actions = [action]
  end
  #--------------------------------------------------------------------------
  # * Calculate Damage
  #--------------------------------------------------------------------------
  def make_gtbs_dmg_preview_data(user, item)
    #expected preview data 
    #[hit_chance, damage, amp, hit_states, rem_states]
    
    value = item.damage.eval(user, self, $game_variables)
    value *= item_element_rate(user, item)
    value *= pdr if item.physical?
    value *= mdr if item.magical?
    value *= rec if item.damage.recover?
    
    hit_chance = (item_hit(user, item) * 100).to_i
    hit_chance = add_eva?(hit_chance)
    amp = [100 * item.damage.variance / 100, 0].max.to_i.to_s + "%"
    result = Game_ActionResult.new(self)
    result.make_damage(value,item)
    if(result.hp_damage > 0 && item.apply_direction)
      result.hp_damage = apply_direction(result.hp_damage, user)  
    end
    get_item_effects(user, item, result)
    mp = (result.mp_damage != 0)
    return [hit_chance, value.to_i, amp, result.added_states,result.removed_states, mp]
  end
  def get_item_effects(user, item, result)
    for effect in item.effects
      item_state_effect_test(user, item, effect, result)
    end
    #for some reason this block wont execute.  Works fine in for statement though. 
    #item.effects {|effect| item_state_effect_test(user, item, effect, result) }
  end
  #--------------------------------------------------------------------------
  # Add Eva
  #--------------------------------------------------------------------------
  def add_eva?(hit_chance)
    return hit_chance
  end  
  #--------------------------------------------------------------------------
  # * Test Status Effects
  #--------------------------------------------------------------------------
  def item_state_effect_test(user, item, effect, result)
    case effect.code
    when EFFECT_ADD_STATE
      if (!state?(effect.data_id))
        result.added_states << effect.data_id
      end
    when EFFECT_REMOVE_STATE
      if (state?(effect.data_id))
        result.removed_states << effect.data_id
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Clear TBS Actions - Resets tbs flags for moved/acted
  #--------------------------------------------------------------------------
  def clear_tbs_actions
    clear_actions
    @actions << Game_Action.new(self)
  end
  #--------------------------------------------------------------------------
  # * Processing at End of Turn
  #--------------------------------------------------------------------------
  alias on_turn_end_gtbs_battler on_turn_end
  def on_turn_end
    on_turn_end_gtbs_battler
    @sprite_effect_type = nil #turn off blink
    @moved = false
    @perf_action = false
    skill_turn_usage=0 #reset skill usage flags
  end
  #--------------------------------------------------------------------------
  # Move Action Waiting (This is for specialized attacks)
  #--------------------------------------------------------------------------
  def move_action_waiting
    @move_actions.size > 0
  end
  #--------------------------------------------------------------------------
  # Weapon Action Waiting (This is for specialized attacks)
  #--------------------------------------------------------------------------
  #def weapon_action_waiting
  #  if @weapon_actions.size > 0
  #    return true
  #  else
  #    return false
  #  end
  #end
  #--------------------------------------------------------------------------
  # Apply Move Cost
  # * MOVE: The cost value to move to tile
  #--------------------------------------------------------------------------
  def apply_move_cost(move)
    value = move * GTBS::REQUIRED_TP_FOR_MOVE
    self.tp -= value.to_i
  end
  #--------------------------------------------------------------------------
  # Atk Animation 1 (right)
  #--------------------------------------------------------------------------
  def atk_animation_id1
    return 0
  end
  #--------------------------------------------------------------------------
  # Atk Animation 2 (left)
  #--------------------------------------------------------------------------
  def atk_animation_id2
    return 0
  end
  #-----------------------------------------------------------------------------
  # Reset Weapon Check - Sets the next weapon check to first weapon index
  #-----------------------------------------------------------------------------
  def reset_wep_check
    @wep_check = 0
  end
  #-----------------------------------------------------------------------------
  # Returns the current weapon index
  #-----------------------------------------------------------------------------
  def weapon_index
    return @wep_check
  end
  #-----------------------------------------------------------------------------
  # Next Weapon - returns next weapon for actor.  Will return nil when no weapon
  #-----------------------------------------------------------------------------
  def next_weapon
    wep = weapons[@wep_check]
    @wep_check += 1
    return wep
  end
  #-----------------------------------------------------------------------------
  # Current Weapon
  #-----------------------------------------------------------------------------
  def current_weapon
    weapons[@wep_check]
  end
  #-----------------------------------------------------------------------------
  # Item User Effect edits
  #-----------------------------------------------------------------------------
  def item_user_effect(user, item)
    if $game_system.team_mode? && item.is_a?(RPG::Skill) 
      if GTBS::Reset_Move_Flag_Skills.include?(item.id)
        @moved = false
        On_ReAct
      end
      if GTBS::Reset_Action_Flag_Skills.include?(item.id)
        @perf_action = false
        On_ReAct
      end
    end
    item_user_effect_gtbs(user,item) #call old method
  end
  #-----------------------------------------------------------------------------
  # On Re-Act - Only Applicable to GTBS:TEAM_MODE
  #-----------------------------------------------------------------------------
  def On_ReAct
    if (SceneManager.scene_is?(Scene_Battle_TBS) && $game_system.team_mode?)
      if ($game_system.acted.include?(self))
        $game_system.acted.delete(self) #allows this actor/enemy to act again
      end
    end
  end
  #-----------------------------------------------------------------------------
  # Add State
  #-----------------------------------------------------------------------------
  def add_state(state_id)
    add_state_gtbs(state_id) # call old method
    tactic_new = GTBS.state_tactic(state_id)
    if (@result.added_states.include?(state_id) && tactic_new != "")
      @temp_tactic = tactic_new
      if @originally_neutral == false && @neutral == false
        @neutral = true
      end
    end
  end
  #-----------------------------------------------------------------------------
  # Remove State
  #-----------------------------------------------------------------------------
  def remove_state(state_id)
    rem_state_gtbs_charm(state_id) #call old method
    if (@result.removed_states.include?(state_id))
      if (state_id == GTBS::CHARM_ID)
        self.temp_team = nil
      elsif (GTBS.state_tactic(state_id) != "")
        if @temp_tactic
          @temp_tactic = nil
          @neutral = @originally_neutral
        end
      end
    end
  end
  #-----------------------------------------------------------------------------
  # Weapon Name - Returns the actors first weapon name
  #-----------------------------------------------------------------------------
  def weapon_name
    weapons[0] != nil ? weapons[0].name : nil
  end
  
  #--------------------------------------------------------------------------
  # * Apply Float Effect - Applies the effect of floating
  #--------------------------------------------------------------------------
  def apply_float_effect(val)
    if @float_offset != nil
      val -= @float_offset
    end
    return val
  end
  
  #--------------------------------------------------------------------------
  # * Get Weapon Animation Data - using weapon index
  #--------------------------------------------------------------------------
  def make_weapon_animation(wep_index)
    #Create base instruction for 'image move parameters'
    wep_sym = "weapon#{wep_index+1}".to_sym
    imp = SceneManager.scene.get_default_image_paramters
    imp[:container] = self 
    imp[:key] = wep_sym 
    imp[:filename] = wep_sym
    if actor?
      if (weapons.size > wep_index)
        weapon = weapons[wep_index]
        weapon.deliver_action(imp)
      end
    elsif enemy?
      if (GTBS::Enemy_Weapon.keys.include?(self.enemy_id))
        wepArray = GTBS::Enemy_Weapon[self.enemy_id]
        if (wepArray != nil && wepArray.size > wep_index)
          weapon = $data_weapons[wepArray[wep_index]]
          weapon.deliver_action(imp)
        end
      end
    end
  end
end