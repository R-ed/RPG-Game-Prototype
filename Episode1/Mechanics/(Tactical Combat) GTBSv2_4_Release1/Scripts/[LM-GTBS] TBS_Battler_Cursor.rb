class TBS_Battler_Cursor < Turn_Sprite
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_lm_gtbs
    alias screen_x_mgc_lm_gtbs screen_x
    alias screen_y_mgc_lm_gtbs screen_y
    @already_aliased_mgc_lm_gtbs = true
  end
  #----------------------------------------------------------------------------
  # Screen X - Sets the current X location on the screen based on the map
  #----------------------------------------------------------------------------
  def screen_x
    unless Layy_Meta.active
      return screen_x_mgc_lm_gtbs
    else
      return @actor.lm_x
    end
  end
  #----------------------------------------------------------------------------
  # Screen Y - Sets the current Y location on the screen based on the map
  #----------------------------------------------------------------------------
  def screen_y
    unless Layy_Meta.active
      return screen_y_mgc_lm_gtbs
    else
      y = @actor.lm_y_h0
      y -= 40
      if @actor.unit_size > 1
        y += (@actor.unit_size - 1 << 4)
      end
      return y
    end
  end
end