#==============================================================================
# ** Game_Battler < Game_BattlerBase
#==============================================================================
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :lm_altitude, :lm_walkable_height, :lm_jumpable_height,
  :lm_max_fall_height
  attr_reader :lm_x, :lm_y, :lm_y_h0
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_lm
    alias init_public_members_mgc_lm init_public_members
    alias moving_mgc_lm? moving?
    alias screen_y_mgc_lm screen_y
    alias update_mgc_lm update
    alias jump_height_mgc_lm jump_height
    alias move_straight_mgc_lm move_straight
    alias run_path_mgc_lm_gtbs run_path
    alias jump_mgc_lm jump
    alias can_occupy_mgc_lm? can_occupy?
    alias valid_attack_pos_mgc_lm? valid_attack_pos?
    alias valid_new_spell_pos_mgc_lm valid_new_spell_pos
    alias bow_position_cost_mgc_lm bow_position_cost
    alias override_passable_mgc_lm? override_passable?
    alias move_climbable_mgc_lm? move_climbable?
    @already_aliased_mgc_lm = true
  end
  #--------------------------------------------------------------------------
  # * Jump
  #     x_plus : x-coordinate plus value
  #     y_plus : y-coordinate plus value
  #--------------------------------------------------------------------------
  def jump(x_plus, y_plus)
    if Layy_Meta.active
      return unless $game_map.valid?(x + x_plus, y + y_plus)
      @lm_altitude_start = $game_map.get_altitude(x, y)
      @in_jump = true # [R5]
    end
    jump_mgc_lm(x_plus, y_plus)
    if Layy_Meta.active
      @lm_altitude_end = $game_map.get_altitude(x, y)
    end
  end
  #--------------------------------------------------------------------------
  # * Initialize Public Member Variables
  #--------------------------------------------------------------------------
  def init_public_members
    init_public_members_mgc_lm
    self.lm_altitude = 0
    self.lm_walkable_height = Layy_Meta::LM_DEFAULT_WALKABLE_HEIGHT
    self.lm_jumpable_height = Layy_Meta::LM_DEFAULT_JUMPABLE_HEIGHT
    self.lm_max_fall_height = Layy_Meta::LM_DEFAULT_MAX_FALL_HEIGHT
    @lm_x = 0
    @lm_y = 0
    @lm_y_h0 = 0
  end
  #--------------------------------------------------------------------------
  # * Determine if Moving
  #--------------------------------------------------------------------------
  def moving?
    unless Layy_Meta.active
      return moving_mgc_lm?
    else
      return moving_mgc_lm? || @lm_falling
    end
  end
  #--------------------------------------------------------------------------
  # [R4] Move Climbable? - Stub for advanced movement techniques
  #--------------------------------------------------------------------------
  def move_climbable?(x2, y2, last_x=@x, last_y=@y, d=@direction, max_fall_height=false)
    unless Layy_Meta.active
      return move_climbable_mgc_lm?(x2,  y2, last_x, last_y, d, max_fall_height)
    else
      lm_altitude_start = $game_map.get_altitude(last_x, last_y, 10 - d)
      lm_altitude_end = $game_map.get_altitude(x2, y2, d)
      return false if lm_altitude_end - lm_altitude_start > lm_walkable_height
      return false if max_fall_height && lm_altitude_start - lm_altitude_end > lm_max_fall_height
      return true
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Passable for jump
  #     d : Direction (2,4,6,8)
  #--------------------------------------------------------------------------
  def jumpable?(x, y, d)
    if Layy_Meta.active
      x2 = $game_map.round_x_with_direction(x, d)
      y2 = $game_map.round_y_with_direction(y, d)
      return false unless $game_map.valid?(x2, y2)
      return true if @through || debug_through?
      return false unless map_passable?(x, y, d)
      return false unless map_passable?(x2, y2, reverse_dir(d))
      return false if collide_with_battlers?(x2, y2)
      lm_altitude_start = $game_map.get_altitude(x, y, 10 - d) # [R2]
      lm_altitude_end = $game_map.get_altitude(x2, y2, d) # [R2]
      return false if lm_altitude_end - lm_altitude_start > lm_jumpable_height
      return false if lm_altitude_start - lm_altitude_end > lm_max_fall_height
      return true
    end
  end
  #--------------------------------------------------------------------------
  # * Get Screen Y-Coordinates
  #--------------------------------------------------------------------------
  def screen_y
    unless Layy_Meta.active
      return screen_y_mgc_lm
    else
      return $game_map.adjust_y(@real_y) * 32 + 32 - shift_y
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    unless Layy_Meta.active
      update_mgc_lm
    else
      update_lm_altitude
      if self == Layy_Meta.focused_character && moving?
        Layy_Meta.force_translation
      end
      update_mgc_lm
      update_lm_position
    end
  end
  #--------------------------------------------------------------------------
  # Run Path - Used to process the determined path
  #--------------------------------------------------------------------------
  def run_path
    unless Layy_Meta.active
      run_path_mgc_lm_gtbs
    else
      if @move_route.size > 0 && Layy_Meta.focused_character != self
        Layy_Meta.focus_on_character(self)
      end
      run_path_mgc_lm_gtbs
    end
  end
  #--------------------------------------------------------------------------
  # * Calculate Jump Height
  #--------------------------------------------------------------------------
  def jump_height
    unless Layy_Meta.active
      return jump_height_mgc_lm
    else
      unless @lm_altitude_end
        @lm_altitude_end = 0
      end
      if @lm_altitude_end >= @lm_altitude_start
        if @jump_count > @jump_peak
          return @lm_altitude_start +
          @jump_count * (@jump_peak - (@jump_count >> 1)) * (@jump_peak *
          @jump_peak + (@lm_altitude_end - @lm_altitude_start << 1)) /
          (@jump_peak * @jump_peak)
        else
          return @lm_altitude_end + @jump_count * (@jump_peak -
          (@jump_count >> 1))
        end
      else
        return @lm_altitude_start + @jump_count * (@jump_peak -
        (@jump_count >> 1))
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Mise à jour de l'altitude
  #--------------------------------------------------------------------------
  def update_lm_altitude
    if jumping?
      self.lm_altitude = jump_height
    else
      @lm_altitude_target = $game_map.get_altitude_px(real_x, real_y) # [R2]
      if lm_altitude > @lm_altitude_target
        unless @lm_falling
          @lm_falling = true
          @lm_altitude_init = lm_altitude
          @lm_fall_duration = 0
        end
        @lm_fall_duration += 1
        self.lm_altitude = [@lm_altitude_init -
        @lm_fall_duration * @lm_fall_duration, @lm_altitude_target].max
      else
        self.lm_altitude = @lm_altitude_target
        @lm_falling = false
        @in_jump = false # [R5]
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Move Straight
  #     d:        Direction (2,4,6,8)
  #     turn_ok : Allows change of direction on the spot
  #--------------------------------------------------------------------------
  def move_straight(d, turn_ok = true)
    if Layy_Meta.active
      @move_succeed = passable?(@x, @y, d)
      unless @move_succeed
        @move_succeed = jumpable?(@x, @y, d)
        if @move_succeed
          set_direction(d)
          jump($game_map.round_x_with_direction(@x, d) - x,
          $game_map.round_y_with_direction(@y, d) - y)
          increase_steps
          return
        end
      end
    end
    move_straight_mgc_lm(d, turn_ok)
  end
  #--------------------------------------------------------------------------
  # * Mise à jour de la position dans le référentiel isométrique
  #--------------------------------------------------------------------------
  def update_lm_position
    ox = Graphics.width >> 1
    oy = Graphics.height >> 1
    x_screen = (real_x * 32).to_i + 16 - (Layy_Meta.display_x >> 3)
    y_screen = (real_y * 32).to_i + 16 - (Layy_Meta.display_y >> 3)
    y_lm = ((oy << 10) + ((y_screen - oy) * Layy_Meta.cos_angle +
    (x_screen - ox) * Layy_Meta.sin_angle) / 6 >> 10)
    x_lm = ((ox << 10) + ((x_screen - ox) * Layy_Meta.cos_angle -
    (y_screen - oy) * Layy_Meta.sin_angle) / 3 >> 10)
    unless Layy_Meta.zoom == 1.0 # [R5]
      x_lm = ox + ((x_lm - ox) * Layy_Meta.zoom).to_i
      y_lm = oy + ((y_lm - oy) * Layy_Meta.zoom).to_i
    end
    @lm_y_h0 = y_lm
    if Layy_Meta.zoom == 1.0 # [R5]
      @lm_y = y_lm - lm_altitude
    else
      @lm_y = y_lm - (lm_altitude * Layy_Meta.zoom).to_i
    end
    @lm_x = x_lm
    if self == Layy_Meta.focused_character && 
      (Layy_Meta.translation? || Layy_Meta.zooming?) # [R5]
    then
      x_lm = lm_x - (Layy_Meta.offset_x >> 3)
      if (x_lm - ox).abs > 1
        Layy_Meta.offset_x += x_lm - ox << 3
      end
      y_lm = lm_y_h0 - (Layy_Meta.offset_y >> 3)
      if (y_lm - oy).abs > 1
        Layy_Meta.offset_y += y_lm - oy << 3
      end
      if @in_jump && !Layy_Meta::LM_CAMERA_FOLLOW_JUMP
        lm_h = [@lm_altitude_end, lm_altitude].min # [R5]
        Layy_Meta.offset_h = (lm_h * Layy_Meta.zoom).to_i
      else
        Layy_Meta.offset_h = (lm_altitude * Layy_Meta.zoom).to_i # [R5]
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Mise à jour pendant la rotation/translation
  #--------------------------------------------------------------------------
  def update_for_lm_transition
    update
  end
  #--------------------------------------------------------------------------
  # * [R4] Override Passable - Stub for advanced movement technique add-ons. 
  #--------------------------------------------------------------------------
  def override_passable?(x, y, dir, nu_x, nu_y, flying_unit)
    unless Layy_Meta.active
      return override_passable_mgc_lm?(x, y, dir, nu_x, nu_y, flying_unit)
    else
      # WARNING : Should use this or override into passable? => MGC : this.
      return jumpable?(x, y, dir)
    end
  end
  #--------------------------------------------------------------------------
  # * [R4] Can Occupy - Used for large units
  #  Actor : Game_Battler
  #  Pos   : [x,y]
  #--------------------------------------------------------------------------
  def can_occupy?(pos)
    return false if !can_occupy_mgc_lm?(pos)
    # Altitude check all positions that this tile can be occupied by LargeUnit
    if Layy_Meta.active
      current_alt = $game_map.get_altitude(pos[0], pos[1])
      for ps in self.positions(pos[0], pos[1])
        pos_alt = $game_map.get_altitude(ps[0], ps[1])
        if (pos_alt - current_alt).abs > Layy_Meta::GTBS_LARGE_UNIT_ALT_VARIANCE
          return false
        end
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * [R4] check if tx, ty is a valid position
  #--------------------------------------------------------------------------
  def valid_attack_pos?(tx, ty, sx, sy)
    result = valid_attack_pos_mgc_lm?(tx, ty, sx, sy)
    if (result && Layy_Meta.active)
      sAlt = $game_map.get_altitude(sx, sy)
      tAlt = $game_map.get_altitude(tx, ty)
      result = false if (tAlt - sAlt).abs > weapon_range[5]
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * [R4] Bow Position Cost
  #--------------------------------------------------------------------------
  def bow_position_cost(offset_x, offset_y, sx, sy)
    cost = bow_position_cost_mgc_lm(offset_x, offset_y, sx, sy)
    if (Layy_Meta.active)
      sAlt = $game_map.get_altitude(sx, sy)
      tAlt = $game_map.get_altitude(sx + offset_x, sy + offset_y)
      # TODO: Check positions between sx,sy and sx+offset_x, sy+offset_y for
      # height change (reduce or addition to range) and landscape collisions (999 cost)
      #...
      # MGC : TODO indeed
      cost = [1, cost].max
    end
    return cost
  end
  #--------------------------------------------------------------------------
  # * [R3] [R4] check if tx, ty is a valid position
  #--------------------------------------------------------------------------
  def valid_new_spell_pos(tx, ty, sx, sy, v_range) # mod_MGC
    result = valid_new_spell_pos_mgc_lm(tx, ty, sx, sy, v_range) # mod_MGC
    if (result && Layy_Meta.active)
      tAlt = $game_map.get_altitude(tx, ty)
      sAlt = $game_map.get_altitude(sx, sy)
      result = false if (tAlt - sAlt).abs > v_range
    end
    return result
  end
end
