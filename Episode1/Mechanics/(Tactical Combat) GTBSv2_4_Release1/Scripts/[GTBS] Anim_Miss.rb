#===============================================================================
# This Script is made specfically for usage with GTBS version 1.5.1.4 by GubiD.
#===============================================================================

#------------------------------------------------------------------------------
# This modification is so that you can spawn new events mainly for animations in
# the battle system. Miss and summons will not work if this is not here.
#------------------------------------------------------------------------------

class Anim_Miss < Game_Event  
  #----------------------------------------------------------------------------
  # * Object Initialization
  #    type: 0 = Miss, 1 = Summon, ELSE = PLAY ANIMATION
  #----------------------------------------------------------------------------
  def initialize(type = 0, anim_id = 0)
    @type = type
    @anim_id = anim_id
    @played = false
    anim = RPG::Event.new(0,0)
    super($game_map.map_id, anim)
  end
  def animated?
    return false
  end
  #----------------------------------------------------------------------------
  # * Start Anim - Plays stored animation information
  #----------------------------------------------------------------------------
  def start_anim
    case @type
    when 0
      @animation_id = GTBS::MISS_ANIMATION #Animation ID of MISS!.. for spells that miss
    when 1
      @animation_id = GTBS::SUMMON_ANIMATION #Animation ID of SPAWN.. for summons  (RAISE)
    else
      @animation_id = @anim_id
    end
    @sprite.update #unless @sprite.nil?
    @played = true
  end
  #----------------------------------------------------------------------------
  # * Place - Sets animation location to appear
  #----------------------------------------------------------------------------
  def place(x,y)
    moveto(x,y)
    @id = $game_map.events.size
    self.refresh
    $game_map.events[@id] = self
    $game_map.need_refresh = true
    @sprite = SceneManager.scene.create_character(SceneManager.scene.spriteset.viewport1,self)
  end
  #----------------------------------------------------------------------------
  # * Update process - used to self dispose after animation has finished
  #----------------------------------------------------------------------------
  def update
    super()
    if @played == true and !@sprite.animation?
      SceneManager.scene.dispose_character(self)#spriteset.event_sprites.delete(@sprite)
      $game_map.events.delete(self)
    end
  end
end
