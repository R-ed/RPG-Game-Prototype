class Sprite_Battler_GTBS < Sprite_Character
  #--------------------------------------------------------------------------
  # * BLINK COLORS
  #--------------------------------------------------------------------------
  ATK_BLINK_COLOR = [255, 128, 128, 128]
  SPELL_BLINK_COLOR = [128, 255, 128, 128]
  HELP_BLINK_COLOR = [128, 128, 255, 128]
  ACTIVE_BLINK_COLOR = [255, 255, 255, 128]
  
  DEFAULT_MOVEMENT_TIME = 10
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :battler
  attr_accessor :battler_name
  attr_reader   :_damage_duration
  attr_reader   :_animation_duration 
  
  POSE_HASH = GTBS::DEFAULT_POSE_NUMBERS
  POSE_HASH_MINKOFF = GTBS::MINKOFF_HOLDER_POSE_NUMBERS
  LOOP_TYPE = POSE_HASH['Wait'] + POSE_HASH['Walk'] + POSE_HASH['Defend'] + 
                              POSE_HASH['Dead'] + POSE_HASH['Near Death']  

                              
  alias init_gm_bat_gtbs_base initialize
  def initialize(viewport, char)
    @effect_duration = 0
    #@weapon = Sprite_Weapon.new(viewport, char)
    @animation_queue = []
    @pose = 0;
    @last_time = 0;
    @max_frame = GTBS::DEFAULT_POSE_FRAMES
    init_gtbs_movement_vars
    init_gm_bat_gtbs_base(viewport, char)
  end
  #----------------------------------------------------------------------------
  # Bat - this method returns the battler that is held in this object
  #----------------------------------------------------------------------------
  def bat
    return @character
  end
  def bat=(battler)
    init_gtbs_movement_vars
    #@weapon.battler = battler
    return @character = battler
  end
  
  #--------------------------------------------------------------------------
  # Append Animation Queue - Queues series of animations for play
  #--------------------------------------------------------------------------
  def append_anim_queue(anims)
    if anims.is_a?(Numeric)
      anims = [anims]
    end
    @animation_queue += anims
  end
  #--------------------------------------------------------------------------
  # * Determine if Effect Is Executing
  #--------------------------------------------------------------------------
  def effect?
    return true if @effect_type != nil
    #return true if  @weapon.visible
    #return true if  moving?
    #result |= LOOP_TYPE.include?(@pose+1)
    return false
  end
  #----------------------------------------------------------------------------
  # Setup New Effect - Edited from Standard Script - Because we are acting
  # as sub-class this should not be an issue of overwritting
  #----------------------------------------------------------------------------
  def setup_new_effect
    if $game_party.in_battle && SceneManager.scene_is?(Scene_Battle_TBS)
      return unless @character
      if !@balloon_sprite && @character.balloon_id > 0
        @balloon_id = @character.balloon_id
        start_balloon
      end
      if !@character_visible && @character.alive?
        start_effect(:appear)
        @character_visible = true
      elsif @character_visible && @character.hidden?
        start_effect(:disappear)
        @character_visible = false
      end
      if @character_visible && @character.sprite_effect_type
        start_effect(@character.sprite_effect_type)
        @character.sprite_effect_type = nil
      end
      setup_new_animation #now call animations
    else
      #This should be an impossibility, but rather than assuming that. 
      super #call normal update method if not tbs battle
    end
  end
  #----------------------------------------------------------------------------
  # Offset Large Unit - Sprite
  #----------------------------------------------------------------------------
  def offset_large_unit
    #large unit position update
    self.x += 16*(@character.unit_size-1)
    self.y += 16*(@character.unit_size-1)
    self.y = @character.apply_float_effect(self.y)
    update_dodge_offsets
    update_shadow
  end
  #--------------------------------------------------------------------------
  # Updates the Dodge Offsets for animation of the dodge
  #--------------------------------------------------------------------------
  def update_dodge_offsets
    self.x = apply_x_dodge_offset(self.x)
    self.y = apply_y_dodge_offset(self.y)
  end
  #--------------------------------------------------------------------------
  # Adjust the X placement by dodge offset
  #--------------------------------------------------------------------------
  def apply_x_dodge_offset(val)
    @offset = 0 if @offset.nil?
    val += (get_direction == 8 ? @offset : get_direction == 6 ? -(@offset) : 0)
    return val
  end
  #--------------------------------------------------------------------------
  # Adjust the Y placement by dodge offset
  #--------------------------------------------------------------------------
  def apply_y_dodge_offset(val)
    @offset = 0 if @offset.nil?
    val += (get_direction == 6 ? @offset : get_direction == 4 ? -(@offset) : 0)
    return val
  end
  #----------------------------------------------------------------------------
  # Update Shadow
  #----------------------------------------------------------------------------
  def update_shadow
    create_shadow?
    if @shadow != nil and !@shadow.disposed?
      @shadow.update(self.x, self.y)
    end
  end
  #----------------------------------------------------------------------------
  # Update Bitmap - Updates the battler info and sprite info
  #----------------------------------------------------------------------------
  def set_character_bitmap
    @character_anim = @character.animated? 
    set_bitmap
  end
  #----------------------------------------------------------------------------
  # Sets the Bitmap
  #----------------------------------------------------------------------------
  def set_bitmap
    self.bitmap = Cache.battler(@character_name, hue)
    set_dimensions 
    self.ox = @cw / 2
    self.oy = @ch
  end    
  #----------------------------------------------------------------------------
  # Set Dimensions - Sets the cut width and cut height to be used when setting the
  # image. 
  #----------------------------------------------------------------------------
  def set_dimensions
    sign = get_sign
    if @character_anim == false || bat.anim_mode == :CHARSET
      if sign && sign.include?('$')
        @cw = bitmap.width / 3
        @ch = bitmap.height / 4
      else
        @cw = bitmap.width / 12
        @ch = bitmap.height / 8
      end
      @index_array = [0,1,2]
      return
    end
    w,h = @character.check_frame_pose_overrrides
    @cw = bitmap.width / w
    #Only GTBS mode needs all 4 directions of each stance, otherwise 1 row for ea.
    div = bat.anim_mode == :GTBS ? 4 : 1  
    @ch = ((bitmap.height / h) / div) 
    update_frame_index_array  #for changing bitmap
  end
  #----------------------------------------------------------------------------
  # Victor Engine compatiblity required override
  #----------------------------------------------------------------------------
  def set_bitmap_position
  end
  #----------------------------------------------------------------------------
  # Create Shadow? - Determines if conditions are met to generate shadow sprite
  #----------------------------------------------------------------------------
  def create_shadow?
    if @shadow == nil and @character.floating?
      @shadow = Sprite_GTBS_Shadow.new(viewport, @character)
    end
    if @shadow != nil and !@character.floating?
      @shadow.dispose
      @shadow = nil
    end
  end
  #----------------------------------------------------------------------------
  # Apply pose animation intercept if any
  #----------------------------------------------------------------------------
  def setup_new_animation
    if @animation_queue.size > 0 && !animation?
      @character.animation_id = @animation_queue.shift
    end
    if @character.animation_id != 0
      if @character_anim
        check_custom_assign_ids
        case @character.animation_id
        when GTBS::ANIM_ATK
          @character.set_pose("attack")
        when GTBS::ANIM_SPEC1
          @character.set_pose("skill")
        when GTBS::ANIM_CASTING
          @character.set_pose("casting")
        when GTBS::ANIM_CAST
          @character.set_pose("cast")
        when GTBS::ANIM_HEAL
          @character.set_pose("heal")
        else
          if @character.animation_id > 0
            animation = $data_animations[@character.animation_id]
            mirror = @character.animation_mirror
            start_animation(animation, mirror)
            @character.animation_id = 0
          end
        end
      else
        if @character.animation_id > 0
          animation = $data_animations[@character.animation_id]
          mirror = @character.animation_mirror
          start_animation(animation, mirror)
          @character.animation_id = 0
        end
      end
      @character.animation_id = 0
    end

    #if @weapon.visible == false && @character.weapon_action_waiting
    #  act = @character.weapon_actions.shift
    #  action = GTBS.anime_data(act).clone
    #  return if action == []
    #  @weapon.weapon_action(action)
    #end
    
    if !moving? && bat.move_action_waiting
      act = bat.move_actions.shift
      prepare_move_action(act)
    end
  end
  #----------------------------------------------------------------------------
  # Check Custom Assign ID's
  #----------------------------------------------------------------------------
  # This method checks the battler custom pose hash to see if there is a defined 
  # skill => pose data.  If so, set that pose. 
  #----------------------------------------------------------------------------
  def check_custom_assign_ids
    skill_to_pose_hash = bat.cust_skill_pose
    if skill_to_pose_hash != nil
      pose = skill_to_pose_hash[@character.animation_id]
      if pose != nil
        @character.set_pose(pose-1)
        @character.animation_id = 0 #clear animation id since we have handled it
      end
    end
  end
  #----------------------------------------------------------------------------
  # Revert to Normal - New VXA method that I needed to modify from its original
  #----------------------------------------------------------------------------
  def revert_to_normal
    self.blend_type = 0
    self.color.set(0, 0, 0, 0)
    self.ox = @cw/2
    self.opacity = 255
  end
  #----------------------------------------------------------------------------
  # Check if the battler has died
  #----------------------------------------------------------------------------
  def check_collapse
    if !self.effect? and @character.death_state? and (@character.damage == nil)#  or !@character_anim)
      if @character.death_animation?
        check_animations
      end  
      pose_hash = POSE_HASH
      
      #Ensure that current pose is not pain or death
      if @character_anim && !(pose_hash["Pain"]+pose_hash["Dead"]).include?(@character.pose?+1)
        if !@character.will_collapse?
          @character.set_pose("collapse")
        else
          #start_effect(:collapse) collapse is performed by the log display class now
        end
      end
    end
  end
  #------------------------------------------------------------- 
  # Get Near Death Value - Returns the battler near death percentage
  #-------------------------------------------------------------
  def get_near_death_value
    return @character.near_death_percent / 100.0
  end
  #-------------------------------------------------------------
  # Update Battler Pose
  #-------------------------------------------------------------
  # Resets pose to wait if applicable
  #-------------------------------------------------------------
  def update_battler_pose
    if POSE_HASH["Walk"].include?(@pose+1) 
      @character.set_pose('wait') unless @character.moving?
    elsif !LOOP_TYPE.include?(@pose+1)
      @character.set_pose('wait')
    elsif POSE_HASH["Dead"].include?(@pose+1) 
      if !@character.dead?
        @character.set_pose('wait')
        @character.collapsed = false
      end
    elsif POSE_HASH["Near Death"].include?(@pose+1) and 
      get_near_death_value <= (@character.hp_rate)
      @character.set_pose('wait')
    end
    # Set defend pose if current_actions is defend type
    if @character.pose? == POSE_HASH["Wait"] and @character.guard?
      @character.set_pose("defend")
    end
    nd_val = get_near_death_value
    # If waiting or defending, but near death, set near death pose
    if (POSE_HASH["Wait"]+ POSE_HASH["Defend"]).include?(@character.pose?+1) and
      nd_val > (@character.hp_rate)
      if !@character.death_state?
        @character.set_pose("danger") 
      elsif @character.death_state? && !@character.will_collapse?
        @character.set_pose("collapse") 
      end
    end
    
    if (bat.result != nil)
      #damage showing??
      if bat.result.hp_damage > 0 || bat.result.mp_damage > 0
        #set pain pose
        @character.set_pose("pain")
      elsif bat.result.hp_damage < 0 || bat.result.mp_damage < 0
        #set heal pose
        @character.set_pose("heal")
      end
    end
    # Update pose variable
    if @pose != @character.pose?
      @pose = @character.pose?
      @pose_started = false
      update_frame_index_array #for pose change
    end
    #--------------------------------------------------------------
    # Get frame index
    #--------------------------------------------------------------
    if !@pose_started
      update_sound_association
      @pose_started = true
    end
  end
  #-------------------------------------------------------------
  # Get Direction - Updated for usage with mini battlers
  #-------------------------------------------------------------
  def get_direction
    return (@dir || @character.direction)
  end
  #-------------------------------------------------------------
  # Update Source Rect (from bitmap)
  #-------------------------------------------------------------
  alias upd_src_rect_gtbs update_src_rect
  def update_src_rect
    if @character != nil && @tile_id == 0 && @character.animated?
      update_frame_index #singular call to update current frame
      anim_src_rect
    else
      norm_src_rect #Call modified method as we need to override direction assignment
    end
  end
  #-------------------------------------------------------------
  # Normal method for src rect
  #-------------------------------------------------------------
  def norm_src_rect
    index = (@character.character_index || 0)
    pattern = @character.pattern < 3 ? @character.pattern : 1
    sx = (index % 4 * 3 + pattern) * @cw
    sy = (index / 4 * 4 + (get_direction - 2) / 2) * @ch
    self.src_rect.set(sx, sy, @cw, @ch)
  end
  #-------------------------------------------------------------
  # Animated method for src rect
  #-------------------------------------------------------------
  def anim_src_rect
    mode = bat.anim_mode
    if (mode == :CHARSET)
      self.mirror = false;
      norm_src_rect
      return
    end
    multiplier = (mode == :GTBS ? @pose * 4 : @pose)#direction multiplier
    cur_frame = @index_array[@frame_index] #gets from number from index array
    sx = cur_frame * @cw #sets start x for cut window
    if mode == :MINKOFF  #Minkoff ignores direction
      sy = multiplier*@ch
      if @dir != nil and @dir == 6
        self.mirror = true
      else
        self.mirror = false
      end
    elsif mode == :GTBS
      self.mirror = false;
      sy = (((get_direction - 2) / 2) * @ch) + (multiplier*@ch) 
    elsif :KADUKI
      self.mirror = false;
      dir = get_kaduki_pose_direction(@pose)
      sy = ((dir - 2) / 2) * @ch #all animated battlers must be $ started!
    end
    self.src_rect.set(sx, sy, @cw, @ch)
  end
  #-------------------------------------------------------------
  # Get Kaduki Direction for current pose
  #-------------------------------------------------------------
  def get_kaduki_pose_direction
    #read pose information from module
    #using pose as key, access direction info that relates to current _suffix image
    
    #..It may be that I want to actually store this in the battler class and just
    #read it, as it will have already had to do this to get the image _suffix name
    #for the corresponding pose.  Slightly more effective use of CPU time????
    msgbox "Kaduki Type battlers are not currently supported!"
    return get_direction; 
  end
  
  #-------------------------------------------------------------
  # Update Frame Index
  #-------------------------------------------------------------
  def update_frame_index
    speed = GTBS::DEFAULT_FRAME_SPEED
    pose_rate = @character.pose_frame_override
    if pose_rate != nil and pose_rate.keys.include?(@pose)
      speed = pose_rate[@pose]
    end
    speed = adjust_for_states(speed)
    #update the frame
    time = Graphics.frame_count / (Graphics.frame_rate / speed)
    if @last_time < time
      @frame_index = (@frame_index + 1) % @max_frame
      if @frame_index == 0 || @pose == 0 || @pose != bat.pose?
        # Has reset to first frame.. check if new animation
        # should be called
        update_battler_pose
      end
    end
    @last_time = time
  end
  #-------------------------------------------------------------
  # Adjust for States updates the framerate speed to reflect special states, such 
  # as HASTE, SLOW, or STOP
  #-------------------------------------------------------------
  def adjust_for_states(speed)
    if @character.state?(GTBS::HASTE_ID)
      speed *= 1.2
    elsif @character.state?(GTBS::SLOW_ID)
      speed *= 0.8
    end
    return speed.to_i
  end
  #-------------------------------------------------------------
  # Checks for a sound association for specified pose
  #-------------------------------------------------------------
  def update_sound_association
    hash = @character.stance_sound_association
    if hash != nil and hash.keys.include?(@pose+1)
      @character.animation_id = hash[@pose+1]
    end
  end
  #-------------------------------------------------------------
  # Update Frame Index Array
  #-------------------------------------------------------------
  # Sets the index advance array.  This is used to determine which order the frames
  # should be played.
  #-------------------------------------------------------------
  def update_frame_index_array
    @index_array = [0,1,2] if !@character_anim
    hash = @character.pose_path
    if hash != nil and hash.keys.include?(@pose+1)
      @index_array = hash[@pose+1]
      @max_frame = hash[@pose+1].size
    else
      hash = @character.frame_hash
      if hash != nil and hash.keys.include?(@pose+1)
        @max_frame = hash[@pose+1]
      else
        @max_frame = GTBS::DEFAULT_POSE_FRAMES
      end
      @index_array = []
      for i in 0...@max_frame
        @index_array.push(i)
      end
    end
    @frame_index = 0 #force reset current frame index to 0
  end
  #--------------------------------------------------------------------------
  # * Update Other
  #--------------------------------------------------------------------------
  def update_other
    update_action_movement
    update_effect
    if $game_system.acted.include?(@character) and !@character.dead?
      self.opacity = GTBS::DIM_OPACITY
    else
      revert_to_normal unless @effect_type != nil
    end
    update_weapon
    update_team_blink unless @effect_type != nil
    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    self.visible = !@character.transparent
  end
  #--------------------------------------------------------------------------
  # Update Weapon
  #--------------------------------------------------------------------------
  def update_weapon
    unless @weapon.nil?
      @weapon.update 
    end
  end
  #--------------------------------------------------------------------------
  # Update Team Blink
  #--------------------------------------------------------------------------
  def update_team_blink
    if SceneManager.scene_is?(Scene_Battle_TBS)
      if SceneManager.scene.confirm_visible == true
        do_team_blink
      else
        clear_team_blink
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Update Effect
  #--------------------------------------------------------------------------
  def update_effect
    if @effect_duration > 0
      @effect_duration -= 1
      case @effect_type
      when :whiten
        update_whiten
      when :blink
        update_blink
      when :appear
        update_appear
      when :disappear
        update_disappear
      when :collapse
        update_collapse
      when :boss_collapse
        update_boss_collapse
      when :instant_collapse
        update_instant_collapse
      end
      @effect_type = nil if @effect_duration == 0
    end
  end
  #--------------------------------------------------------------------------
  # Update Team Blink 
  #--------------------------------------------------------------------------
  # This method updates according to the current frame rate a slow blink of 
  # friendly and enemy units. For easier notification to the user which units
  # belong to which team.
  #--------------------------------------------------------------------------
  def do_team_blink
    if bat != nil
      count = (Graphics.frame_count % 60) / 10
      bat.team == "actor" ? self.color.set(0, 0, 255, 0) : self.color.set(255, 0, 0, 0)
      self.color.alpha = 128 - (16 * count)
    end
  end
  #--------------------------------------------------------------------------
  # Clear Team Blink
  #--------------------------------------------------------------------------
  def clear_team_blink
    self.color.alpha = 0;
  end
  #--------------------------------------------------------------------------
  # Iniitalize GTBS Movement Variables
  #--------------------------------------------------------------------------
  def init_gtbs_movement_vars
    @positions = {}
    @positions[:origin] = {}
    @positions[:origin][:x] = 0
    @positions[:origin][:y] = 0
    @positions[:origin][:time] = DEFAULT_MOVEMENT_TIME
    @positions[:target] = @positions[:origin].clone
    @positions[:current] = @positions[:origin].clone
    @positions[:jumppeak] = 0;
  end
  #--------------------------------------------------------------------------
  # Prepare Move Action
  #--------------------------------------------------------------------------
  def prepare_move_action(action)  
    clear_movement_data
    @positions[:target][:time] = action.time 
    if (action.jump_peak > 0)
      @positions[:jumppeak] = action.jump_peak
    end
    return if action.reset
      
    #------------------------------------------------------------------------
    if action.xy != nil
      @positions[:target][:x] = action.xy.x
      @positions[:target][:y] = action.xy.y
    end
    
    #------------------------------------------------------------------------
    if action.targets != nil
      target = action.targets[0]
      
      tsprite = SceneManager.scene.get_battler_sprite(target)
      
      tx,ty,w,h = tsprite.gather_pos_data
      tx,ty = adjust_to_relative_pos(tx,ty)
      
      case action.position
      when :head
        @positions[:target][:x] = tx + w/2
        @positions[:target][:y] = (ty-(h*0.75)).to_i
      when :feet
        @positions[:target][:x] = tx
        @positions[:target][:y] = ty + tsprite.oy/2
      else
        @positions[:target][:x] = tx
        @positions[:target][:y] = ty
      end
      
      #Now take the current position (which will be directly on top of the subject)
      #and deduct/add the current direction at have the current ox/oy value
      
      if [7,4,1].include?(self.get_direction)
        @positions[:target][:x] += self.ox
      elsif [9,6,3].include?(self.get_direction)
        @positions[:target][:x] -= self.ox
      elsif self.get_direction == 8 #looking up
        @positions[:target][:y] += self.oy/3 #push down a little
      else #down
        @positions[:target][:y] -= self.oy/3 #push up a little
      end
    end
    if (action.offset_list.size > 0)
      off_x, off_y = 0,0
      for offset in action.offset_list
        case offset[0]
        when :left
          off_x -= offset[1]
        when :right
          off_x += offset[1]
        when :up
          off_y -= offset[1]
        when :down
          off_y += offset[1]
        end
      end
      @positions[:target][:x] += off_x
      @positions[:target][:y] += off_y
    end
  end
  #------------------------------------------------------------------------
  # Adjust target x,y data to relative locations
  def adjust_to_relative_pos(tx,ty)
    x = tx - (self.x - @positions[:current][:x])
    y = ty - (self.y - @positions[:current][:y])
    return x,y
  end
  #------------------------------------------------------------------------
  def clear_movement_data
    @positions[:target] = @positions[:origin].clone
  end
  #------------------------------------------------------------------------
  def moving?
    @positions[:target][:x] != @positions[:current][:x] ||
    @positions[:target][:y] != @positions[:current][:y]
  end
  #-----------------------------------------------------------------------------
  # Update Position - Updated to offset large unit placement
  #-----------------------------------------------------------------------------
  alias upd_pos update_position
  def update_position
    oldx,oldy = self.x, self.y #save current pos
    
    upd_pos #updates the currrent position based on screen_x/screen_y
    update_mini_base_placement #override starting position base
    update_movement
    
    offset_large_unit
    move_animation(self.x - oldx, self.y - oldy) #update animations to new pos
  end
  
  def move_animation(x,y)
    #override method to do nothing as mini battle seems to really mess this up
  end
  #------------------------------------------------------------------------
  def update_mini_base_placement
    if bat != nil && @pos != nil
      self.x = @pos.x
      self.y = @pos.y
    end
  end
  #------------------------------------------------------------------------
  def update_movement
    if moving?
      tx_dist = @positions[:target][:x] - @positions[:current][:x]
      ty_dist = @positions[:target][:y] - @positions[:current][:y]
      time = @positions[:target][:time]
      if time == 0
        @positions[:current][:x] = @positions[:target][:x]
        @positions[:current][:y] = @positions[:target][:y]
      else
        move_x = tx_dist / @positions[:target][:time]
        move_y = ty_dist / @positions[:target][:time]
      
        @positions[:current][:x] += move_x
        @positions[:current][:y] += move_y
        @positions[:target][:time] -= 1
      end    
    end
  end
  #--------------------------------------------------------------------------
  # Update Action Movement
  #--------------------------------------------------------------------------
  def update_action_movement
    update_mini_base_placement
    
    self.x += @positions[:current][:x]
    self.y += @positions[:current][:y] - action_jump_height
  end
  #--------------------------------------------------------------------------
  # Returns the current jump height that should be returned for the current jump
  #--------------------------------------------------------------------------
  def action_jump_height
    if (@positions[:jumppeak] > 0)      
      return (@positions[:jumppeak] * @positions[:jumppeak] - (@positions[:target][:time] - @positions[:jumppeak]).abs ** 2) / 2
    end
    return 0
  end

  alias disp_gtbs_bat dispose
  def dispose
    disp_gtbs_bat
    #@weapon.dispose
    if (@shadow != nil)
      @shadow.dispose
      @shadow = nil
    end
  end
end
