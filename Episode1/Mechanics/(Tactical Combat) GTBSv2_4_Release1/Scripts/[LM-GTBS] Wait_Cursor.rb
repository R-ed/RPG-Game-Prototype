#----------------------------------------------------------------------------
# Wait Cursor - This is the WAIT DIRECTION image that appears over battlers
#    when they select the WAIT command
#----------------------------------------------------------------------------
class Wait_Cursor < TBS_Battler_Cursor
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_lm_gtbs
    alias update_bitmap_mgc_lm_gtbs update_bitmap
    alias update_mgc_lm_gtbs update
    @already_aliased_mgc_lm_gtbs = true
  end
  #----------------------------------------------------------------------------
  # * Update Process
  #----------------------------------------------------------------------------
  def update
    if Layy_Meta.active
      super
      if Input.trigger?(Input::DOWN)
        input_value = 2
      elsif Input.trigger?(Input::LEFT)
        input_value = 4
      elsif Input.trigger?(Input::RIGHT)
        input_value = 6
      elsif Input.trigger?(Input::UP)
        input_value = 8
      else
        update_bitmap
        return
      end
      case Layy_Meta.map_rotation_angle
      when 46...136
        camera_direction = 6
      when 136...226
        camera_direction = 2
      when 226...316
        camera_direction = 4
      else
        camera_direction = 8
      end
      case camera_direction
      when 2
        input_value = 10 - input_value
      when 4
        input_value = 10 - Input::Left[(input_value >> 1) - 1]
      when 6
        input_value = Input::Left[(input_value >> 1) - 1]
      when 8
        input_value = input_value
      end
      @actor.set_direction(input_value)
      moveto(@actor.x, @actor.y)
      update_bitmap
      self.x = screen_x
      self.y = screen_y
      self.z = screen_z
    else
      update_mgc_lm_gtbs
    end
  end
  #----------------------------------------------------------------------------
  # Updates the bitmap based on the current direction of the actor
  #----------------------------------------------------------------------------
  def update_bitmap
    if Layy_Meta.active
      relative_direction = @actor.direction - 2 >> 1
      directions_list = [0, 1, 3, 2]
      relative_direction = (directions_list[(directions_list.index(
      relative_direction) + (Layy_Meta.map_rotation_angle % 360) /
      90) % 4] << 1) + 2
      unless @direction == relative_direction
        @direction = relative_direction
        bitmap.dispose if bitmap && !bitmap.disposed?
        self.bitmap = Cache.picture(sprintf("GTBS/wait_iso%d",
        relative_direction))
      end
    else
      update_bitmap_mgc_lm_gtbs
    end
  end
end