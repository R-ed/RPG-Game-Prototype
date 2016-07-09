#===============================================================================
# Windows_Status_GTBS
#===============================================================================
class Windows_Status_GTBS < TBS_Window_Base
  attr_accessor :skill
  #----------------------------------------------------------------------------
  # Constants
  #----------------------------------------------------------------------------
  #----------------------------------------------------------------------------
  # * Object Intialization
  #    actor = Game_Actor/Game_Enemy/nil
  #----------------------------------------------------------------------------
  def initialize(actor = nil) 
    super(0, 0, 250, 155)
    create_contents 
    ensure_open
    setup_gauges
    move_to(6)
    setup_temp
    refresh
    @win_help = nil;
  end
  #----------------------------------------------------------------------------
  def win_help=(win)
    @win_help = win
  end
  #----------------------------------------------------------------------------
  # Setup Temp
  #----------------------------------------------------------------------------
  def setup_temp
    @attacker = nil
    @actor = nil
    @skill = nil
    @type = 0
    @hp = 0
    @maxhp = 0
    @mp = 0
    @maxmp = 0
    @at = 0
    @states = []
    @states_act = nil
    @preview = []
  end
  #----------------------------------------------------------------------------
  # Setup Gauges - Setups up HP/MP/Act gauges and positions
  #----------------------------------------------------------------------------
  def setup_gauges
    @gauges_setup = true
    add_type = [0, 1]
    add_type += [2] if ($game_system.cust_battle == "ATB")
    add_type += [3] if ($data_system.opt_display_tp)
    y_spacing = (add_type.size > 3 ? 18 : 24)
    ind = 0
    y_min = 24
    for type in add_type
      y = (y_spacing * ind) + y_min
      case type
      when 0#hp
        @hp_bar = Progress_Bar.new(self, 0,  y, type)
        @hp_bar.set_symbol(Vocab.hp)
      when 1#mp
        @mp_bar = Progress_Bar.new(self, 0, y, type)
        @mp_bar.set_symbol(Vocab.mp)
      when 2#at
        @at_bar = Progress_Bar.new(self, 0, y, type)
        @at_bar.set_symbol(Vocab.at) if GTBS::Show_Action_Time_value
      when 3#tp
        @tp_bar = Progress_Bar.new(self, 0, y, type)
        @tp_bar.set_symbol(Vocab.tp)
      end
      ind += 1
    end
  end
  #---------------------------------------------------------------------------- 
  # Act - Returns the current actor
  #----------------------------------------------------------------------------
  def act
    return @actor
  end
  #----------------------------------------------------------------------------
  # Ensure Open - Attempt to make VX take me seriously!
  #----------------------------------------------------------------------------
  def ensure_open
    @opening = false
    @closing = false
    self.openness = 255
  end
  #----------------------------------------------------------------------------
  # Hide - Hides the currently displayed info
  #----------------------------------------------------------------------------
  def hide
    self.visible = false
    clear_dmg_preview
  end
  #----------------------------------------------------------------------------
  # Update Method
  #----------------------------------------------------------------------------
  def update(actor = nil) 
    super()
    if @actor != actor
      @actor = actor
      refresh
    elsif @actor
      lite_refresh
    else
      update_gauges
    end 
  end
  
  #----------------------------------------------------------------------------
  # Update Gauges
  #----------------------------------------------------------------------------
  def update_gauges
    @hp_bar.update
    @mp_bar.update
    @at_bar.update if @at_bar != nil
    @tp_bar.update if @tp_bar != nil
  end
  #----------------------------------------------------------------------------
  # Damage Preview Needed?  
  #----------------------------------------------------------------------------
  def dmg_preview?
    if @attacker != nil and GTBS::PREVIEW_DAMAGE
      dmg_preview(@type, @attacker, @skill)
    end
  end
  #----------------------------------------------------------------------------
  # Draw Actor Info
  #----------------------------------------------------------------------------
  def draw_actor_info
    clear_info
    self.contents.font.size = Font.default_size 
    x = 0
    y = 0
    width = self.contents.width
    self.contents.draw_outline_text(x,y,width,24,@actor.name)
    self.contents.draw_outline_text(x,y,width,24,@actor.class_name,2)
    x = width-96
    y = 24
    draw_actor_face(@actor,x,y,96)
  end

  def clear_info
    self.contents.clear_rect( 0, 0, self.contents.width, 24 ) #Clears name
    self.contents.clear_rect( self.contents.width - 96, 24, 96, 96)
  end
  
  #----------------------------------------------------------------------------
  # Refresh States - Draws the actors current states. 
  #----------------------------------------------------------------------------
  def refresh_states(force = false)
    if force or @actor != @states_act or @actor.states != @states
      @states_act = @actor
      x = 0
      y = self.contents.height-24
      @states = @actor.states.clone
      draw_states(x,y,@states, [])
    end
  end
  #----------------------------------------------------------------------------
  # Refresh Method
  #----------------------------------------------------------------------------
  def refresh
    if @actor == nil
      hide 
      return
    end
    #create_contents
    clear_dmg_preview
    draw_actor_info
    refresh_hp
    refresh_mp
    refresh_act
    refresh_tp
    refresh_states(true)
    self.visible = true
  end
    #----------------------------------------------------------------------------
  # Lite Refresh - As information is already being shown.. update pertainent info
  #----------------------------------------------------------------------------
  def lite_refresh
    if @actor.hp != @hp or @actor.mhp != @maxhp
      refresh_hp
    end
    if @actor.mp != @mp or @actor.mmp != @maxmp
      refresh_mp
    end
    if @actor.atb != @act
      refresh_act
    end
    if @actor.tp != @tp
      refresh_tp
    end
    update_gauges
    refresh_states
    dmg_preview?
  end

   #----------------------------------------------------------------------------
  # Refresh HP - draws the hp
  #----------------------------------------------------------------------------
  def refresh_hp
    if @actor.hide_info?
      @hp = nil
      @maxhp = nil
    else
      @hp = @actor.hp
      @maxhp = @actor.mhp
    end
    @hp_bar.refresh(@hp, @maxhp)
  end
  
  #----------------------------------------------------------------------------
  # Refresh SP - draws the sp
  #----------------------------------------------------------------------------
  def refresh_mp
    if @actor.hide_info?
      @mp = nil
      @maxmp = nil
    else
      @mp = @actor.mp
      @maxmp = @actor.mmp
    end
    @mp_bar.refresh(@mp, @maxmp)
  end
  #----------------------------------------------------------------------------
  # Refresh ATB - draws the atb
  #----------------------------------------------------------------------------
  def refresh_act
    return if $game_system.cust_battle == "TEAM"
    atb = @actor.atb
    atb_max = @actor.recuperation_time
    if atb > atb_max or atb == 0
      atb == atb_max
    end
    @act = @actor.atb
    @at_bar.refresh(atb, atb_max)
  end 
  #----------------------------------------------------------------------------
  # Refresh TP - draws the tp
  #----------------------------------------------------------------------------
  def refresh_tp
    if @actor.hide_info?
      @tp = nil
      @mtp = nil
    else
      @tp = @actor.tp
      @mtp = @actor.max_tp
    end
    @tp_bar.refresh(@tp, @mtp) if @tp_bar != nil
  end
  #----------------------------------------------------------------------------
  # Clears Damage Preview is currently displayed
  #----------------------------------------------------------------------------
  def clear_dmg_preview
    @attacker = nil
    @type = nil
    @skill = nil 
    self.contents.clear_rect(0, self.contents.height - WLH, width, WLH) 
    return unless @preview
    for sp in @preview
      sp.dispose
    end
    @preview.clear
  end 
  #----------------------------------------------------------------------------
  # Display Damage Preview
  #----------------------------------------------------------------------------
  def dmg_preview(type, attacker, skill = nil, target = [@actor])
    return if GTBS::PREVIEW_DAMAGE == false
    return if target == nil
    return if (@attacker == attacker and @type == type and @skill == skill)
    refresh #force refresh to ensure all  looks right before drawing preview 
    actor = @actor
    unless target.include?(@actor)
      update(@attacker)
    end
    @attacker = attacker
    @type = type
    @skill = skill
    for bat in target
      next unless bat
      @attacker.current_action
      result = bat.make_gtbs_dmg_preview_data(@attacker, @attacker.current_action.item)
      unless result.nil?
        if @actor == bat
          index = -1
        else
          index = @preview.size
        end
        @preview.push(Window_TBS_Preview.new(index, bat))
        @preview.last.refresh(result)
      end
    end
    @actor = actor
    self.visible = true 
  end
  
  def visible=(bool)
    super
    return unless @preview
    for sp in @preview
      sp.visible = bool
    end
  end
  #----------------------------------------------------------------------------
  # Draws State Icons for Plus/Minus states, called via dmg_preview
  #----------------------------------------------------------------------------
  def draw_states(x,y,plus,minus = [], bmp = nil) 
    i = 0
    for state in plus + minus
      if state.is_a?(Numeric)
        state = $data_states[state]
      end
      if bmp and state != nil
        bitmap = Cache.system("Iconset")
        rect = Rect.new(state.icon_index % 16 * 24, state.icon_index / 16 * 24, 24, 24)
        bmp.blt(x, y, bitmap, rect, 255)
      else
        draw_state_icon(state,x+(24*i),y)
      end
      i += 1
    end
  end
end
