class Scene_Battle_TBS
  #----------------------------------------------------------------------------
  # Process Constants
  #----------------------------------------------------------------------------
  Process_init = 1
  Process_step2 = 2
  Process_step3 = 3
  Process_step4 = 4
  
  #----------------------------------------------------------------------------
  # Process Actions (Attack/Skill/Item)
  #----------------------------------------------------------------------------
  def update_process_phase
    case @step
    when Process_init;   process_setup
    when Process_step2;  execute_summon_miss
    when Process_step3 ; execute_action
    when Process_step4 ; clean_up_process_action
    end
  end

  #--------------------------------------------------------------------
  #* setup the Process_Action_Phase
  #--------------------------------------------------------------------
  def process_action
    @windows[Menu_Actor].visible = false
    @active_battler.reset_wep_check
    @tbs_process_phase = true
    @step = Process_init
    @gained = []
    process_battle_event
    while @tbs_process_phase
      loop do
        update_basic
        @wait_count -= 1
        unless update_screen or @wait_count > 0
          break 
        end
      end
      @wait_count = 0
      update_process_phase
    end
    process_battle_event
    wait(10)
  end
  #--------------------------------------------------------------------------
  # * Wait a set amount of time
  #     duration : Wait time (number of frames)
  #     no_fast  : Fast forward disabled
  #    A method for inserting a wait during scene class update processing.
  #    As a rule, update is called once for each frame, but during battle it
  #    can be difficult to grasp the processing flow, so this method is used#
  #    as an exception.
  #--------------------------------------------------------------------------
  def wait(duration, no_fast = false)
    for i in 0...duration
      update_basic
      break if not no_fast and i >= duration / 2 and show_fast?
    end
  end
  #--------------------------------------------------------------------------
  # * Determine Fast Forward
  #--------------------------------------------------------------------------
  def show_fast?
    return (Input.press?(Input::A) or Input.press?(Input::C))
  end

   #----------------------------------------------------------
  #* process_setup
  #   setup attacker's animations
  #----------------------------------------------------------
  def process_setup
    #Turn to target location
    @active_battler.turn_to( (@targets[0] || @target || @cursor))
    @hit_count = 0
    setup_itemskill            # return @spell = nil if an item
    @step = Process_step2
  end
  #------------------------------------------------------------
  # setup for @spell or item the parameters
  # @apply_all
  # dual?
  #------------------------------------------------------------
  def setup_itemskill
    action = @active_battler.current_action
    if action.attack?
      @apply_all = nil
    end
    @spell = action.item
    if action.item? and !action.attack? and !action.guard? #skill
      if ALL_TYPES.include?(@spell.scope)
        @apply_all = true
      end 
    end
    @log_window.display_use_item(@active_battler, @spell)
  end
  #----------------------------------------------------------------------------
  # Check Projectiles - Need to create projectile?
  #----------------------------------------------------------------------------
  def check_projectiles(battler)
    return nil if battler.current_action.nil? #no action (just in case)
    if battler.current_action.attack?
      if battler.is_a?(Game_Enemy)
        data = battler
        result = GTBS.enemy_has_projectile?(battler.enemy_id)
        if result.nil?
          return nil #no projectile data
        else
          type = result;
          return [data, type] #done, return data
        end
      end
    else
      data = battler.current_action.item
    end
    
    #Examine actor data
    if data != nil
      case data
      when RPG::Weapon
        result = GTBS.weapon_has_projectile?(data.id)
        type = result if !!result
      when RPG::Skill
        result = GTBS.skill_has_projectile?(data.id)
        type = result if !!result
      else #item
      end
    end
    if !!type
      return [data, type]
    else
      return nil
    end
  end
  
  #-------------------------------------------------------------------------------------------------------------------
  #* process_action_2
  #-------------------------------------------------------------------------------------------------------------------
  def execute_summon_miss
    if @targets.empty?
      sumid = GTBS::is_summon?(@active_battler.current_action.item.id, @active_battler.actor?)
      if sumid > 0 and $game_map.passable?(@cursor.x, @cursor.y, 0)
        #Crease Miss object, but play summon animation
        @target = Anim_Miss.new(1)
        #Set character
        if @active_battler.exist?
          if @active_battler.is_a?(Game_Actor) and !@active_battler.neutral
            actor = set_character('actor', sumid, @cursor.x, @cursor.y,0,true)
          elsif @active_battler.is_a?(Game_Actor) and @active_battler.neutral
            actor = set_character('neutral', sumid, @cursor.x, @cursor.y,0,true)
          elsif @active_battler.is_a?(Game_Enemy)
            actor = set_character('enemy', sumid, @cursor.x, @cursor.y,0,true)
          end
          if actor
            @targets.push(actor)
            actor.hp = actor.mhp
            actor.mp = actor.mmp
            @gained = [actor]
          end
        end
      else
        #Play Miss Animation
        @target = Anim_Miss.new
      end 
      @target.place(@cursor.x, @cursor.y)
      @target.start_anim 
      exit_process_action
    elsif GTBS::is_summon?(@spell.id, @active_battler.actor?) > 0
      #Play Miss Animation - since a summon cannot occupy any location already occupied.
      anim = Anim_Miss.new
      anim.place(@cursor.x, @cursor.y)
      anim.start_anim
      exit_process_action
    end
    @step = Process_step3
  end
  
  #----------------------------------------------------------
  #* process_action_3
  #----------------------------------------------------------
  def execute_action
    @wait_count += 25
    if @target.is_a?(Anim_Miss) #summon or actual miss
      @step = Process_step4
    end
    reset_music
    @action = @active_battler.current_action.clone
    if GTBS::POP_DAMAGE_IND
      for target in @targets.uniq
        make_result_on_target([target])
        show_item_gold?([target])
      end
    else
      make_result_on_target(@targets)
      show_item_gold?(@targets)
    end
    @action = nil;
    fade_music
    info = []
    for target in @targets
      check_knock_back(target)
      target.perform_death
      check_exp_gained(target) if @active_battler.actor? #cue exp growth for any actor action
      if @active_bat_temp.nil? #only calculate counter if not countering...
        @counters << target.counter?(@active_battler) if !@active_battler.death_state? && @melee == true && !target.death_state?
      end
    end
    @step = Process_step4
  end
  #----------------------------------------------------------------------------
  # Reset Music - Initialize music flag
  #----------------------------------------------------------------------------
  def reset_music
    @music_changed = false
  end
  #----------------------------------------------------------------------------
  # Start_Music
  #----------------------------------------------------------------------------
  def start_music
    if @music_changed == false
      me = GTBS.side_music($game_map.map_id)
      if me.name != ""
        me.play      
        @music_changed = true
      end
    end
  end
  #----------------------------------------------------------------------------
  # Fade Music - Cause the side view called music to fade out (if it was called)
  #----------------------------------------------------------------------------
  def fade_music
    if @music_changed == true
      #RPG::ME.fade(GTBS::Side_Music_FadeOut_Time * 1000)
      Audio.me_fade(GTBS::Side_Music_FadeOut_Time * 1000) 
    end
  end
  #----------------------------------------------------------------------------
  # Use Mini For Delivery - Determines if mini scene should show
  #----------------------------------------------------------------------------
  def use_mini_for_delivery(action)
    return ((GTBS::Use_Mini_Battle == true) && !(action.guard? || action.item?))
  end
  #----------------------------------------------------------------------------
  # make_result_on_target
  #----------------------------------------------------------------------------
  def make_result_on_target(targets)
    #action = @active_battler.current_action
    return if @action.nil?
    skip_mini = false
    if targets.size > 1 || (targets.size == 1 && targets[0] == @active_battler)
      skip_mini = true if GTBS::Prevent_Group_Mini
    end
  
    if use_mini_for_delivery(@action) && !skip_mini
      init_mini_scene(@active_battler, targets[0])
      start_music
      update_mini #will transition battlers onto scene
    end
    
    #deliver attacks
    make_action_results(targets)
    
    if use_mini_for_delivery(@action) && !skip_mini
      @mini_stage = TRANSITION_MINI_OUT
      @mini = true
      update_mini
    end
  end
  #----------------------------------------------------------------------------
  # Make action results (target)
  #----------------------------------------------------------------------------
  # Delivers attack on target
  #----------------------------------------------------------------------------
  def make_action_results(targets)
    #action = @active_battler.current_action
    if (@action.attack? || @action.skill?)
      make_skill_result(targets)
    elsif @action.guard? 
      make_skill_result(targets) #cast skill on yourself
    elsif @action.item?
      if action.item_skill != nil
        @spell = @action.skill
        make_skill_result(targets)
        @item = nil
      else
        make_item_result(targets)
      end
    end
  end
  #---------------------------------------------------------------------
  #* Add experience gained 
  #---------------------------------------------------------------------
  def check_exp_gained(target)
    if GTBS::GAIN_EXP_ON_MISS or not (target.result.missed or target.result.evaded )
      @gained.push(target)
    end
  end
  #----------------------------------------------------------------------------
  # Used for skills that apply state "knock back"
  #----------------------------------------------------------------------------
  def check_knock_back(target)
    for state in target.states
      if GTBS::KNOCK_BACK_STATES.include?(state.id)
        if state.distance != 0
          perform_knock_back(target, state)
        end
        target.remove_state(state.id) 
      end
    end
  end
  #----------------------------------------------------------------------------
  # Perform Knock Back
  #----------------------------------------------------------------------------
  def perform_knock_back(target, state, override = true)
    
    count = state.distance.abs
    dir = @active_battler.direction
    if state.distance < 0
      dir = @active_battler.reverse_dir(dir)
    end
    while count > 0
      dir, dx, dy = Game_Battler::TEST_DIR.assoc(dir)
      if occupied_by?(target.x+dx,target.y+dy) == nil and 
        target.passable?(target.x,target.y, dir, override)
      then
        
        target.knock_back(dir)
      end
      loop do
        update_basic
        break if !target.moving?
      end
      count -= 1
    end
  end
  #----------------------------------------------------------
  #* process_action_4
  # process counter
  #----------------------------------------------------------
  def clean_up_process_action
    #----------------
    # Target now counters if they are set to do so
    #----------------
    @exp_gained.push([3, @active_battler, @gained]) unless @active_battler.death_state? or @gained.empty? or @active_bat_temp
    @gained = []
    @hit_count = 0
    @active_battler = @active_bat_temp if @active_bat_temp 
    @counters.compact!
    @counters.uniq!
    @counter = @counters.shift
    while not @counters.empty? and (@counter == nil or @counter.dead?)
      @counter = @counters.shift
    end
    if @counter != nil
      if !@counter.death_state?  #if counter flag is true
        @active_bat_temp = @active_battler                #save current battler info so they can be restored when complete
        @active_battler = @counter                     #return countering party of active_battler
        @active_battler.clear_tbs_actions                 #reset actions for battler
        @active_battler.current_action.set_attack           #set for physical action
        @targets = [@active_bat_temp]                   #set current battler as target
        @active_battler.current_action.position = @active_bat_temp.pos
        @active_battler.current_action.targets = @targets
        @active_battler.reset_wep_check  #reset weapon to first
        clear_tr_sprites
        @cursor.moveto(@active_bat_temp)
        @melee = false                                    #reset melee so there is no chance of counter happening over and over
        @counter = nil                                    #reset counter so it doesnt pull this again unless conditions meet.
        #set attack target animation
        #@animation2 = [@active_battler.atk_animation_id1, @active_battler.atk_animation_id2]
        @step = Process_init           #set step back to 1 so it can redo attack and animations
        return
      end
    end
    #Clears counter info when ready
    if @active_bat_temp != nil 
      @active_battler = @active_bat_temp
      @active_bat_temp = nil
    end
    cleanup_mini
    @counters.clear
    @turnable = nil
    @targets.clear
    @melee = true
    @apply_all = nil
    @wait_count += 25
    exit_process_action
  end
  #----------------------------------------------------------
  #* process_action_5
  #----------------------------------------------------------
  def exit_process_action
    @log_window.clear
    @log_window.wait
    if @windows[Menu_Actor].active                             #if return to battler phase, reset windows to open
      @windows[Menu_Actor].setup(@active_battler)
    end
    @active_battler.on_action_end
    if @using_skill or @active_battler.death_state?
      @using_skill = false
      deactivate_battler
    end
    @cursor.mode = nil
    #if active battler died during transaction, reset wait functions and proceed with battle.
    clear_tr_sprites
    @tbs_process_phase = false
  end
  #-------------------------------------------------------------------------
  # Make_Skill_Result - Makes item result for designated targets
  #-------------------------------------------------------------------------
  def make_skill_result(targets)
    @action_targets = targets.clone
    spell = (@spell == nil ? @action.item : @spell)
    if @action.attack?
      num = 1 + (@action.attack? ? @active_battler.atk_times_add.to_i : 0) rescue num = 1
      num *= spell.repeats
    else
      num = spell.repeats
    end
    #Revive character technique
    if spell.for_dead_friend?
      target = targets[0] #this may come back to haunt me later...
      target.moveto(@cursor.x, @cursor.y) 
      target.appear
      @spriteset.update
      
      if (GTBS::REMOVE_DEAD == 2 && target.is_a?(Game_Actor))
        create_character(@spriteset.viewport1, target)
      elsif (GTBS::REMOVE_DEAD > 0 && target.is_a?(Game_Enemy))
        create_character(@spriteset.viewport1, target)
      end
      #return #need to not return here as this causes the action to not 
      #be carried out
    end
    #-----------------------------------------
    
    actions_used = 0
    data, anim = get_action_anime_data(spell, @active_battler)
    #anim_index = 0
    
    dmg_type = ["damage", "target", []]
    
    #ensure all dmg's are dealt
    dmg_deal = (data.select {|dat| dat == dmg_type }).size
    while dmg_deal < num
      data << dmg_type
      dmg_deal += 1
    end
    data << ["cleanup",nil,[]]
    
    while data.size > 0
      act = data.shift
      
      parse_action_data(act, spell)
      
      while should_wait?
        if @mini_showing 
          update_mini_basic 
          @movement_wait = false if !@spriteset.movement?
          @animation_wait = false if !waiting_for_mini_animations?
          @effect_wait = false if !waiting_for_mini_effects?
        else
          update_basic
          @movement_wait = false if !@spriteset.movement?
          @animation_wait = false if !@spriteset.animation?
          @effect_wait = false if !@spriteset.effect?
        end
      end
    end  
  end
  
  #-------------------------------------------------------------------------
  # Parse the input action array into actionable objects
  #-------------------------------------------------------------------------
  def parse_action_data(act, spell)
    case act[0]
    when /^move/i
      action_movement(act)
    when /^create/i
      action_create(act)
    when /^damage/i
      action_damage(act, spell)
    when /^screen/i
      action_screen(act)
    when /^delete/i
      action_delete(act)
    when /^animation/i
      action_animation(act, spell)
    when /^message/i
      action_message(act, spell)
    when /^movie|cine|cinema/i
      action_movie(act)
    when /^wait/i
      action_wait(act)
    when /^cleanup/i
      action_cleanup
    end
  end
  #-------------------------------------------------------------------------
  # Action Cleanup - Sets wait flags for all interaction types
  #-------------------------------------------------------------------------
  def action_cleanup
    SceneManager.scene.instance_eval("@windows[Win_Help].hide")
    SceneManager.scene.instance_eval("@movement_wait = true")
    SceneManager.scene.instance_eval("@animation_wait = true")
    SceneManager.scene.instance_eval("@effect_wait = true")
  end
  
  #-------------------------------------------------------------------------
  # Deliver Damage Value
  #-------------------------------------------------------------------------
  def deal_dmg(target, battler, spell)
    target.item_apply(battler, spell) #deal damage
    @log_window.display_action_results(target, spell)
  end
      
  #-------------------------------------------------------------------------
  # Make_Item_Result - Makes item result for designated targets
  #-------------------------------------------------------------------------
  def make_item_result(targets, battler = @active_battler)
    item = $data_items[battler.current_action.item.id]
    if item.for_dead_friend?
      for target in targets
        target.moveto(@cursor.x, @cursor.y) if GTBS::REMOVE_DEAD == 2
        target.animation_id = item.animation_id
        target.appear
      end
      @spriteset.update 
    end
    args = [@active_battler, item]
    for target in targets
      target.item_apply(battler, item)
    end
    # Use_Item apply takes care of common event triggering stuff. 
    #return target.damage
  end
  
  #----------------------------------------------------------------------------
  # Set Character - Allows the placement of a character on the map
  #----------------------------------------------------------------------------
  def set_character(type, id, x, y, anim = 0, summon = false)
    if @mini_showing
      @set_character_later << [type, id, x, y, anim, summon]
      return
    end
    case type
    when Battler_Actor
      if summon
        actor = $game_party.add_summon(id)
      else
        check_actor = $game_actors[id]
        if !$game_party.all_members.include?(check_actor)
          $game_party.add_actor(id)
          actor = $game_actors[id]
        end
      end
      return nil unless actor
      if GTBS::ACTOR_SUMMONS.include?(id)
        if !GTBS::CONTROLABLE_SUMMONS.include?(id)
          actor.neutral = true
        else
          actor.neutral = false
        end
        if GTBS::DOOM_SUMMONS
          args = GTBS::DOOM_ID
          actor.add_state(*args) #add doom to them to auto remove from battle
        end
      elsif summon and !GTBS::ACTOR_SUMMONS.include?(id)
        return # do not summon if actor is not marked as summon
        # prevents actor
      end
    #Enemy entrance
    when Battler_Enemy
      if summon
        actor = $game_troop.add_summon(id) 
      else
        actor = $game_troop.add_member(id)
      end
      return nil unless actor
    when Battler_Neutral
      actor = $game_party.add_neutral(id)
      return nil unless actor
      actor.neutral = true
    end
    actor.gtbs_entrance(x,y)
    s = create_character(@spriteset.viewport1, actor)
    s.update
    actor.animation_id = anim
    actor.adjust_special_states
    return actor
  end
  #--------------------------------------------------------------------------
  # * Battle Event Processing
  #--------------------------------------------------------------------------
  def process_battle_event
    loop do
      return if judge_win_loss
      return if scene_changing?
      $game_troop.interpreter.update
      $game_troop.setup_battle_event
      wait_for_message
      process_action if BattleManager.action_forced?
      return unless $game_troop.interpreter.running?
      update_basic
    end
  end
  #--------------------------------------------------------------------------
  # Process Forced Action
  #--------------------------------------------------------------------------
  def process_forced_action
    if BattleManager.action_forced? && @active_battler.nil?
      set_active_battler(BattleManager.action_forced_battler, true)
      BattleManager.clear_action_force
    end
  end
end