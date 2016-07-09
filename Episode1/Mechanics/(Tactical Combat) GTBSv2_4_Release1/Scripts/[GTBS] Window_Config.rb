#===============================================================================
# Window Config
#===============================================================================
# Used to configure GTBS
#----------------------------------------------------------------------------
class Window_Config < TBS_Window_Selectable
  
  #--------------------------------------------------------------------------
  # Constants
  #----------------------------------------------------------------------------
  Offset = 3
  #----------------------------------------------------------------------------
  # Object Initialization
  #----------------------------------------------------------------------------
  attr_accessor :win_color
  def initialize
    w = 480
    h = 32 + 8 * WLH
    x = (Graphics.width-w)/2
    y = (Graphics.height-h)/2
    super(x,y,w,h)
    self.contents = Bitmap.new(width-32, height-32)
    @item_max = 8
    self.index = -1
    refresh
    @win_color = Window_Select_Color.new
    @win_color.active = false
  end
  #----------------------------------------------------------------------------
  # item max
  #----------------------------------------------------------------------------
  def item_max
    return @item_max
  end
  def row_max
    return 1
  end
  #----------------------------------------------------------------------------
  # Refresh
  #----------------------------------------------------------------------------
  def refresh
    create_contents
    x = WLH
    y = 0
    self.contents.draw_text(x,y,160,WLH, Vocab_GTBS::Config_Reset_Default )
    y += WLH
    #displays current setting for enable custom battle system
    self.contents.draw_text(x, y, 160, WLH, Vocab_GTBS::Config_Battle_System_Type)
    option = $game_system.cust_battle
    if $game_party.in_battle
      self.contents.font.color = disabled_color
    end
    text = (option == "ATB") ? Vocab_GTBS::Config_ATB_Mode : Vocab_GTBS::Config_TEAM_Mode
    self.contents.draw_text(x+160,y,240,WLH, text, 2)
    
    self.contents.font.color = normal_color
    y += WLH
    #Displays the current setting for the Show_Damage in battle 
    self.contents.draw_text(x, y, 200, WLH, Vocab_GTBS::Config_Scroll_During_Battle)
    option = $game_system.scroll_cursor
    text = option ? Vocab_GTBS::Config_Scroll_On : Vocab_GTBS::Config_Scroll_Off
    self.contents.draw_text(x+360,y,40,WLH, text)
      
    y += WLH
    #Displays the current color for attack skill color
    self.contents.draw_text(x, y, 140, WLH, Vocab_GTBS::Config_Attack_Skill_Color )
    
    color = $game_system.attack_skill_color
    rect = Rect.new(x+360, y+Offset, 18, 18)
    self.contents.fill_rect(rect, color.color)
    y += WLH
    
    #Displays the current color for help skill color
    self.contents.draw_text(x, y, 140, WLH, Vocab_GTBS::Config_Help_Skill_Color )
    color = $game_system.help_skill_color
    rect = Rect.new(x+360, y+Offset, 18, 18)
    self.contents.fill_rect(rect, color.color)
    y += WLH
    
    #Displays current color for move color
    self.contents.draw_text(x, y, 140, WLH, Vocab_GTBS::Config_Move_Color )
    color = $game_system.move_color
    rect = Rect.new(x+360, y+Offset, 18, 18)
    self.contents.fill_rect(rect, color.color)
    y += WLH
    
    #Displays current color for Attack color
    self.contents.draw_text(x, y, 140, WLH, Vocab_GTBS::Config_Attack_Color )
    color = $game_system.attack_color
    rect = Rect.new(x+360, y+Offset, 18, 18)
    self.contents.fill_rect(rect, color.color)
    y += WLH
    
    self.contents.draw_text(x,y, self.width-64, WLH, Vocab_GTBS::Config_Done,1)
  end
  #----------------------------------------------------------------------------
  # Update Cursor Location/Size
  #----------------------------------------------------------------------------
  def update_cursor_rect
    self.cursor_rect.set(26, @index * WLH, 205, WLH)
  end
  
  def select_color
    color = @win_color.get_color
    case self.index
    when 3 #Attack Skill Color
      $game_system.attack_skill_color = color
    when 4 #Help Skill Color
      $game_system.help_skill_color = color
    when 5 #Move Color
      $game_system.move_color = color
    when 6 #Attack Color
      $game_system.attack_color = color
    else
      return
    end
    refresh
  end
  #----------------------------------------------------------------------
  # Dispose
  #---------------------------------------------------------------------
  def dispose
    @win_color.dispose
    super
  end
end

