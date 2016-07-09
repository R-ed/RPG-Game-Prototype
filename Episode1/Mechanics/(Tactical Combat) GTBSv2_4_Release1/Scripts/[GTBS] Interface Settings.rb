module GTBS
  #-------------------------------------------------------------
  # Set Battle Start and Congrats Text
  #-------------------------------------------------------------
  VICTORY_MESSAGE = "Congratulations!"
  ESCAPE_MESSAGE = "Escape!"
  DEFEAT_MESSAGE = "You was defeated!"
  BATTLE_COMPLETE = "Battle Complete"
  ITEM_GAIN_TEXT = "Items Found"
  # make a picture 'Battle_Start.png' in the directory 'Graphics/Pictures/'
  # if not, this text will appear
  BATTLE_START = "-Battle Start-"
  
  #-------------------------------------------------------------
  # active_time status abreviation
  #-------------------------------------------------------------
  AT_TERM = "AT" 
  
  #-------------------------------------------------------------
  # Use 'Weapon Name' in place of actors 'Attack' command
  #-------------------------------------------------------------
  Use_Weapon_Name_For_Attack = false
  
  #-------------------------------------------------------------
  # Always Allow Place
  #-------------------------------------------------------------
  # If 'Actor#' events exist, then still allow PLACE events to work
  #-------------------------------------------------------------
  Always_Allow_Place = true
  
  #-------------------------------------------------------------
  # Allow user Control for All Teams 
  #-------------------------------------------------------------
  # This is here for the ability to play 2player games against one
  # another.  This allows you the ability to control actors for all
  # various teams that are available.  It however only extends the 
  # ability to control *actors* movements that belong to a team other
  # than 'actor' which is the default.  
  # If you create a series of 'neutral' characters and assign their 
  # team to "enemy", and this flag is true, you can control their 
  # actions rather than letting the AI take control. 
  #-------------------------------------------------------------
  Allow_User_Control_For_All_Teams = false 
  
  #-------------------------------------------------------------
  # Use Mini Battle Scene
  #-------------------------------------------------------------
  Use_Mini_Battle = true
  
  #-------------------------------------------------------------
  # Prevent Mini Scene when more than 1 target and not 'pop individual'
  # Pop Individual forces mini to always show so this setting is irrelevant then.
  #-------------------------------------------------------------
  Prevent_Group_Mini = true
  
  #-------------------------------------------------------------
  # Use War Style Mini Battle - Like Fire Emblem War battles
  #-------------------------------------------------------------
  Use_Mini_War = true #Not implemented
  
  #-------------------------------------------------------------
  # Unknown Text - To be used when an enemy is marked to show unknown info
  #-------------------------------------------------------------
  Unknown_Text = "????"
  
  #-------------------------------------------------------------
  # Enemy Think
  #-------------------------------------------------------------
  THINKING_TEXT  = "Thinking"
   
  #-------------------------------------------------------------
  # SCROLL_SPEED - 5 is default
  #-------------------------------------------------------------
  # Scroll speed controls the speed in which the screen will pan to the current target 
  # during battle
  SCROLL_SPEED = 4
  
  #-------------------------------------------------------------
  # Action Confirmations
  #-------------------------------------------------------------
  MOVE_CONFIRM = true
  ATTACK_CONFIRM = true #this applies to ALL actions ( Attack/Skill/Item )
  WAIT_CONFIRM = true
  
  #-------------------------------------------------------------
  # Force Wait - After both move and action have been performed, force wait phase
  #-------------------------------------------------------------
  Force_Wait = false
  
  #-------------------------------------------------------------
  # Enable Move when active, for actors only
  #-------------------------------------------------------------
  ENABLE_MOVE_START = false
  
  #-------------------------------------------------------------
  # Show Attackable Area after move?
  #-------------------------------------------------------------
  SHOW_MOVE_ATTACK = true
  MOVE_INCLUDE_SPELL = false
  

  #-------------------------------------------------------------
  # Enable Act List (Action order list available from cancel menu)
  #-------------------------------------------------------------
  ACT_LIST = true
  #Color for the active battler
  Act_List_Active_Color = Color.new(255,0, 0,255)
  #Color for all the occurences of the battler selected in the list
  Act_List_Select_Color = Color.new(0,255,0,255)
  #Normal color, for the others
  Act_List_Normal_Color = Color.new(255,255,255,255)
  
  #-------------------------------------------------------------
  # Hide Cursor Position - Hide x,y,height info? (true or false)
  #-------------------------------------------------------------
  HIDE_CURSOR_POSITION_INFO = false
  #-------------------------------------------------------------
  # PREVEIW_DAMAGE
  #-------------------------------------------------------------
  # This options allows you to enable/disable damage preview for the status window
  #-------------------------------------------------------------
  PREVIEW_DAMAGE = false
  
  #-------------------------------------------------------------
  # Hide Inactive Menu Commands
  #-------------------------------------------------------------
  HIDE_INACTIVE_COMMANDS = true

  #-------------------------------------------------------------
  # Control Opacity (0-255)
  #-------------------------------------------------------------
  # This controls what opacity is set to all command windows.
  CONTROL_OPACITY = 180
  
  #-------------------------------------------------------------
  # DIM OPACITY - used during team mode to visibly display who has already acted
  #-------------------------------------------------------------
  DIM_OPACITY = 120 
      
  #-------------------------------------------------------------
  # Menu Commands
  #-------------------------------------------------------------
  DataManager.init # run this early to load vocab requirement
  #-------------------------------------------------------------
  # This allows you to replace your command names for the Actions window, without
  # editing the codebase.  Rather than just being a order based variable you will
  # use as Hash that allows you to access information by a content name.  
  #------------------------------------------------------------- 
  # Also keep in mind that these are used as Defaults.  So your SKILL, if configured
  # in the skill section, may be replaced with something else like "Earth" 
  # or "Steal" accordingly. 
  #-------------------------------------------------------------
  Menu_Move = "Move"
  Menu_Wait = "Wait"

  #-------------------------------------------------------------
  # Use Gradiant Bars for HP/MP/TP/AT
  #-------------------------------------------------------------
  Use_Dual_Gradiant_Bars = false
  
  #-------------------------------------------------------------
  # If Use_Gradiant_Bars == false - determine images that should be used
  # to fill bars for status.  Images from .\Graphics\System\GTBS\
  # If image file cannot be found, then will use 2 tone gradiation (Left 2 Right)
  #-------------------------------------------------------------
    HP_Status_Img = ""
  #-------------------------------------------------------------
    MP_Status_Img = ""
  #-------------------------------------------------------------
    TP_Status_Img = ""
  #-------------------------------------------------------------
    AT_Status_Img = ""
  #-------------------------------------------------------------
  
  #-------------------------------------------------------------
  # Stat Animation Time for Progess Bars
  # This value determines the amount of frames required to adjust fill
  # between old/new fill perc of bars.  1 is lowest acceptable value. 
  # Increasing this causes minor lag spikes when bars needs to be drawn
  #-------------------------------------------------------------
  STAT_ANIM_TIME = 2
  
  #------------------------------------------------------------
  # Color definition
  #------------------------------------------------------------
  
  #-----------------------------------------------------------
  # Get Color
  #-----------------------------------------------------------
  # Used to define colors in the program.  There is no actual mention
  # of the name, so you can simply update the RGB of these to affect the game.
  #-----------------------------------------------------------
  RED = Color.new(255,0,0,255)
  BLUE = Color.new(0,0,255,255)
  GREEN = Color.new(0,255,0,255)
  YELLOW = Color.new(255,255,0,255)
  PURPLE = Color.new(128,0,255,255)
  ORANGE = Color.new(255,128,0,255)
  BROWN = Color.new(128,64,0,255)
  BLACK = Color.new(0,0,0,255)
  WHITE = Color.new(255,255,255,255)
  PINK = Color.new(255,128,255,255)
  TAN = Color.new(200,200,110,255)
    
  class Gtbs_Color
    attr_reader :name, :color
    def initialize(name, color)
      @name = name
      @color = color
    end
  end
  #Now Reassign colors and add to Colors array
  Colors = [
    RED = Gtbs_Color.new('RED', RED ),
    BLUE = Gtbs_Color.new('BLUE' , BLUE),
    GREEN = Gtbs_Color.new('GREEN' , GREEN),
    YELLOW = Gtbs_Color.new('YELLOW' , YELLOW),
    PURPLE = Gtbs_Color.new('PURPLE' , PURPLE),
    ORANGE = Gtbs_Color.new('ORANGE' , ORANGE),
    BROWN = Gtbs_Color.new('BROWN' , BROWN),
    BLACK = Gtbs_Color.new('BLACK' , BLACK),
    WHITE = Gtbs_Color.new('WHITE' , WHITE),
    PINK = Gtbs_Color.new('PINK' , PINK),
    TAN = Gtbs_Color.new('TAN', TAN)
  ]
  #-------------------------------------------------------------
  # Use Animated Tiles(used for move/attack/skill tiles)
  #-------------------------------------------------------------
  ANIM_TILES = false

end
module Vocab
  def self.at
    return GTBS::AT_TERM
  end
end