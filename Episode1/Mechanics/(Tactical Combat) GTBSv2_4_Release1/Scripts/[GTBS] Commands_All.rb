
#=============================================================
# Commands All
#-------------------------------------------------------------
#This displays the command window for character actions.
#=============================================================
class Commands_All < TBS_Win_Actor
  
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize(*args)
    super
    @actor_display = Window_Actor_Display.new(height)
  end
  #--------------------------------------------------------------------------
  # * Get Number of Lines to Show
  #--------------------------------------------------------------------------
  def visible_line_number
    item_max
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    return unless @actor
    add_move_command(@actor.moved?)
    add_attack_command(@actor.perf_action)
    add_skill_commands(@actor.perf_action)
    add_item_command(@actor.perf_action)
    add_guard_command
    add_equip_command if $imported["YEA-CommandEquip"]
    add_status_command
    add_escape_command
  end
  #--------------------------------------------------------------------------
  # * Add Attack Command to List
  #--------------------------------------------------------------------------
  def add_attack_command(disabled=false)
    add_command((GTBS::Use_Weapon_Name_For_Attack ? @actor.weapon_name : Vocab::attack), :attack, @actor.attack_usable?) unless GTBS::HIDE_INACTIVE_COMMANDS && @actor.perf_action
  end
  #--------------------------------------------------------------------------
  # * Add Skill Command to List
  #--------------------------------------------------------------------------
  def add_skill_commands(disabled)
    @actor.added_skill_types.sort.each do |stype_id|
      name = $data_system.skill_types[stype_id]
      add_command(name, :skill, true, stype_id) unless GTBS::HIDE_INACTIVE_COMMANDS && @actor.perf_action
    end
  end
  
  #--------------------------------------------------------------------------
  # * Add Guard Command to List
  #--------------------------------------------------------------------------
  def add_guard_command
    if @actor.perfaction? == false#@actor.guard_usable?
      add_command(Vocab::guard, :defend, true)
    else
      add_command(GTBS::Menu_Wait, :wait, true)
    end
  end
  #--------------------------------------------------------------------------
  # * Add Item Command to List
  #--------------------------------------------------------------------------
  def add_item_command(disabled)
    add_command(Vocab::item, :item) unless GTBS::HIDE_INACTIVE_COMMANDS && @actor.perf_action
  end
  #--------------------------------------------------------------------------
  # * Add Move Command to List
  #--------------------------------------------------------------------------
  def add_move_command(disabled)
    add_command(GTBS::Menu_Move, :move, !@actor.moved?) unless GTBS::HIDE_INACTIVE_COMMANDS && @actor.moved?
  end
  def add_status_command
    add_command(Vocab.status, :status, true)
  end
  def add_escape_command
    add_command(Vocab.escape, :escape, BattleManager.can_escape?)
  end
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  def setup(actor)
    super(actor)
    @actor_display.refresh(actor)
    self.height = item_max * WLH + (standard_padding * 2)
    select(0)
  end
  def clear_help
    if @help_window
      @help_window.clear
    end
  end
  def call_update_help
    update_help if @help_window
  end
  def update_help
    case current_symbol
    when :item
      text = Vocab_GTBS::Help_Item
    when :skill
      text = Vocab_GTBS::Help_Class_Ability
    when :attack
      text = Vocab_GTBS::Help_Attack
    when :move
      text = Vocab_GTBS::Help_Move
    when :status
      text = Vocab_GTBS::Help_Status
    when :defend
      text = Vocab_GTBS::Help_Defend
    when :wait
      text = Vocab_GTBS::Help_Wait
    when :escape
      text = Vocab_GTBS::Help_Escape
    end
    text = (text || "")
    
    #This is a kludge to make this help window display correctly
    @help_window.move_to(8)
    @help_window.move_to(2)
    #for whatever reason, it must be moved then, moved back to start displaying
    #text again. ???
    @help_window.set_text(text)
  end
end
