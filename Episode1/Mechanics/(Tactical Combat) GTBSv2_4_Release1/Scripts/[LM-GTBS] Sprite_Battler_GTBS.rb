#==============================================================================
# ** Sprite_Battler_GTBS
#==============================================================================
class Sprite_Battler_GTBS < Sprite_Character
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_lm
    alias initialize_mgc_lm_aprite_battler_gtbs initialize
    alias set_character_bitmap_mgc_lm_aprite_battler_gtbs set_character_bitmap
    
    alias update_position_mgc_lm_aprite_battler_gtbs update_position
    alias update_src_rect_mgc_lm_aprite_battler_gtbs update_src_rect
    
    alias get_direction_mgc_lm_aprite_battler_gtbs get_direction
    alias offset_large_unit_lm_aprite_battler_gtbs offset_large_unit
    @already_aliased_mgc_lm = true
  end
  #--------------------------------------------------------------------------
  # * Object Initialization
  # param viewport : Viewport
  # param character : Game_Character
  #--------------------------------------------------------------------------
  def initialize(viewport, character = nil)
    @lm_data = [0, 0, 0, 32, 32, 0]
    initialize_mgc_lm_aprite_battler_gtbs(viewport, character)
  end
  #--------------------------------------------------------------------------
  # * Set Character Bitmap
  #--------------------------------------------------------------------------
  def set_character_bitmap
    set_character_bitmap_mgc_lm_aprite_battler_gtbs
    if Layy_Meta::LM_OFFSET_SPRITES.has_key?(bat.character_name)
      offset_y = Layy_Meta::LM_OFFSET_SPRITES[bat.character_name]
    else
      offset_y = 0
    end
    #@lm_data[1] = y + offset_y
    #@lm_data[2] = lm_y_base + [offset_y, 0].max
    
    @lm_data[3] = @cw
    @lm_data[4] = @ch
    end_lm
    @lm_bitmap = Bitmap.new(@cw, @ch)
    @lm_data[5] = @lm_bitmap
    self.lm_need_refresh = true
  end
  #--------------------------------------------------------------------------
  # * Update Position
  #--------------------------------------------------------------------------
  def update_position
    if Layy_Meta.active
      old_x = x
      old_y = y
      update_position_mgc_lm_aprite_battler_gtbs
      update_lm
      self.z = @character.screen_z
      offset_large_unit
      move_animation(x - old_x, y - old_y)
    else
      update_position_mgc_lm_aprite_battler_gtbs
    end
  end
  #-------------------------------------------------------------
  # * Offset Large Unit
  #-------------------------------------------------------------
  def offset_large_unit
    if Layy_Meta.active
      self.y += 16*(@character.unit_size-1)
    else
      offset_large_unit_lm_aprite_battler_gtbs
    end
  end
  #-------------------------------------------------------------
  # * Get Direction
  #-------------------------------------------------------------
  def get_direction
    current_direction = dir = get_direction_mgc_lm_aprite_battler_gtbs
    if Layy_Meta.active
      current_direction = dir - 2 >> 1
      directions_list = [0, 1, 3, 2]
      current_direction = directions_list[(directions_list.index(
      current_direction) + ((Layy_Meta.map_rotation_angle + 45) % 360) /
      90) % 4] + 1 << 1
    end
    return (current_direction || 2)
  end
  #-------------------------------------------------------------
  # * Src Rect Method
  #-------------------------------------------------------------
  def update_src_rect
    sx_old = src_rect.x
    sy_old = src_rect.y
    update_src_rect_mgc_lm_aprite_battler_gtbs
    if Layy_Meta.active
      if src_rect.x != sx_old || src_rect.y != sy_old || lm_need_refresh
        @lm_bitmap.clear
        @lm_bitmap.blt(0, 0, bitmap, src_rect) 
        self.lm_need_refresh = true
      end
    end
  end
end