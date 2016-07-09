#===============================================================================
# This Script is made specfically for usage with GTBS version 1.5.1.4 by GubiD.
#===============================================================================
class Sprite_GTBS_Shadow < Turn_Sprite
  Shadow_Image = "GTBS_Shadow"
  def initialize(viewport, battler)
    super(viewport)
    @character = battler
    self.z -= 1
    self.bitmap = Cache.system("Shadow")
    self.ox = self.bitmap.width/2
    self.oy = self.bitmap.height/2
    update
  end
  def update(x=@character.screen_x, y=@character.screen_y, z=@character.screen_z)
    if (!@character.floating? and !disposed?)
      dispose
      return
    end
    
    self.x = x
    self.y = y - 7 + @character.float_count
    ratio = 0
    case @character.float_count
    when 0
      ratio = 1.0
    when 1
      ratio = 0.90
    when 2
      ratio = 0.80
    when 3
      ratio = 0.70
    when 4
      ratio = 0.60
    when 5
      ratio = 0.50
    when 6
      ratio = 0.45
    end
    self.zoom_x = ratio
    self.zoom_y = ratio
    self.z = z-1
  end
end