#class Battle_Option < Window_Selectable
#===============================================================================
# Battle_Option
# Displays the battle options available for the BS type (ATB or TEAM)
#===============================================================================
class Battle_Option < TBS_Window_Selectable
  End_Turn = "End Turn"
  Act_List = "Act List"
  Conditions =  "Conditions"
  Config = "Config"
  Cancel = "Cancel"
  Option_Translate = {
    End_Turn => Vocab_GTBS::Battle_Option_End_Turn,
    Act_List => Vocab_GTBS::Battle_Option_Act_List,
    Conditions => Vocab_GTBS::Battle_Option_Conditions,
    Config => Vocab_GTBS::Battle_Option_Config,
    Cancel => Vocab_GTBS::Battle_Option_Cancel}

  #----------------------------------------------------------------------------
  # Object Initialization
  #----------------------------------------------------------------------------
  def initialize
    h =  $game_system.cust_battle == "TEAM" ? 4 : 3
    super(260, 190, 120, (h*24)+32)
    @column_max = 1
    refresh
  end
  def item_max
    @options ? @options.size : 1
  end
   #----------------------------------------------------------------------------
  # Get Single Data Option with Index
  #----------------------------------------------------------------------------
  def option
    return @options[@index]
  end
  #----------------------------------------------------------------------------
  # Refresh Process
  #----------------------------------------------------------------------------
  def refresh
    get_available_options
    if self.contents != nil
      self.contents.clear
      self.contents = nil
    end
    self.height = @options.size * WLH + 32
    self.contents = Bitmap.new(width - 32, height - 32)
    for i in 0...@options.size
      text = Option_Translate[@options[i]]
      self.contents.draw_text(2,i*WLH,100,WLH, text)
    end
  end
  #--------------------------------------------------------------
  # Get Available Options - populates the @options array with available selections
  #--------------------------------------------------------------
  def get_available_options
    @options = []
    if $game_system.cust_battle == Game_System::TEAM_Mode
      @options += [End_Turn] 
    else#ATB mode
      @options += [Act_List] if GTBS::ACT_LIST
    end
    @options +=  [Conditions, Config, Cancel]
  end
  #--------------------------------------------------------------
  # Update Curosr Rect changes - fixes mouse over issues
  #--------------------------------------------------------------
  def update_cursor_rect
    if @index < 0
      self.cursor_rect.empty
      return
    end
    row = @index / @column_max
    if row < self.top_row
      self.top_row = row
    end
    if row > self.top_row + (self.page_row_max - 1)
      self.top_row = row - (self.page_row_max - 1)
    end
    cursor_width = self.width / @column_max - 32
    x = @index % @column_max * (cursor_width + 32)
    y = @index / @column_max * WLH - self.oy
    self.cursor_rect.set(x, y, cursor_width, WLH)
  end
end