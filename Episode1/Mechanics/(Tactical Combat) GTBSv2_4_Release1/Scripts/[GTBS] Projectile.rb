#===============================================================================
# This Script is made specfically for usage with GTBS version 1.5.1.4 by GubiD.
#===============================================================================

class Projectile < Sprite
  #--------------------------------------------------------------------------
  # * Initialize
  #     Source = Source Object (actor or enemy.. usually)
  #     Target = Target Object (actor or enemy.. usually)
  #     Data   = Payload - Actor for physical attacks and Skill for.. skills
  #     Type 
  #       *  "normal" - for straight path with no camera adjustments
  #       *  "arched" - for curved path using camera adjustments (actual path 
  #            followed is straight, but camera adjust to "appear" as curved)
  #--------------------------------------------------------------------------
  # Constants
  #----------------------------------------------------------------------------

  #--------------------------------------------------------------------------
  # Wait Move Time, is the time in which the projectile will be stationary 
  #  before moving.
  #--------------------------------------------------------------------------
  WAIT_MOVE_TIME = 25
  Normal = 'normal'
  Arched =  'arched'
  
  def initialize(viewport, source, target, data, type = Normal)
    super(viewport)
    @source = source
    @target = target
    @type = type
    
    self.bitmap = Cache.picture("GTBS/Projectiles/#{data.name}") 
    
    self.opacity = 255
    self.visible = true
        
    
    @src_spr = SceneManager.scene.get_battler_sprite(@source)
    @trg_spr = SceneManager.scene.get_battler_sprite(@target)    
    if @src_spr.nil? || @trg_spr.nil?
      self.dispose
      return 
    end
    @sx = @src_spr.x-self.bitmap.width/2 
    @sy = @src_spr.y-self.bitmap.height 
    
    self.x = @sx
    self.y = @sy
    
    @tx = @trg_spr.x
    @ty = @trg_spr.y-self.bitmap.height 
    
    
    #DO NOT CHANGE THIS!
    dist = (@sx - @tx).abs + (@sy - @ty).abs*4
    if dist < 129
      @slice = 9   
      @div = 3
    else
      @slice = 24
      @div = 8
    end
    
    @start = WAIT_MOVE_TIME
    @started = false
    
    get_slope
    @index = 0
    @high = 4 * dist
    @base_y = $game_map.display_y  
    self.z = 2000 + [@target.screen_z, source.screen_z].max
    
    update
  end
  
  #--------------------------------------------------------------------------
  # Update
  #--------------------------------------------------------------------------
  def update
    return if disposed?
    super 
    if !@started
      @start -= 1
      if @start <= 0
        @started = true
        self.visible = true
      end
    else
      update_move #straight or arched projectile
      @index += 1
    end
    if @index >= @slice
      $game_map.set_display_pos($game_map.display_x, @base_y) if @type == Arched
      self.dispose
    end
  end
  
  #--------------------------------------------------------------------------
  # Screen X - sets the current x location for the sprite
  #--------------------------------------------------------------------------
  def screen_x
    return @sx - ((@index+1)*@speed_x)
  end
  #--------------------------------------------------------------------------
  # Screen Y - sets the current y location for the sprite
  #--------------------------------------------------------------------------
  def screen_y
    return @sy - ((@index+1)*@speed_y)
  end
  
  #--------------------------------------------------------------------------
  # Update Move - Updates "normal" projectiles 
  #--------------------------------------------------------------------------
  def update_move
    self.x = screen_x
    self.y = screen_y
    update_move_arch if  @type == Arched
  end  

  #--------------------------------------------------------------------------
  # Update Move Arch - Updates arched projectiles
  #--------------------------------------------------------------------------
  def update_move_arch
    update_zvect
    self.y -= (Math::sin(@index/@div.to_f)*@high/8) 
  end

  #--------------------------------------------------------------------------
  # Update ZVect - Updates the camera based on current "frame" of animation
  #--------------------------------------------------------------------------
  def update_zvect
    return unless GTBS::PROJECTILE_CAM
    zvect = Math::sin(@index/@div.to_f)
    $game_map.set_display_pos($game_map.display_x, @base_y - (zvect * @high/2))
  end
  
  #--------------------------------------------------------------------------
  # Get Slope - determines the x/y slope to the target from the source
  #--------------------------------------------------------------------------
  def get_slope
    @speed_x = (@sx - @tx)/@slice.to_f
    @speed_y = (@sy - @ty)/@slice.to_f
  end
end


