class TBS_Battler_Cursor < Turn_Sprite
  attr_reader   :map_x
  attr_reader   :map_y
  attr_reader   :real_x
  attr_reader   :real_y 
  #----------------------------------------------------------------------------
  # Object Initialization
  #----------------------------------------------------------------------------
  def initialize(viewport, actor)
    super(viewport)
    @actor = actor
    @iso = $game_map.iso?
    create_bitmap
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
    self.ox = self.bitmap.width / 2
    self.oy = self.bitmap.height
    update
  end
  #----------------------------------------------------------------------------
  # MoveTo - Sets the X,Y position of the cursor
  #----------------------------------------------------------------------------
  def moveto(x, y)
    @map_x = x % $game_map.width
    @map_y = y % $game_map.height
    @real_x = @map_x
    @real_y = @map_y
  end
  #----------------------------------------------------------------------------
  # Screen X - Sets the current X location on the screen based on the map
  #----------------------------------------------------------------------------
  def screen_x
    return @actor.screen_x
  end
  #----------------------------------------------------------------------------
  # Screen Y - Sets the current Y location on the screen based on the map
  #----------------------------------------------------------------------------
  def screen_y
    y = @actor.screen_y
    y-= 40
    if @actor.unit_size > 1
      y += 16*(@actor.unit_size-1)
    end
    return y
  end
  #----------------------------------------------------------------------------
  # Screen Z - Sets the Z location based on the map
  #----------------------------------------------------------------------------
  def screen_z(height = 0)
    return @actor.screen_z + 1
  end
  def dispose
    @actor.targeted = nil
    super
  end
end