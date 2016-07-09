#----------------------------------------------------------------------------
# Sprite Character - This is updated so that events can be drawn on the map as 
#  well
#----------------------------------------------------------------------------
class Sprite_Character_GTBS < Sprite_Character
  attr_reader   :_damage_duration 
  attr_reader   :_animation_duration 
  
  def bat
    return @character
  end
end