class Game_Unit
  alias init_gm_unit_gtbs initialize
  def initialize(*args)
    init_gm_unit_gtbs(*args)
    @summoned = []
  end
  def clear_summons
    @summoned.clear
  end
  def clear_neutrals
  end
  def existing_members
    clean_up_summoned
    return (all_members.select {|mem| mem.exist? } ) + @summoned
  end
  def summoned
    return @summoned
  end
  def tbs_dead_members
    dead = all_members.select {|mem| mem.death_state?}
    return (dead.select{|mem| mem.tbs_battler})
  end
  def clean_up_summoned
    @summoned = @summoned.select{|mem| !mem.death_state?}
  end
end
class Game_Troop < Game_Unit
  def all_members
    return members
  end
  #--------------------------------------------------------------------------
  # Add Summon - here for the later SUMMON enemy feature
  #--------------------------------------------------------------------------
  def add_summon(enemy_id) 
    return nil if $data_enemies[enemy_id] == nil
    summon = Game_Enemy.new(0, enemy_id)
    summon.appear
    @summoned << summon
    return summon
  end
  #--------------------------------------------------------------------------
  # Add Member
  #--------------------------------------------------------------------------
  def add_member(enemy_id)
    return nil if $data_enemies[enemy_id] == nil
    en = Game_Enemy.new(0, enemy_id)
    en.appear
    @enemies << en
    return en
  end
  #--------------------------------------------------------------------------
  # * Battle Event Setup
  #--------------------------------------------------------------------------
  alias setup_batevent_trigger setup_battle_event
  def setup_battle_event
    setup_batevent_trigger
    event = $game_system.battle_events.values.find {|event| event.starting }
    event.clear_starting_flag if event
    @interpreter.setup(event.list, event.id) if event
  end
end

class Game_Party < Game_Unit
  alias gtbs_initialize initialize
  def initialize(*args)
    gtbs_initialize(*args)
    @neutrals = []
    @force_placed = []
  end
  def force_placed
    return @force_placed
  end
  #--------------------------------------------------------------------------
  # * Add an Actor
  #     actor_id : actor ID
  #--------------------------------------------------------------------------
  def add_neutral(actor_id) 
    actor = $game_actors[actor_id ]
    if actor
      actor.neutral = true
      actor.instance_eval("@originally_neutral = true")
      @neutrals.push(actor)
    end
    return actor
  end
  def neutrals
    return @neutrals
  end
  def clear_neutrals
    @neutrals.clear
  end
  def add_summon(actor_id) 
    return nil if $data_actors[actor_id] == nil
    if (GTBS::SUMMON_GAIN_EXP)
      summon = $game_actors[actor_id]
    else
      summon = Game_Actor.new( actor_id)
    end
    summon.appear
    @summoned.push(summon)
    return summon
  end
  def set_place_max=(value)
    @max_place = value
  end
  def clear_place_max
    @max_place = nil
  end
  def placable?
    return @max_place if @max_place != nil
    return (all_members.select {|mem| !mem.dead?}).count
  end
  alias gain_item_vx_compatibility gain_item
  def gain_item(*args)
    if args[0].is_a?(Numeric)
      args[0] = $data_items[*args[0]]
    end
    gain_item_vx_compatibility(*args)
  end
  def gain_weapon(id, n)
    item = $data_weapons[id]
    gain_item(item, n)
  end
  def gain_armor(id, n)
    item = $data_armors[id]
    gain_item(item, n)
  end
  def clear_tbs_positions
    for actor in all_members
      actor.clear_tbs_pos
    end
  end
  def add_member(actor_id)
  end
end
