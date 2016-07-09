#----------------------------------------------------------------------------
# Battle Cursor - Used to navigate the map during battle
#----------------------------------------------------------------------------
class Battle_Cursor < Sprite_Base
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_lm_gtbs
    alias update_mgc_lm_gtbs update
    alias clear_target_sprites_mgc_lm_gtbs clear_target_sprites
    alias draw_target_sprites_mgc_lm_gtbs draw_target_sprites
    @already_aliased_mgc_lm_gtbs = true
  end
  #----------------------------------------------------------------------------
  # Update Process
  #----------------------------------------------------------------------------
  def update
    if Layy_Meta.active
      if @map_x != $tbs_cursor.x || @map_y != $tbs_cursor.y
        has_moved = true
        $game_map.tile(@map_x, @map_y).deselect
      else
        has_moved = false
      end
    end
    update_mgc_lm_gtbs
    if Layy_Meta.active
      if visible && (has_moved ||
        $game_map.tile(@map_x, @map_y).colored_faces != 33)
      then
        tile = $game_map.tile(@map_x, @map_y)
        tile.select
      end
      self.visible = false
    end
  end
  #------------------------------------------------------------------
  #* draw and clear ranges sprites
  #------------------------------------------------------------------
  def clear_target_sprites
    clear_target_sprites_mgc_lm_gtbs
    if Layy_Meta.active && @lm_range
      for x, y in @lm_range
        unless $game_map.tile(x, y).tone == Layy_Meta::GTBS_NO_TONE
          $game_map.tile(x, y).set_previous_tone
        end
      end
      @lm_range.clear
    end
  end
  #------------------------------------------------------------------
  #* draw ranges sprites
  #------------------------------------------------------------------
  def draw_target_sprites
    unless Layy_Meta.active
      draw_target_sprites_mgc_lm_gtbs
    else
      type = @cursor.target_area[0]
      return unless type
      case type
      when 1; tone = Layy_Meta::GTBS_ATTACK_ST_TONE
      when 2; tone = Layy_Meta::GTBS_MOVE_ST_TONE
      when 3; tone = Layy_Meta::GTBS_HELP_SKILL_ST_TONE
      when 4; tone = Layy_Meta::GTBS_ATTACK_SKILL_ST_TONE
      when 5; tone = Layy_Meta::GTBS_ATTACK_SKILL_ST_TONE
      when 6; tone = Layy_Meta::GTBS_HELP_SKILL_ST_TONE
      when 7; tone = Layy_Meta::GTBS_ATTACK_ST_TONE
      end
      unless @lm_range then @lm_range = [] end
      @lm_range += @cursor.target_positions
      for x, y in @cursor.target_positions
        $game_map.tile(x, y).set_tone(tone, 1, false)
      end
    end
  end
end