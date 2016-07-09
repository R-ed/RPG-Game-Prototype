#==============================================================================
# ** Spriteset_Map
#==============================================================================
class Spriteset_Map
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_lm_gtbs
    alias update_event_sprites_mgc_lm_gtbs update_event_sprites
    alias draw_range_mgc_lm_gtbs draw_range
    alias dispose_tile_sprites_mgc_lm_gtbs dispose_tile_sprites
    @already_aliased_mgc_lm_gtbs = true
  end
  #--------------------------------------------------------------------------
  # * Update Event Sprites
  #--------------------------------------------------------------------------
  def update_event_sprites
    update_event_sprites_mgc_lm_gtbs
    if Layy_Meta.active
      need_refresh = false
      visible_sprites = []
      sprites = []
      if @actor_sprites
        sprites += @actor_sprites.values
      end
      if @enemy_sprites
        sprites += @enemy_sprites.values
      end
      if @event_sprites
        sprites += @event_sprites.values
      end
      sprites.each {|sprite|
        unless sprite.character.character_name == '' || !sprite.visible
          if sprite.lm_need_refresh
            need_refresh = true
          end
          if sprite.lm_visible
            sprite.visible = false
            visible_sprites << sprite.get_lm_data
          end
        end
      }
      if need_refresh
        visible_sprites.sort! {|a, b|
          a[2] - b[2] == 0 ? a[0] - b[0] : b[2] - a[2]
        }
        Layy_Meta.set_characters(visible_sprites)
      end
    end
  end
  #--------------------------------------------------------------------
  # * Draw range
  #--------------------------------------------------------------------
  def draw_range(range, type)
    unless Layy_Meta.active
      draw_range_mgc_lm_gtbs(range, type)
    else
      case type
      when 1; tone = Layy_Meta::GTBS_ATTACK_TONE
      when 2; tone = Layy_Meta::GTBS_MOVE_TONE
      when 3; tone = Layy_Meta::GTBS_HELP_SKILL_TONE
      when 4; tone = Layy_Meta::GTBS_ATTACK_SKILL_TONE
      when 5; tone = Layy_Meta::GTBS_ATTACK_SKILL_TONE
      when 6; tone = Layy_Meta::GTBS_HELP_SKILL_TONE
      when 7; tone = Layy_Meta::GTBS_ATTACK_TONE
      end
      unless @lm_range then @lm_range = [] end
      @lm_range += range
      for x, y in range
        $game_map.tile(x, y).set_tone(tone)
      end
    end
  end
  #----------------------------------------------------------------------------
  # * Dispose Tile Sprites
  #----------------------------------------------------------------------------
  def dispose_tile_sprites
    dispose_tile_sprites_mgc_lm_gtbs
    if Layy_Meta.active && @lm_range
      for x, y in @lm_range
        $game_map.tile(x, y).set_tone(Layy_Meta::GTBS_NO_TONE)
      end
      @lm_range.clear
    end
  end
end