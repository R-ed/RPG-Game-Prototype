class Scene_Battle_TBS
  TRANSITION_MINI_IN = 0
  MINI_DROP_CONTROL = 1
  TRANSITION_MINI_OUT= 2
  FINISH_MINI = 3
  
  #-----------------------------------------------------------------------------
  # Setup Mini Scene Variables
  #-----------------------------------------------------------------------------
  # Prepares the mini scene variables so that they dont have to be initialized
  # later to save load time for mini scene. 
  #-----------------------------------------------------------------------------
  def setup_mini_scene_variables
    @back_transition_default = 30
    @mini = false
    @mini_showing = false
    create_mini_viewports
    create_mini_battlers
  end
  #----------------------------------------------------------------------------
  def init_mini_scene(attacker, defender)
    @mini = true
    @mini_stage = TRANSITION_MINI_IN
    @mini_step = 0
    prepare_next_mini(attacker, defender)
    @mini_showing = true
  end
  def prepare_next_mini(attacker, defender)
    reset_transition_timer
    spriteset_mode_mini(true)
    set_mini_battlers(attacker, defender)
    create_mini_backdrops(attacker, defender)
  end
  def reset_transition_timer
    @back_transition = @back_transition_default
  end
  def spriteset_mode_mini(bool)
    @spriteset.in_mini = bool
  end
  def set_mini_battlers(attacker, defender)
    @right_battler.mirror = false
    @left_battler.mirror = false
    @right_battler.bat = attacker
    @left_battler.bat = defender
  end
  #----------------------------------------------------------------------------
  def create_mini_viewports
    @mini_viewport1 = Viewport.new(0,0,Graphics.width, Graphics.height)
    @mini_viewport2 = Viewport.new(0,0,Graphics.width, Graphics.height)
    @mini_viewport2.z = 1000
  end
  #----------------------------------------------------------------------------
  def create_mini_backdrops(attacker, defender)
    @backdrops = {} 
    get_backdrop_from_target(defender)
    get_backdrop_from_target(attacker)
  end
  #----------------------------------------------------------------------------
  def get_backdrop_from_target(target)
    name = $game_map.get_backdrop_image(target.pos)
    @backdrops[target] = Sprite.new(@mini_viewport1)
    @backdrops[target].bitmap = Cache.picture(name)
    @backdrops[target].visible = false
  end
  #----------------------------------------------------------------------------
  def create_mini_battlers #sprites
    @left_battler    = Sprite_Battler_MiniGTBS.new(@mini_viewport2, nil)
    @right_battler   = Sprite_Battler_MiniGTBS.new(@mini_viewport2, nil)
    @left_battler.z  = 1000
    @right_battler.z = 1000
    
    @left_battler.pos  = POS.new(2*@mini_viewport1.rect.width/5, @mini_viewport1.rect.height/2)
    @right_battler.pos = POS.new(4*@mini_viewport1.rect.width/5, @mini_viewport1.rect.height/2)
    @left_battler.visible  = false
    @right_battler.visible = false
  end
  #----------------------------------------------------------------------------
  def update_mini
    while @mini == true
      update_mini_basic
      update_mini_scene
    end
  end
  #----------------------------------------------------------------------------
  def update_mini_basic
    Graphics.update
    Input.update
    update_mini_windows
    $game_troop.update
    @spriteset.update
  end
  #----------------------------------------------------------------------------
  def update_mini_windows
    #@mini_cmd.update
    @windows[Win_Help].update
    update_mini_sprites
  end
  #----------------------------------------------------------------------------
  def update_mini_sprites
    @left_battler.update if @left_battler != nil
    @right_battler.update if @right_battler != nil
    @left_back.update if @left_back != nil
    @right_back.update if @right_back != nil
    $game_troop.update #update screen
    @mini_viewport1.update
    @mini_viewport2.update
  end
  #----------------------------------------------------------------------------
  def update_mini_scene
    case @mini_stage
    when TRANSITION_MINI_IN
      case @mini_step
      when 0
        reset_transition_timer
        transition_start_placement_mini
        @mini_step += 1
        return
      when 1
        return if wait_for_background_transition
        @mini_step = 0
        @mini_stage += 1
        return
      end
    when MINI_DROP_CONTROL
      @mini = false #return control to over system
    when TRANSITION_MINI_OUT
      case @mini_step
      when 0
        reset_transition_timer
        @mini_step += 1
        return
      when 1
        return if wait_for_background_transition(true) == true
        @mini_step = 0
        @mini_stage = MINI_DROP_CONTROL
        return
      end
    when FINISH_MINI
      cleanup_mini
      @mini = false
    end
  end

  #----------------------------------------------------------------------------
  # Transition Placement Mini - Place Backdrop and Mini Battler on the field
  # and ready for transition INTO scene. 
  #----------------------------------------------------------------------------
  def transition_start_placement_mini
    # Place Left "Defender"
    assign_backdrop(0, @left_battler)
    # Place Left "Attacker"
    assign_backdrop(1, @right_battler)
  end
  #----------------------------------------------------------------------------
  # Assign Backdrop - Sets the sprite image for the backdrop and places it ready
  # for transition. 
  #----------------------------------------------------------------------------
  def assign_backdrop(side, target_sprite)
    sprite = @backdrops[target_sprite.bat]
    if sprite
      center_x = Graphics.width/2
      center_y = Graphics.height/2
      sprite.x = center_x - (side == 0 ? sprite.bitmap.width : 0)
      sprite.y = center_y-(sprite.bitmap.height/2)
      sprite.visible = true
      if side == 0  #left
        sprite.color.set(0,0,255,20) 
        @left_back = sprite
        @left_back.x -= @back_transition * 10
        place_mini_battler_left(target_sprite, sprite.width/2)
      else
        sprite.color.set(255,0,0,20)
        @right_back = sprite
        @right_back.x += @back_transition * 10
        place_mini_battler_right(target_sprite, sprite.width/2)
      end
    end
  end
  #----------------------------------------------------------------------------
  # Place Mini Left - Sets the LEFT battler in transition position
  #----------------------------------------------------------------------------
  def place_mini_battler_left(sprite, back_center_x)
    center_x = Graphics.width/2
    center_y = Graphics.height/2
    sprite.pos = POS.new((center_x-back_center_x)-(@back_transition * 20), center_y)
    sprite.force_direction(6) #face right
    sprite.visible = true
  end
  #----------------------------------------------------------------------------
  # Place Mini Right - Sets the RIGHT battler in transition position
  #----------------------------------------------------------------------------
  def place_mini_battler_right(sprite, back_center_x)
    center_x = Graphics.width/2
    center_y = Graphics.height/2
    sprite.pos = POS.new((center_x+back_center_x)+(@back_transition * 20), center_y)
    sprite.force_direction(4) #face left
    sprite.visible = true
  end
  #----------------------------------------------------------------------------
  # Wait for Background Transition - Transitions backdrop and battler onto scene
  #  or off if 'reverse'
  #----------------------------------------------------------------------------
  def wait_for_background_transition(reverse = false)
    move_left = reverse ? [@left_back, @left_battler.pos] : [@right_back, @right_battler.pos]
    move_right = reverse ? [@right_back, @right_battler.pos] : [@left_back, @left_battler.pos]
    move_left.each  {|obj| obj.x -= (obj.is_a?(POS) ? 20 : 10)}
    move_right.each {|obj| obj.x += (obj.is_a?(POS) ? 20 : 10)}
    if ((@back_transition -= 1) > 0)
      return true
    else
      return false
    end
  end
  #----------------------------------------------------------------------------
  # Waiting for mini Animations
  #----------------------------------------------------------------------------
  def waiting_for_mini_animations?
    return true if @left_battler.animation? 
    return true if @right_battler.animation? 
    return false
  end
  def waiting_for_mini_effects?
    return true if @left_battler.effect?
    return true if @right_battler.effect?
    return false
  end
  #----------------------------------------------------------------------------
  # CleanUp Mini - This method backs out of Mini scene without dispoing everything
  #----------------------------------------------------------------------------
  def cleanup_mini
    #set wait count #clean up routines#
    #@wait_count = 60
    @mini_showing = false
    #if not refreshed, battlers are invisible
    @spriteset.in_mini = false #done with mini scene
    @spriteset.refresh_battlers #refresh to ensure directions are correct
    @spriteset.update
  end
  #----------------------------------------------------------------------------
  # Dispose Mini Viewports
  #----------------------------------------------------------------------------
  def dispose_mini_viewports
    @mini_viewport1.dispose
    @mini_viewport2.dispose
    @mini_viewport1 = nil
    @mini_viewport2 = nil
  end
  #----------------------------------------------------------------------------
  # Dispose Mini Battlers
  #----------------------------------------------------------------------------
  def dispose_mini_battlers
    @left_battler.dispose
    @right_battler.dispose
    @left_back.dispose
    @right_back.dispose
    
    @left_battler = nil
    @right_battler = nil
    @left_back = nil
    @right_back = nil
  end
  #----------------------------------------------------------------------------
  # Dispose Mini Backdrops
  #----------------------------------------------------------------------------
  def dispose_mini_backs
    for target in @backdrops.keys
      drop = @backdrops[target]
      drop.dispose
      target.clear_temp_dir
    end
    @backdrops = nil
  end
end
