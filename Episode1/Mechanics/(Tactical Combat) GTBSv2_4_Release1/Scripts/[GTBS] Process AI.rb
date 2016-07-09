class Scene_Battle_TBS
  #==========================================================
  # Process AI Action
  #==========================================================
  def update_ai_unit
    return if @active_battler.moving?
    return unless battler_movable?
    clear_tr_sprites
    action = @active_battler.current_action
    
    if action == nil
      file = File.open("./gtbsDebugData.rvdata2", "wb")
      Marshal.dump(tactics_all, file);
      Marshal.dump(@active_battler, file);
      Marshal.dump($data_skills, file);
      Marshal.dump($data_weapons, file);
      Marshal.dump($data_enemies, file);
      Marshal.dump($game_map, file);
      Marshal.dump($game_system, file);
      Marshal.dump(SceneManager, file);
      Marshal.dump(BattleManager, file);
      file.close();
      
      errMsg = "There was an error determining action for the current battler: " + 
      "#{@active_battler.name} " + "please report this error to GubiD with a demo" + 
      "showing the error.  Especially if it duplicates often.\n\nIf you cannot " +
      "duplicate regularly.  Gather the gtbsDebugData.rvdata2 file from your project " +
      "and send that instead."
      print errMsg 
      exit_ai_processing
      return
    end
    
    debug_ai_unit_info = false #true/false
    if debug_ai_unit_info
      op_names = ""
      for op in @active_battler.opponents
        op_names += op.name + ", "
      end
      friend_names = ""
      for fr in @active_battler.friends
        friend_names += fr.name + ", "
      end
      print "Action info: \n
      Excuting action of type: #{action.tactic}\n
      target_position: #{action.position}\n
      move_pos: #{action.move_pos}, actual pos: #{@active_battler.pos}\n
      before_move=#{action.before_move}\n
      action=#{action}\n
      actor has moved = #{@active_battler.moved?}\n
      actor has acted = #{@active_battler.perfaction?}\n
      action_tactic = #{action.tactic}\n,
      possible targets: #{op_names}\n
      friends: #{friend_names}\n\n"
    end
    
    #---------------------------------------------------------------------
    #  If Captured in middle of action, abort
    #---------------------------------------------------------------------
    #  If the battler has been hidden, they are captured or dead
    #---------------------------------------------------------------------
    if @active_battler.hidden? || @active_battler.death_state?
      exit_ai_processing
      return
    end
    
    #---------------------------------------------------------------------
    # Retreat Method
    if !@active_battler.moved? and action.tactic == 3
      if @active_battler.can_teleport?
        @move_positions = @active_battler.set_teleport_positions
      else
        @route, cost  = @active_battler.calc_pos_move
        @move_positions = @route.keys
      end
      get_retreat_pos_rating
      process_move
      
    #---------------------------------------------------------------------
    # Process Move
    elsif !@active_battler.moved? and action.move_pos != @active_battler.pos
      process_move
      
    #---------------------------------------------------------------------
    # Process Skill
    elsif  !@active_battler.perfaction? and action.tactic == 2
      process_skill
      #take action before move? set for pos retreat after act
      action.tactic = 3
      
    #---------------------------------------------------------------------
    # Process Attack
    elsif  !@active_battler.perfaction? and action.tactic == 1
      #process attack if not an approach 
      process_attack unless @active_battler.current_action.position.empty?
      #take action before move? set for pos retreat after act
      action.tactic = 3
    
    #---------------------------------------------------------------------
    # Exit AI
    #---------------------------------------------------------------------
    else
      exit_ai_processing
    end
  end
  
  #----------------------------------------------------------------------------
  # Determines if the battler is capable of taking their turn
  #----------------------------------------------------------------------------
  def battler_movable?
    #if battler is paralyzed or sleeping then end turn.
    if @active_battler.paralyzed? or @active_battler.sleeping?
      #@active_battler.slip_damage_effect
      @active_battler.has_doom?
      @active_battler.clear_tbs_actions
      deactivate_battler
      if !@ATB_Active
        if @turn == Turn_Player
          next_actor
        else
          next_enemy
        end
      end
      return false
    end
    return true
  end
  
  #----------------------------------------------------------------------------
  # Perform attack that was determined previously by AI
  #----------------------------------------------------------------------------
  def process_attack
    @cursor.moveto( @active_battler.current_action.position) 
    @cursor.range = draw_ranges(@active_battler, 7) ;   update_target_cursor
    @targets = get_targets
    @active_battler.perf_action = true
    process_action 
  end
  
  #----------------------------------------------------------------------------
  # Performs the skill action that was determined previously, by AI
  #----------------------------------------------------------------------------
  def process_skill
    action = @active_battler.current_action
    @spell = @active_battler.current_action.item
  
    @wait_count = 5
    @cursor.moveto(action.position)
    @cursor.range = draw_ranges(@active_battler, 5) ;    update_target_cursor
    
    if @ATB_Active and GTBS::skill_wait(@spell.id)[0] > 0
      setup_skill_wait
    else
      @active_battler.skill_cast = nil
      #@active_battler.mp -= @active_battler.calc_mp_cost(@spell) 
      @active_battler.use_item(@spell)
      @active_battler.count_skill_usage(@spell)
      @targets = get_targets
      @active_battler.current_action.set_skill(@spell.id)
      #@animation1 = 0 #@active_battler.animation1
      #@animation2 = [@spell.animation_id]
      process_action
    end
  end
  
  #----------------------------------------------------------------------------
  # Performs the move action that was determined previously, by AI
  #----------------------------------------------------------------------------
  def process_move
    @route, cost = @active_battler.calc_pos_move
    @move_positions = @route.keys
    unless @active_battler.hide_move?
      @spriteset.draw_range(@move_positions, 2)
    end
    move_pos = @active_battler.current_action.move_pos
    @cursor.moveto(move_pos)
    @active_battler.run_route(@route[move_pos])
    @active_battler.moved = true 
    apply_move_cost(cost[move_pos] || 0)
  end
  #----------------------------------------------------------------------------
  # Apply Move Cost
  #----------------------------------------------------------------------------
  def apply_move_cost(cost)
    c = cost * GTBS::REQUIRED_TP_FOR_MOVE
    @active_battler.apply_move_cost(c)
  end
  #----------------------------------------------------------------------------
  # Exit AI Processing - Performs complete checks and resets the battler info
  #----------------------------------------------------------------------------
  def exit_ai_processing
    @active_battler.face_closest_enemy
    @active_battler.set_wait 
    deactivate_battler
    if !@ATB_Active
      if @turn == Turn_Enemy
        next_enemy
      else
        next_actor
      end
    end
  end
end