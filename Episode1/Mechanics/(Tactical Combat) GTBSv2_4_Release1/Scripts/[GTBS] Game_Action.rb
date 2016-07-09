#===============================================================================
# This Script is made specfically for usage with GTBS version 1.5.1.4 by GubiD.
#===============================================================================

#--------------------------------------------------------------------------
# Game BattleAction - Gives additional variables for GTBS use
#--------------------------------------------------------------------------
class Game_Action
  attr_accessor  :position
  attr_accessor  :targets
  attr_accessor  :tactic
  attr_accessor  :move_pos
  attr_accessor  :rating
  attr_accessor  :before_move
  attr_accessor  :item_skill
  #--------------------------------------------------------------------------
  # Battler - returns the battler associated with this action
  #--------------------------------------------------------------------------
  def battler
    return subject
  end
  #--------------------------------------------------------------------------
  # * Set Guard
  #--------------------------------------------------------------------------
  def guard?
    item == $data_skills[subject.guard_skill_id]
  end
  #--------------------------------------------------------------------------
  # * Set Item
  #--------------------------------------------------------------------------
  def item?
    #return false if item.nil?
    @item.is_item?
  end
  #--------------------------------------------------------------------------
  # Skill
  #--------------------------------------------------------------------------
  def skill?
    not (item? or attack? or guard?)
  end
  #--------------------------------------------------------------------------
  # * Set Item
  #--------------------------------------------------------------------------
  alias set_item_gtbs set_item
  def set_item(item_id)
    skill_id = GTBS.item_range(item_id)[2]
    if skill_id > 0
      @item_skill = $data_skills[skill_id]
    end
    set_item_gtbs(item_id)
  end
  #--------------------------------------------------------------------------
  # Clear - Now has an override to disable guard + GTBS required items
  #--------------------------------------------------------------------------
  alias gubid_battleaction_clear clear
  def clear
    @position = []
    @targets = []
    @tactic = 0
    @move_pos = []
    @rating = 0
    @before_move = false
    gubid_battleaction_clear
  end
  #-------------------------------------------------------------------------
  # Sets the action.tactic setting so that AI processing (phase7) can know where 
  # to start
  #-------------------------------------------------------------------------
  def determine_tactic
    #Override retreat if physical attack
    if attack?
      @tactic = 1
    elsif skill?
      if !item.nil?
        @tactic = 2
      end
    else
      @tactic = 3
    end
  end
  
  #--------------------------------------------------------------------------
  # * Create Target Array
  #--------------------------------------------------------------------------
  def tbs_make_targets
    if attack?
      return tbs_make_attack_targets
    elsif skill?
      return tbs_make_obj_targets(item)
    elsif item?
      return tbs_make_obj_targets(item)
    end
  end
  #--------------------------------------------------------------------------
  # * Create Normal Attack Targets
  #--------------------------------------------------------------------------
  def tbs_make_attack_targets    
    targets = []
    targets += subject.opponents + subject.friends
    targets &= subject.opponents if !GTBS::ATTACK_ALLIES
    targets &= $tbs_cursor.targeted_battlers    
    targets = targets.select  {|target| target.dead? == false}
    return targets.compact
  end
  
  #--------------------------------------------------------------------------
  # Get Random Target
  #--------------------------------------------------------------------------
  def get_random_target(possible_targets)
    tgr_sum = possible_targets.inject(0) {|r, member| r + member.tgr }
    tgr_rand = rand * tgr_sum rescue tgr_rand = 0
    possible_targets.each do |member|
      tgr_rand -= member.tgr
      return member if tgr_rand < 0
    end
    possible_targets[0]
  end
  
  #--------------------------------------------------------------------------
  # * Create Skill or Item Targets
  #     obj : Skill or item
  #--------------------------------------------------------------------------
  def tbs_make_obj_targets(obj)
    #TODO: Need to clean this up a little. 
    targets = []
    if obj.for_all?
      targets += $tbs_cursor.targeted_battlers
    elsif obj.for_opponent?
      if obj.for_random?
        number_of_targets = obj.scope-2 
        number_of_targets.times do
          all_targets = $tbs_cursor.targeted_battlers
          targets &= subject.opponents if !GTBS::ATTACK_ALLIES
          target = get_random_target(all_targets)
          #targets.push(all_targets[rand(all_targets.size)])
          targets << target
        end
      else
        if obj.for_one?        # One enemy
          possible_opponents = $tbs_cursor.targeted_battlers
          if !GTBS::ATTACK_ALLIES
            possible_opponents &= subject.opponents
          end
          closest_opponent = possible_opponents.min do |a, b|
            $tbs_cursor.distance(a) <=> $tbs_cursor.distance(b) 
          end
          targets.push(closest_opponent)
        else                      # All enemies  
          targets += $tbs_cursor.targeted_battlers
          if !GTBS::ATTACK_ALLIES
            targets &= subject.opponents
          end
        end
      end
    elsif obj.for_user?         # User
      targets.push(battler) if battler.positions & $tbs_cursor.target_positions != []
    elsif obj.for_dead_friend?
      if obj.for_one?           # One ally (incapacitated)
        possible_friends = subject.dead_friends & $tbs_cursor.targeted_battlers
        closest_friend = possible_friends.min do |a, b|
          $tbs_cursor.distance(a) <=> $tbs_cursor.distance(b) 
        end
        targets.push(closest_friend)
      else                      # All allies (incapacitated)
        targets += subject.dead_friends & $tbs_cursor.targeted_battlers
      end
    elsif obj.for_friend?
      if obj.for_one?           # One ally
        possible_friends = $tbs_cursor.targeted_battlers
        if !GTBS::ATTACK_ALLIES
          possible_friends &= subject.friends
        end
        closest_friend = possible_friends.min do |a, b|
          $tbs_cursor.distance(a) <=> $tbs_cursor.distance(b) 
        end
        targets.push(closest_friend)
      else                      # All allies 
        targets += $tbs_cursor.targeted_battlers
        if !GTBS::ATTACK_ALLIES #exclude ENEMY targeted battlers
          targets &= subject.friends
        end
      end
    end
    if obj.is_a?(RPG::Skill) 
      if GTBS::PREVENT_SKILL_FRIENDLY_DMG.include?(obj.id)
        targets &= subject.opponents
      end
      if GTBS::TARGET_FIENDLY_ONLY_SKILLS.include?(obj.id)
        targets &= subject.friends
      end
    end
    unless obj.for_dead_friend?
      targets = targets.select {|target| target.nil? == false && !target.dead?}
    end
    return targets.compact
  end
end

module RPG
  class Enemy
    class Action
      def initialize
        @kind = 0
        @basic = 0
        @skill_id = 1
        @condition_type = 0
        @condition_param1 = 0
        @condition_param2 = 0
        @condition_turn_a = 0
        @condition_turn_b = 1
        @condition_hp = 100
        @condition_level = 1
        @condition_switch_id = 0
        @rating = 5
      end
      
      attr_accessor :kind
      attr_accessor :basic
      attr_accessor :skill_id
      attr_accessor :condition_type
      attr_accessor :condition_param1
      attr_accessor :condition_param2
      attr_accessor :condition_turn_a
      attr_accessor :condition_turn_b
      attr_accessor :condition_hp
      attr_accessor :condition_level
      attr_accessor :condition_switch_id
      attr_accessor :rating
      attr_accessor :targets
      attr_accessor :tactic
      attr_accessor :move_pos
    end
  end
end




