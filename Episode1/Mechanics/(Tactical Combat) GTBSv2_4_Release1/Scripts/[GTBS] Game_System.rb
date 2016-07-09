#--------------------------------------------------------------------------
# Game System
#--------------------------------------------------------------------------
class Game_System
  
  #--------------------------------------------------------------------------
  # Constants
  #--------------------------------------------------------------------------
  ATB_Mode = 'ATB'
  TEAM_Mode = 'TEAM'
  
  #--------------------------------------------------------------------------
  attr_accessor :cust_battle
  attr_accessor :scroll_cursor
  attr_reader   :battle_events
  attr_reader   :acted 
  attr_accessor :move_color
  attr_accessor :help_skill_color
  attr_accessor :attack_skill_color
  attr_accessor :attack_color
  attr_accessor :tbs_enabled
  #--------------------------------------------------------------------------
  # Object Initialization - Added GTBS variables
  #--------------------------------------------------------------------------
  alias gtbs_GS_init initialize
  def initialize
    reset_default_gtbs_config 
    @acted               = []
    @battle_events       = {}
    @tbs_enabled         = true
    gtbs_GS_init
  end
  def tactical_events
    return SceneManager.scene.tactics_alive + @battle_events.values
  end
  
  def gtbs_enabled?
    return @tbs_enabled
  end
  def clear_battlers 
    @acted.clear
    @battle_events.clear
  end
  
  def reset_default_gtbs_config
    @cust_battle         = (GTBS::MODE == 0 ? ATB_Mode : TEAM_Mode) unless $game_party.in_battle
    @scroll_cursor       = true
    @move_color          = GTBS::BLUE
    @help_skill_color    = GTBS::GREEN
    @attack_skill_color  = GTBS::YELLOW
    @attack_color        = GTBS::RED
  end
    
  #-------------------------------------------------------------
  # Remove Dead from map upon death?
  # 0 = Do NOT remove any dead
  # 1 = Remove Enemies Only
  # 2 = Remove ALL dead
  #-------------------------------------------------------------
  def actors_bodies?
    GTBS::REMOVE_DEAD != 2
  end
  def neutrals_bodies?
    GTBS::REMOVE_DEAD != 2
  end
  def enemies_bodies?
    GTBS::REMOVE_DEAD == 0
  end
  
  def team_mode?
    @cust_battle == TEAM_Mode
  end
end