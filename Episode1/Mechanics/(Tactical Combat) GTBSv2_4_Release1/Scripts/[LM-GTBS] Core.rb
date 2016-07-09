#==============================================================================
# ** Sprite_Battler_GTBS
#==============================================================================
module Layy_Meta
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def self.update_input
    if Input.press?(:F5) # TEST TODO
      self.map_rotation_angle += 1
    elsif Input.press?(:F6)
      self.map_rotation_angle -= 1
    elsif Input.trigger?(:F7) # [R5]
      self.to_zoom(2.0, 30)
    elsif Input.trigger?(:F8) # [R5]
      self.to_zoom(0.5, 30)
    elsif Input.trigger?(:CTRL) # [R5]
      self.to_zoom(1.0, 30)
    elsif SceneManager.scene_is?(Scene_Battle_TBS) && 
              SceneManager.scene.placement_done
      if Input.trigger?(:L)
        rotate_by(90, 15)
      elsif Input.trigger?(:R)
        rotate_by(-90, 15)
      end
    elsif SceneManager.scene_is?(Scene_Map)
      if Input.trigger?(:L)
        rotate_by(90, 30)
      elsif Input.trigger?(:R)
        rotate_by(-90, 30)
      end
    end
  end
end