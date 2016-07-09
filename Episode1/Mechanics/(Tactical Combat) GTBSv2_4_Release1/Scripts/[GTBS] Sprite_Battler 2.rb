class Sprite_Battler_GTBS < Sprite_Character
  #--------------------------------------------------------------------------
  # Imported Sprite_Battler methods (since I again, cannot modify the inheritance
  #--------------------------------------------------------------------------
  def update_whiten
    self.color.set(255, 255, 255, 0)
    self.color.alpha = 128 - (16 - @effect_duration) * 10
  end
  def update_blink
    self.opacity = (@effect_duration % 10 < 5) ? 255 : 0
  end
  def update_appear
    self.opacity = (16 - @effect_duration) * 16
  end
  def update_disappear
    self.opacity = 256 - (32 - @effect_duration) * 10
  end
  def update_collapse
    self.blend_type = 1
    self.color.set(255, 128, 128, 128)
    self.opacity = 256 - (48 - @effect_duration) * 6
  end
  def update_boss_collapse
    alpha = @effect_duration * 120 / bitmap.height
    #self.ox = bitmap.width / 2 + @effect_duration % 2 * 4 - 2
    self.blend_type = 1
    self.color.set(255, 255, 255, 255 - alpha)
    self.opacity = alpha
    self.src_rect.y -= 1
    Sound.play_boss_collapse2 if @effect_duration % 20 == 19
  end
  def update_instant_collapse
    self.opacity = 0
  end
  #-----------------------------------------------------------------------------
  # Start Effect - Copied from Sprite_Battler, with a couple changes. 
  #-----------------------------------------------------------------------------
  def start_effect(effect_type)
    @effect_type = effect_type
    case @effect_type
    when :appear
      @effect_duration = 16
      @battler_visible = true
    when :disappear
      @effect_duration = 32
      @battler_visible = false
    when :whiten
      @effect_duration = 16
      @battler_visible = true
    when :blink
      @effect_duration = 20
      @battler_visible = true
    when :collapse
      @effect_duration = 48
      @battler_visible = false
      check_bodies
    when :boss_collapse
      @effect_duration = bitmap.height
      @battler_visible = false
      check_bodies
    when :instant_collapse
      @effect_duration = 16
      @battler_visible = false
    end
    revert_to_normal
  end
  #-----------------------------------------------------------------------------
  # Check Bodies - reset's effects if battler collapse shouldn't rem from battle. 
  #-----------------------------------------------------------------------------
  def check_bodies
    if bat.actor? && $game_system.actors_bodies?
      @effect_type = nil
      @effect_duration = 0
    elsif !bat.actor? && $game_system.enemies_bodies?
      @effect_type = nil
      @effect_duration = 0
    end
  end  
end