class Scene_Battle_TBS
  #============================================================= 
  # update_AI 
  # get_move_positions_from_route(battler, route)
  # find_approach_move(move_positions)
  # find_move_position(move, move_positions, routes)
  # determine_tactic
  # rate_skill_position(i, battler, line, position, pos, max, min, high_rate)
  # rate_attack_position(i, bow, pos, battler, target, high_rate, tpos)
  # get_attack_targets(action)
  # determine_targets(action, positions, field)
  # set_ai_wait_direction
  # get_retreat_pos_rating
  # rate_retreat(rating, pos, away) 
  # process_skill
  #=============================================================

  #-------------------------------------------------------------------------
  # Old AI Process
  #-------------------------------------------------------------------------
  # Update_AI - This process determines the best action possible for the enemy to make for available skill/move
  #        This will check in order the following and guage response for reachable battlers
  #      -determines team (if automatted character or enemy)
  #      -if skills include healing spells/items and fellow battler hp 200 or greater
  #         -if oponent group undead and skills are heal, or raise - weakest group
  #         -searches for largest group of battlers to heal/attack, even if not self.
  #         -find move to fathest away position (Not into oponent group) to still use skill
  #      -if attack spells power > attack power
  #         -weakest oponent in reachable oponents group targeted(This will NOT check for elemental properties)
  #         -find move to fathest away position (Not into oponent group) to still use skill
  #      -if attack power > attack spell power or no attack spells
  #         -search for weakest oponent in range
  #         -if long range
  #            -find position farthest away where attack can still occur
  #               if battler back is exposed, attack there, otherwise sides, or front.
  #         -else
  #            -find position to back of battler
  #               -if occupied? 
  #                  check sides
  #               -else front
  #-------------------------------------------------------------------------
  # New AI Process in order - 
  #-------------------------------------------------------------------------
  # 1. Determine moveable positions
  # 2. For each skill/action available
    # a. Define all attackable locations/targets
    # b. Locate best casting/use position to cause/heal the most
    # c. Locate best movement position to deliver item B.
    # d. Store the action rating that is based on db skill rating and affected targets
  # 3. Determine best action using the ratings stored in item 2d for each action
  # 4. Store the action information in @active_battler.current_action for use by later tbs_phase
  #-------------------------------------------------------------------------
  def update_AI(forcing)
    @cursor.moveto(@active_battler)
    @thinking = Sprite_Thinking.new(@active_battler)
    if @active_battler.state?(GTBS::CONFUSE_ID) && !forcing
      if @active_battler.moved?
        move_positions = [@active_battler.pos]
      else
        move_pos_data, cost = @active_battler.calc_pos_move
        move_positions = move_pos_data.keys
      end
      confused_battler_action(move_positions) 
    #If not confused, normal ai
    else      
      if @active_battler.moved?
        move_positions = [@active_battler.pos]
        move_cost = { @active_battler.pos => 0 }
      else
        move_positions, move_cost = @active_battler.calc_pos_move
        move_positions = move_positions.keys
      end
      if (forcing)
        #TODO: Finish force actions
        @active_battler.make_tbs_action(move_positions, move_cost, false, true)
      else  
        @active_battler.make_tbs_action(move_positions, move_cost)
      end
    end
    if !@active_battler.current_action.nil?
      @active_battler.current_action.determine_tactic
    end
    @cursor.moveto(@active_battler)
    while @thinking.update
      update_basic
    end
    @thinking.dispose
    @cursor.mode = nil
  end
  
  #-----------------------------------------------------------------------------------------
  #* update_thinking
  # is used to iterate an array while ai_update to not freeze screen
  #----------------------------------------------------------------------------------------- 
  def update_thinking
    @thinking.update
    update_basic
  end
  
  #----------------------------------------------------------------------------------------
  #*Determine a random action/move for a confused battler
  #----------------------------------------------------------------------------------------
  def confused_battler_action(move_positions)
    @active_battler.make_tbs_confused_action(move_positions)
    @active_battler.current_action.determine_tactic
  end
  
  #----------------------------------------------------------------------------
  # Detemine of the available move positions, which is the best 'retreat' position
  #----------------------------------------------------------------------------
  def get_retreat_pos_rating
    #pos, rate, greatest_min, farthest, count
    rating = [@active_battler.pos, 1, 0, 0, 0] 
    away = @active_battler.opponents
    for pos in @move_positions
      rating = rate_retreat(rating, pos, away)
    end
    @active_battler.current_action.move_pos = rating[0]
  end
  
  #----------------------------------------------------------------------------
  # Portion of retreat_pos_rating method, makes code easier to read and understand
  #----------------------------------------------------------------------------
  def rate_retreat(rating, pos, away)
   battler = @active_battler 
    # Method to adjust rating based on enemy concentration in area
    farthest = 0
    greatest_min = 999
    count = 0                     #count viewable enemies
    for enemy in battler.opponents
      dist = (enemy.x - pos[0]).abs + (enemy.y - pos[1]).abs
      if dist <= battler.view_range #in viewable range
        count += 1
        if dist < greatest_min
          greatest_min = dist
        end
        if dist > farthest
          farthest = dist
        end
      end
    end
    rate = 1
    #high_rate = [0-PosIndex,1-Rating,2-minDist,3-maxDist,4-EnCount]
    if greatest_min >= rating[2]
      rate += 30
    end
    if farthest >= rating[3]
      rate += 30
    end
    if count <= rating[4]
      rate += 25
    end
    
    #if skill to be used
    if battler.current_action.skill?
      #get field range
      field = battler.skill_range(battler.current_action.item.id)[1]
      v_range_aoe = battler.skill_range(battler.current_action.item.id)[6]
      if battler.current_action.targets != nil and field > 0 and
        battler.current_action.targets.include?(battler)  and 
        battler.current_action.targets.size > 1 and
        HEAL_SCOPES.include?(battler.current_action.item.scope) 
        act_pos = battler.current_action.position
        #if above criteria met.. determine if current POS is included in field range. 
        field_pos = @cursor.calculate_aoe(field,0, act_pos[0], act_pos[1], v_range_aoe)
        if field_pos.include?(pos)
          #up rating to increase chance that this position will be chosen because 
          #you will get healed
          rate += 50 
        end
      end
    end
    if rate >= rating[1] and ( farthest > rating[3] or (farthest == rating[3] and rand(2) == 0) ) 
      rating = [pos, rate, greatest_min, farthest, count]  
    end 
    return rating
  end
end