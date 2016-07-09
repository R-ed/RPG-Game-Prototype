class Game_Battler < Game_BattlerBase
  #-----------------------------------------------------------------------------
  # Ensure passed animation is valid.  If not, set 0.  Otherwise set value. 
  #-----------------------------------------------------------------------------
  def animation_id=(value)
    @animation_id = value.nil? ? 0 : value
    return @animation_id
  end
  #-----------------------------------------------------------------------------
  # Clear TBS Pos - Made to resolve auto advance placement bug by clearing pos
  #-----------------------------------------------------------------------------
  def clear_tbs_pos
    moveto(0,0)
    set_direction(2)
    on_turn_end
  end
  #-----------------------------------------------------------------------------
  # Get Possible Actions - Returns a list of possible actions the actor/enemy can take
  #-----------------------------------------------------------------------------
  def get_possible_actions
    if actor?
      avail_actions = []
      for skill in usable_skills 
        add_action(skill, avail_actions)
      end
      add_action(attack_skill_id, avail_actions)
      return avail_actions
    else # enemy
      return enemy.actions
    end
  end
  #-----------------------------------------------------------------------------
  # Add Attack Action - for current battler to array
  #-----------------------------------------------------------------------------
  def add_action(item, action_list)
    action = RPG::Enemy::Action.new
    if item.is_a?(RPG::BaseItem) #is item/skill
      action.skill_id = item.id
    else #is numeric
      action.skill_id = item
    end
    action.rating = 5
    action_list << action
  end
  #-----------------------------------------------------------------------------
  # Get Wander Position
  # Returns the position in which this battler is going to wander to.
  # Never more than 1 tile away from current position
  #-----------------------------------------------------------------------------
  def get_wander_position(sx,sy)
    dir = [2,4,6,8].random
    x = $game_map.round_x_with_direction(sx, dir)
    y = $game_map.round_y_with_direction(sy, dir)
    if passable?(x,y,0) and GTBS::ALLOW_AI_WANDER and !moved? and allow_wander
      return x, y
    else
      return sx, sy
    end
  end
  #-----------------------------------------------------------------------------
  # Make TBS Confused Action
  #-----------------------------------------------------------------------------
  def make_tbs_confused_action(move_positions)
    clear_tbs_actions
    current_action.move_pos = self.pos
    return unless movable?
    available_actions = []
    for action in get_possible_actions #usable is already figured out
      next unless tbs_conditions_met?(action)
      if action.skill?(self)
        next unless skill_can_use?($data_skills[action.skill_id])
      end
      available_actions << action
    end
    
    #select random action
    action = available_actions[rand(available_actions.size)]
    
    #Set action to active
    current_action.set_skill(action.skill_id)
    
    #get skill range info
    if action.attack?(self)
      line, field = self.weapon_range[3,2]
      exclude_caster = true
      v_range_aoe = weapon_range[6]
      type = [line, field, current_action.range, exclude_caster, v_range_aoe]
    elsif action.skill?(self)
      field, line, exclude_caster = self.skill_range(action.skill_id)[1, 3]
      v_range_aoe = skill_range(action.skill_id)[6]
      type = [line, field, current_action.range, exclude_caster, v_range_aoe]
    elsif action.guard?(self)
      type = nil
    end
    current_action.assign_random_movement_and_targets(move_positions, type)
  end
  #--------------------------------------------------------------------------
  # * Create Battle Action
  #-------------------------------------------------------------------------- 
  def make_tbs_action(move_positions, move_cost, find_approach = false, forcing = false)
    sx, sy = self.pos
    clear_tbs_actions
    self.current_action.move_pos = [sx, sy] #set move position to self
    return unless movable?
    moveto(-unit_size, -unit_size) #move out of range for all attackable positions of enemies
    
    other_bat_attack = {}
    for bat in SceneManager.scene.tactics_alive
      next if $game_map.distance(self, bat) > self.view_range #need to add 'hide' logic here
      other_bat_attack[bat] =  bat.calc_pos_attack(bat.weapon_range[0], bat.weapon_range[1])
    end
    
    moveto(sx, sy) #now move back to original placement for position checking
    en_alive = opponents
    ally_alive =  friends
    
    closest_dist = closest_enemy ? $game_map.distance(closest_enemy, self) : 9999
    
    #No enemy in range
    if closest_dist > self.view_range
      clear_tbs_actions #clear any existing action
      ex, ey = get_wander_position(sx, sy)
      self.current_action.move_pos = [ex, ey] #set move position
      return unless (GTBS::IGNORE_VIEW_OUTNUMBERED and en_alive.size <= ally_alive.size)
    end
    
    available_actions = []
    rating_max = 0
    debut = Time.now
    count = 0
    array_count = []
    for action in get_possible_actions
      next unless tbs_conditions_met?(action)
      if action.attack?(self)
        line, field = self.weapon_range[3,2]
        exclude_caster = true
        v_range_aoe = weapon_range[6] # mod MGC
      elsif action.skill?(self)
        next unless skill_can_use?($data_skills[action.skill_id])
        field, line, exclude_caster = self.skill_range(action.skill_id)[1, 3]
        v_range_aoe = skill_range(action.skill_id)[6] # mod MGC
      elsif action.guard?(self)
        next #guard is automatically run at end of turn if no action was taken
      end

      tbs_action = Game_Action.new(self)
      tbs_action.rating = action.rating
      tbs_action.set_skill(action.skill_id)
      tbs_action.other_bat_attack = other_bat_attack  #Add attack ranges of other battlers
      for move_pos in move_positions
        tbs_action.move_pos = move_pos
        next if tbs_action.skill? && GTBS::REQUIRED_TP_FOR_MOVE > 0 && self.tp < (tbs_action.item.tp_cost + move_cost[move_pos] * GTBS::REQUIRED_TP_FOR_MOVE)
        act_range = tbs_action.range #get action range from move position
        tbs_action.move_pos_evaluate #eval position
        for act_pos in act_range #for attackable postion of those within range
          if Time.now - debut > 0.015
            array_count.push count
            count = 0
            if GTBS::Show_En_Think_Areas
              SceneManager.scene.spriteset.draw_range(rand(2)==0 ? act_range : move_positions, rand(7) + 1)
            end
            SceneManager.scene.update_thinking #does update_basic 
            SceneManager.scene.clear_tr_sprites
            debut = Time.now
          end
          count +=1
          tbs_action.position = act_pos
          tbs_action.rating = action.rating
          type = [line, field, act_range, exclude_caster, v_range_aoe] # mod MGC
          $tbs_cursor.moveto(act_pos)
          $tbs_cursor.target_positions = target_zone(move_pos, act_pos, type)
          tbs_action.targets = tbs_action.tbs_make_targets
          tbs_action.tbs_evaluate 
          next if tbs_action.rating == 0 or tbs_action.targets.empty?
          rating_max = [rating_max, tbs_action.rating].max
          action_to_add = tbs_action.clone
          available_actions.push action_to_add
        end
      end
    end    
    @actions.clear

    ### all available actions are set and evaluated ###
    ratings_total = 0
    rating_zero = [rating_max - 3, 0].max
    for action in available_actions
      next if action.rating <= rating_zero
      ratings_total += action.rating - rating_zero
    end
    if ratings_total == 0
      if find_approach or self.moved?
        #retreat 
        a = Game_Action.new(self)
        a.move_pos = self.pos
        self.current_action =  a
      else
        aprch_rate = 4#self.ai_tactic.force_approach ? 4 : 2
        approach_routes, approach_cost = calc_pos_move(2 * aprch_rate * base_move_range)
        #only test actions which can be done during the next turn
        approach_positions = approach_routes.keys - move_positions
        make_tbs_action(approach_positions, approach_cost, true)
        approach_pos = find_approach_move(self.current_action.move_pos, move_positions, other_bat_attack)
        a = Game_Action.new(self)
        a.set_attack
        a.move_pos = approach_pos
        self.current_action =  a
      end
      return
    end
    value = rand(ratings_total)
    for action in available_actions
      #ignore action if it is 'not recommended' by battle tactic
      next if action.rating <= rating_zero 
      if value < action.rating - rating_zero
        self.current_action = action
        self.current_action.before_move = (action.move_pos == self.pos and not self.moved?)
        return
      else
        value -= action.rating - rating_zero
      end
    end
    if self.current_action.nil? #no action could be decided
      ex, ey = get_wander_position(sx,sy) #do wander if enabled
      clear_tbs_actions #sets basic attack action
      self.current_action.move_pos = [ex, ey] #set move position to self
    end
  end
  #-------------------------------------------------------------------------
  # Find Approach Move
  #-------------------------------------------------------------------------
  # Finds the best movable position that is approaching the desired target since
  # none are currently reachable
  #-------------------------------------------------------------------------
  def find_approach_move(t_pos, move_positions, other_bat_attack)
    #calculate all positions from move_position from wher battler can reach t_pos
    sx, sy = self.pos
    result = {}
    for pos in move_positions
      moveto(*pos)
      test_move_pos, test_cost = calc_pos_move
      test_move_pos = test_move_pos.keys
      if test_move_pos.include?(t_pos)
        move_pos_value = 0
        for bat in opponents
          if other_bat_attack[bat] and ( other_bat_attack[bat] & self.positions(*pos) != [] )
            move_pos_value += 1
          end
        end
        result[pos] = move_pos_value
      end
    end
    moveto(sx, sy)
    return result.keys.min { |a, b| result[a] <=> result[b] }
  end
end
