class Game_Action
  attr_accessor :other_bat_attack
  #========================================
  #
  #========================================
  #------------------------------------------------------------------------
  #* rate action regarding the battler's strategy
  #------------------------------------------------------------------------
  def tbs_tactic_rate
    tactic = GTBS_Tactics::All_AI_Tactics[  (battler.ai_tactic or 'default') ]
    value = 0
    if @effect_preview.keys.size == 0
      self.rating = value
      return
    end
    
    for target, effect in @effect_preview
      hit_chance, dmg_eval, mp, rate_states, rate_counter = effect
      damage, ref, ally = dmg_eval
      damage_frac = damage / ref.to_f
      dmg_rate = (mp ? tactic.mp_damage : tactic.hp_damage) 
      target_rate = [0.01, ((subject.view_range.to_f/$game_map.distance(subject, target)) * target.tgr)].max
      
      if ally
        pained_ally = (target.hp / target.mhp.to_f < 0.33) ? 1.0 + tactic.team_rate : 1.0
        death_unlike = (damage_frac > 0.83) ? [damage_frac*(1.0+tactic.team_rate), 1.0].max : 1.0
        dmg_rate = tactic.hp_heal if damage < 0
        value -= (hit_chance / 100.0) * damage_frac * dmg_rate * death_unlike * pained_ally * target_rate
        value += rate_states * tactic.state * tactic.team_rate * pained_ally * target_rate
      else
        n_ally = 1.0
        #if tactic team enabled, add value if target can be attacked by other allies
        if tactic.team
          for bat in subject.friends
            if @other_bat_attack[bat] & target.positions != []
              n_ally += tactic.team_rate
            end
          end
        end
        if tactic.force_approach
          value += 10
        end
        
        #check 83% because variance add 20%
        death_like = (damage_frac > 0.83) ? [damage_frac*tactic.death_like, 1.0].max : 1.0
        value += n_ally * (hit_chance / 100.0  * damage / ref.to_f * dmg_rate) * death_like * target_rate
        value += rate_states * tactic.state * target_rate
        #don't care of counter if unit will die
        rate_counter *= (1.0 - damage_frac) / 0.17 if (damage_frac > 0.83)
      end
      value -= rate_counter * tactic.counter
      value -= tactic.mp_save * battler.skill_mp_cost(item) / [battler.mmp.to_f, 1.0].max if skill?
    end
    
    #modify rating
    if value > 0
      unless tactic.team 
        value += (@move_pos == battler.pos) ? tactic.position : -tactic.position / 4 * rate_pos_safe
      end
      value = (value * ai_rating)
      self.rating += (value * tactic.predictable / 100).to_i
    else
      self.rating = 0
    end
  end
  #---------------------------------------------------------------
  # AI Rating - Increases likelyhood of skill casted based on AI liking of this
  # skill.  (Determine by SKILL not particualr AI)
  #---------------------------------------------------------------
  def ai_rating
    if (skill?)
      GTBS.get_skill_rating(self.item.id)
    else
      return 1
    end
  end
  #---------------------------------------------------------------
  #* Check if the position is safe
  #---------------------------------------------------------------
  def rate_pos_safe
    unless @move_pos_value
      move_pos_evaluate
    end
    return @move_pos_value
  end
  #---------------------------------------------------------------
  # Move Position Evaluate - Will rate +1 for each enemy unit that can attack this position
  #---------------------------------------------------------------
  def move_pos_evaluate
    @move_pos_value = 0
    for bat in subject.opponents
      if @other_bat_attack[bat] and (@other_bat_attack[bat] & battler.positions(*move_pos) != [])
        @move_pos_value += 1
      end
    end
  end
  #-------------------------------------------------------------
  #* Determine action range by action type
  #-------------------------------------------------------------
  def range(pos = @move_pos) 
    if attack?
      max, min, bow, line, field, proj = battler.weapon_range
      if bow
        action_range = battler.calc_pos_bow(max, min, [pos])
      else
        action_range = battler.calc_pos_attack(max, min, [pos])
      end
    elsif skill?#skill
      max, field, line, exclude, min, v_range = battler.skill_range(item.id)
      if line
        action_range = battler.calc_pos_attack(max, min, [pos])
      else
        action_range = battler.calc_pos_spell(max, min, [pos], v_range)
      end
    elsif item?
      max, field, skill_id, v_range = battler.item_range(item.id)
      action_range = battler.calc_pos_spell(max, 0, [pos], v_range)
    else#item/guard 
      action_range = []
    end
    return action_range
  end
  #--------------------------------------------------------------------------
  # * Action Value Evaluation (for automatic battle)
  #    @value and @target_index are automatically set.
  #--------------------------------------------------------------------------
  def tbs_evaluate
    #if attack?
    #  @effect_preview = tbs_evaluate_attack
    #  @targets = @effect_preview.keys
    #elsif item? #no item use for ai controlled unit
    if item? #no item use.. 
      @effect_preview = {}
      @targets = []
    else 
      @effect_preview = tbs_evaluate_skill
      @targets = @effect_preview.keys
    end
    return if @targets.empty?
    #rate the action regarding the battler strategy
    tbs_tactic_rate 
  end
  
  #------------------------------------------------------------------------
  #* return an hash
  # effective_target => [ hit%, +/- %damage, +/- positive states, +/- negative_states]
  #------------------------------------------------------------------------
  #def tbs_evaluate_attack
  #  result = {}
  #  for target in @targets
  #    hit_chance, damage, amp, hit_states, rem_states = target.preview_attack_effect(battler)
  #    next unless hit_chance and hit_chance > 0
  #    rate_states = evaluate_states(target, hit_states, rem_states)
  #    dmg_rate = adjust_damage(target, damage, false)
  #    result[target] = [hit_chance, dmg_rate, false, rate_states, rate_counter(target)]
  #  end
  #  return result
  #end
  
  #------------------------------------------------------------------------
  #* return an hash
  # effective_target => [ hit%, +/- %damage, +/- positive states, +/- negative_states]
  #------------------------------------------------------------------------
  def tbs_evaluate_skill
    result = {}
    state_sum = 0
    ally_count = 0
    target_count = 0
    for target in @targets
      #[hit_chance, value.to_i, amp, add_states,rem_states] 
      hit, dmg, amp, hit_states,rem_states, mp = target.make_gtbs_dmg_preview_data(@subject, item)
      next unless hit and hit > 0
      rate_states = evaluate_states(target, hit_states, rem_states)
      state_sum += rate_states
      ally_count += 1 if battler.friends.include?(target)
      target_count += 1
      dmg_rate = adjust_damage(target, dmg, mp)
      result[target] = [hit, dmg_rate, mp, rate_states, rate_counter(target)]
    end
    return result
  end
  
  #---------------------------------------------------------------------------------
  # Evaluate the chance of the target to counter
  #----------------------------------------------------------------------------------
  def rate_counter(target)
    counter_result = target.counter?(battler, @move_pos)
    case counter_result
    when nil ;   return 0
    when Numeric ; counter_result
    when Game_Battler ; counter_result = 100
    end
    #make_gtbs_dmg_preview_data(user, item)
    preview_damage = target.make_gtbs_dmg_preview_data(battler, item)
    return counter_result / 100.0 * preview_damage[0] / 100.0 * preview_damage[1] / battler.hp
  end
  
  #------------------------------------------------------------------------
  #* adjust damage: opponent/ally, hp/mp
  #------------------------------------------------------------------------
  def adjust_damage(target, damage, mp = false)
    if mp
      damage = [[damage, target.mp].min, target.mp - target.mmp].max
      ref = (damage > 0) ? target.mp : target.mmp
    else
      damage = [[damage, target.hp].min, target.hp - target.mhp].max
      ref = (damage > 0) ? target.hp : target.mhp
    end
    ally = battler.friends.include?(target)
    return damage, ref, ally
  end
  #------------------------------------------------------------------------
  #* evaluate_states
  #------------------------------------------------------------------------
  def evaluate_states(target, hit_states, rem_states)
    result = 0
    for state_id in hit_states
      next if state_id == 0
      result -= $data_states[state_id].ai_effect
    end
    for state in rem_states
      next if state_id == 0
      result += $data_states[state_id].ai_effect
    end
    return result if battler.friends.include?(target)
    return -result
  end
  #------------------------------------------------------------------------
  # Assign random movement and targets to current action using current skill
  #------------------------------------------------------------------------
  def assign_random_movement_and_targets(move_positions, type)
    #assign random movement position
    if !battler.moved? #not already moved?
      @move_pos = move_positions[rand(move_positions.size)]
    else #has moved - set to self position
      @move_pos = self.pos
    end
    
    #Not Guard
    if type != nil
      #get skill/attack/etc usage area
      act_range = range
      #select random attack position
      @position = act_range[rand(act_range.size)]
      #find targets (if any)
      $tbs_cursor.moveto(@move_pos)
      $tbs_cursor.target_positions = battler.target_zone(@move_pos, position, type)
      @targets = tbs_make_targets
    else #Guard Type
      @position = battler.pos
      @targets = [battler]
    end
  end
end