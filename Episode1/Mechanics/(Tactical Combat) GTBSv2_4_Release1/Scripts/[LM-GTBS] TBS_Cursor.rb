class TBS_Cursor < POS
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_lm_gtbs
    alias update_mgc_lm_gtbs update
    alias valid_new_aoe_pos_mgc_lm_gtbs valid_new_aoe_pos
    @already_aliased_mgc_lm_gtbs = true
  end
  #------------------------------------------------------
  #* If active, check keyboard input
  #------------------------------------------------------
  def update
    unless Layy_Meta.active
      return update_mgc_lm_gtbs
    else
      return false unless @active
      nu_x, nu_y = @x, @y
      if Input.press?(Input::RIGHT)
        input_value = 6
      elsif Input.press?(Input::LEFT)
        input_value = 4
      elsif Input.press?(Input::DOWN)
        input_value = 2
      elsif Input.press?(Input::UP)
        input_value = 8
      end
      if input_value
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
        case input_value
        when 2
          nu_y += 1
        when 4
          nu_x -= 1
        when 6
          nu_x += 1
        when 8
          nu_y -= 1
        end
      end
      if (nu_x != @x or nu_y != @y) and $game_map.valid?(nu_x, nu_y)
        moveto(nu_x, nu_y)
        SceneManager.scene.update_target_cursor
        Layy_Meta.focus_on_coordinates(nu_x, nu_y, 8)
        Sound.play_cursor
        return true
      end
      return false
    end
  end
  #------------------------------------------------------------------------------
  # * [R3] [R4] check if tx, ty is a valid position
  #------------------------------------------------------------------------------
  def valid_new_aoe_pos(tx, ty, sx, sy, v_range_aoe) # mod MGC
    result = valid_new_aoe_pos_mgc_lm_gtbs(tx, ty, sx, sy, v_range_aoe) # mod MGC
    if (result && Layy_Meta.active)
      sAlt = $game_map.get_altitude(sx, sy)
      tAlt = $game_map.get_altitude(tx, ty)
      result = false if (tAlt - sAlt).abs > v_range_aoe # mod MGC
    end
    return result
  end
end