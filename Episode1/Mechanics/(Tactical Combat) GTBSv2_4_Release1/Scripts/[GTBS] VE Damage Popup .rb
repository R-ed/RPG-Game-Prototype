#==============================================================================
# ** Sprite_Battler_GTBS
#------------------------------------------------------------------------------
#  This sprite is used to display battlers. It observes a instance of the
# Game_Battler class and automatically changes sprite conditions.
#==============================================================================

class Sprite_Battler_GTBS < Sprite_Character
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  alias init_spr_bat_GTBS_dmg_sprite initialize
  def initialize(viewport, battler = nil)
    @damage_sprite = Game_Damage.new(viewport, bat, self) 
    init_spr_bat_GTBS_dmg_sprite(viewport, battler)
  end
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :update_effect_ve_damage_pop :setup_new_effect
  def setup_new_effect
    update_effect_ve_damage_pop
    return unless @character
    set_damage if bat.damaged || bat.missed
    @damage_sprite.update
  end
  #--------------------------------------------------------------------------
  # * New method: center_x
  #--------------------------------------------------------------------------
  def center_x
    self.ox
  end
  #--------------------------------------------------------------------------
  # * New method: center_y
  #--------------------------------------------------------------------------
  def center_y
    self.oy / 2
  end  
  #--------------------------------------------------------------------------
  # * Alias method: dispose
  #--------------------------------------------------------------------------
  alias :dispose_ve_damage_pop :dispose
  def dispose
    dispose_ve_damage_pop
    @damage_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * New method: set_damage
  #--------------------------------------------------------------------------
  def set_damage
    @damage_sprite.set_damage(bat) if bat 
    bat.clear_damage_flags
  end
  alias effect_gtbs_bat_dmg_pop effect?
  def effect?
    return true if @damage_sprite.showing?
    effect_gtbs_bat_dmg_pop
  end
end
#--------------------------------------------------------------------------
# Game Damage Extenstions
#--------------------------------------------------------------------------
class Game_Damage
  def showing?
    @damage_sprites.size > 0
  end
  #--------------------------------------------------------------------------
  def exp_gained
    return @battler.result.exp_gain_amt 
  end
  #--------------------------------------------------------------------------
  def doom
    return @battler.result.doom
  end
  #--------------------------------------------------------------------------
  # * damage_value
  #--------------------------------------------------------------------------
  alias damage_value_gtbs damage_value
  def damage_value
    return exp_gained if exp_gained  != ""
    return doom if doom != ""
    damage_value_gtbs
  end
  #--------------------------------------------------------------------------
  # * damage_type
  #--------------------------------------------------------------------------
  alias damage_type_gtbs damage_type
  def damage_type
    return :hp_recover if exp_gained != ""
    return :crt_text if doom != ""
    damage_type_gtbs
  end
end
#==============================================================================
# Game Enemy - Adding Hue function
#==============================================================================
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * New method: hue
  #--------------------------------------------------------------------------
  def hue
    @hue ? @hue : 0
  end
end

  