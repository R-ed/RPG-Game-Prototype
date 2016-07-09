
#==============================================================================
# ** Victor Engine - Damage Popup
#------------------------------------------------------------------------------
# Author : Victor Sant
# Modified by: Martin Gubler *GubiD 
#
# Version History:
#  v 1.00 - 2011.12.19 > First relase
#  v 1.01 - 2011.12.21 > Added bold and Italic options for text
#  v 1.02 - 2011.12.30 > Faster Regular Expressions
#  v 1.03 - 2012.01.18 > Added compatibility with Skip Battle Log
#  v 1.04 - 2012.01.28 > Fixed zero damage displayed on status effect actions
#                      > Fixed drain value not displayed
#  v 1.05 - 2012.01.30 > Fixed debuff value not displayed
#  v 1.06 - 2012.07.17 > Compatibility with Basic Module 1.24
#                      > Individual duration for each pop up type
#  v 1.07 - 2012.07.18 > Compatibility with Retaliation Damage
#  v 1.08 - 2012.08.02 > Compatibility with Custom Slip Effect
#  v 1.09 - 2012.08.18 > Compatibility with Custom Hit Formula
#  v 1.09.1 - 2012.12.2 > Removed basic module requirement. 
#------------------------------------------------------------------------------
#  This script adds an popup system to damage diplay. Allowing to view
# the damage and states change with visible digits that pop from target.
# It's possible an extensive edition of this display.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v1.27 or higher
#   If used with 'Victor Engine - Custom Slip Effect' place this bellow it.
#   If used with 'Victor Engine - Custom Hit Formula' place this bellow it.
#
# * Overwrite methods
#   class Window_BattleLog < Window_Selectable
#     def display_critical(target, item)
#
# * Alias methods
#   class Game_ActionResult
#     def clear_damage_values
#
#   class Game_Battler < Game_BattlerBase
#     def item_element_rate
#     def regenerate_hp
#     def regenerate_mp
#     def regenerate_tp
#     def item_apply(user, item)
#     def execute_damage(user)
#     def remove_states_auto(timing)
#
#   class Sprite_Battler
#     def initialize(viewport, battler = nil)
#     def update_effect
#     def dispose
#
#   class Scene_Battle < Scene_Base
#     def invoke_counter_attack(target, item)
#     def invoke_magic_reflection(target, item)
#     def apply_substitute
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# States note tags
#   Tags to be used on the States note box in the database
#  
#  <no display add>
#  <no display rmv>
#   This allows to hide the state popup display.
#
#  <damage behavior: x>
#   This tag change the behavior of the damage display of the state,
#   x must be a text with the name of the new behavior, the new behavior
#   must be set previously on the settings module
#    
#  <add color: r, g, b>
#   This will change the color of the text when inflicting a state.
#     r : red   (0-255)
#     g : green (0-255)
#     b : blue  (0-255)
#
#  <remove color: r, g, b>
#   This will change the color of the text when losing a state.
#     r : red   (0-255)
#     g : green (0-255)
#     b : blue  (0-255)
#
#------------------------------------------------------------------------------
# Skills and Items note tags
#   Tags to be used on the Skills and Items note box in the database
#
#  <damage behavior: x>
#   This will change the behavior of the damage display of the action,
#   x must be a text with the name of the new behavior, the new behavior
#   must be set previously on the settings module
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  Custom display behaviors must be set on the following constant of the
#  settings module, otherwise it will return erros:
#    - VE_DAMAGE_TEXTS (if VE_DAMAGE_DISPLAY = :text)
#    - VE_DAMAGE_IMGS  (if VE_DAMAGE_DISPLAY = :image)
#    - VE_DAMAGE_MOVE
#
#==============================================================================
 
#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine  
  #--------------------------------------------------------------------------
  # * Deteremine the damage display
  #    It's posssible to choose between texts drawn by the RPG Maker
  #    (draw_text) or specific images
  #    :text  : display by text, the settings are done on Damage_Text.
  #    :image : display by image, the settings are done on Damage_Images.
  #      It's needed to create a new folder on 'Graphics' folder named 'Digits'
  #--------------------------------------------------------------------------
  VE_DAMAGE_DISPLAY = :text
  #--------------------------------------------------------------------------
  # * Set popup custom text constants
  #--------------------------------------------------------------------------
  VE_HP_DAMAGE    = "%s"       # HP damage text   (use %s to show the value)
  VE_MP_DAMAGE    = "%s"       # MP damage text   (use %s to show the value)
  VE_TP_DAMAGE    = "%s"       # TP damage text   (use %s to show the value)
  VE_HP_RECOVER   = "%s"       # HP recovery text (use %s to show the value)
  VE_MP_RECOVER   = "%s"       # MP recovery text (use %s to show the value)
  VE_TP_RECOVER   = "%s"       # TP recovery text (use %s to show the value)
  VE_MISS_TEXT    = "Miss"     # Miss text
  VE_EVADE_TEXT   = "Evade"    # Evade text
  VE_CRT_TEXT     = "Critical" # Critical text   (only if CTR_POP = true)
  VE_WEAK_TEXT    = "Weak"     # Weakness text   (only if RESIST_POP = true)
  VE_RESIST_TEXT  = "Resist"   # Resistance text (only if RESIST_POP = true)
  VE_IMUNE_TEXT   = "Imune"    # Imune text      (only if RESIST_POP = true)
  VE_ABSORB_TEXT  = "Absorb"   # Absorb text     (only if RESIST_POP = true)
  VE_COUNTER_TEXT = "Counter"  # Counter attack text
  VE_REFLECT_TEXT = "Reflect"  # Reflect magic text
  VE_COVER_TEXT   = "Covered"  # Cover text
  VE_STATE_ADD    = "+%s"      # Add state text    (use %s to show state name)
  VE_STATE_REMOVE = "-%s"      # Remove state text (use %s to show state name)
  VE_BUFF_ADD     = "%s +1"    # Buff text   (use %s to show status name)
  VE_DEBUFF_ADD   = "%s -1"    # DeBuff text (use %s to show status name)
  VE_BUFF_RMV     = "%s "      # Clear buff text (use %s to show status name)
  #--------------------------------------------------------------------------
  # * Set popup boleans constants (true/false)
  #    The critical text (VE_CRT_POP) and resistance texts (VE_RESIST_POP)
  #    don't have the multi pop effect (VE_MULTI_POP), so it's advised to
  #    not use these options activated toghter.
  #--------------------------------------------------------------------------
  VE_DIGIT_ROLL  = false # Digit roll during the start of display
  VE_FAST_ROLL   = false # Fast digit roll (may cause lag)
  VE_DIGIT_EACH  = false # Digits shown in sequence
  VE_MULTI_POP   = false # Digits with delay
  VE_COUNTER_POP = true  # Show counter popup message
  VE_REFLECT_POP = true  # Show reflect popup message
  VE_COVER_POP   = true  # Show covered popup message
  VE_CRT_FLASH   = true  # Flash effect for critical damage
  VE_CRT_POP     = true  # Show critical text with critical damage
  VE_RESIST_POP  = true  # Show resist text with normal damage
  VE_HEIGHT_ADJ  = true  # Adjust position based on target graphic height
  VE_AUTO_ADJ    = true  # Adjust height if there is various damage diplays
  #--------------------------------------------------------------------------
  # * Set popup numeric values constants
  #--------------------------------------------------------------------------
  VE_DIGIT_SPACE = 0  # Space between the digits on the display
  #--------------------------------------------------------------------------
  # * Set values for text damage display (VE_DAMAGE_DISPLAY = :text)
  #--------------------------------------------------------------------------
  VE_DAMAGE_TEXTS = {
    # Type      [ Red, Green, Blue, Size, Wait, Bold, Italic, Font],
    default:    [ 255,   255,  255,   32,   50, true,  false, Font.default_name],
    hp_damage:  [ 255,   255,  255,   32,   50, true,  false, Font.default_name],
    mp_damage:  [ 128,    96,  255,   32,   50, true,  false, Font.default_name],
    tp_damage:  [  96,   192,   96,   32,   50, true,  false, Font.default_name],
    hp_recover: [ 160,   255,  128,   32,   80, true,  false, Font.default_name],
    mp_recover: [ 255,   128,  255,   32,   50, true,  false, Font.default_name],
    tp_recover: [ 128,   255,  224,   32,   50, true,  false, Font.default_name],
    miss_text:  [ 160,   160,  160,   32,   50, true,  false, Font.default_name],
    eva_text:   [ 160,   160,  160,   32,   50, true,  false, Font.default_name],
    crt_damage: [ 255,    96,    0,   36,   50, true,  false, Font.default_name],
    crt_text:   [ 255,   128,   96,   22,   50, true,  false, Font.default_name],
    weakness:   [ 255,   128,  128,   22,   50, true,  false, Font.default_name],
    resist:     [ 128,   255,  255,   22,   50, true,  false, Font.default_name],
    imune:      [ 160,   160,  160,   22,   50, true,  false, Font.default_name],
    absorb:     [ 128,   255,  128,   22,   50, true,  false, Font.default_name],
    counter:    [ 255,   192,  128,   22,   50, true,  false, Font.default_name],
    reflect:    [ 128,   192,  255,   22,   50, true,  false, Font.default_name],
    covered:    [ 192,   255,  128,   22,   50, true,  false, Font.default_name],
    state_add:  [ 255,   255,  128,   22,   50, true,  false, Font.default_name],
    state_rmv:  [ 128,   255,  255,   22,   50, true,  false, Font.default_name],
    buff_add:   [ 255,   255,  128,   22,   50, true,  false, Font.default_name],
    debuff_add: [ 255,   128,  128,   22,   50, true,  false, Font.default_name],
    buff_rmv:   [ 128,   255,  255,   22,   50, true,  false, Font.default_name],
  } # Don't remove
  #--------------------------------------------------------------------------
  # * Set values for text damage display (VE_DAMAGE_DISPLAY = :image)
  #    For critical text (:crt_text), resists (:weakness, :resist, imune, 
  #    :absorb) and state change (:state_add, :state_rmv, :buff_add, )
  #    and , use a single image for the whole text, for the others (including
  #    miss and evade text), use a singe image for each digit.
  #--------------------------------------------------------------------------
  VE_DAMAGE_IMGS = {
   #type:       [Wait, "sufix"],
    default:    [  50, ""],        # Default text
    hp_damage:  [  50, ""],        # HP damage
    sp_damage:  [  50, "_mp"],     # MP damage
    tp_damage:  [  50, "_tp"],     # TP damage
    hp_recover: [  50, "_heal"],   # HP recover
    sp_recover: [  50, "_mpheal"], # MP recover
    tp_recover: [  50, "_tpheal"], # TP recover
    miss_text:  [  50, "_miss"],   # Miss text
    eva_text:   [  50, "_evade"],  # Evade text
    crt_damage: [  50, "_crtdmg"], # Critical damage
    crt_text:   [  50, "_crttxt"], # Critical text
    weakness:   [  50, "_weak"],   # Weakness text
    resist:     [  50, "_resist"], # Resist text
    imune:      [  50, "_imune"],  # Imune text
    absorb:     [  50, "_absorb"], # Absorb text
    counter:    [  50, "_cntr"],   # Counter text
    reflect:    [  50, "_rflct"],  # Reflection text
    covered:    [  50, "_cover"],  # Cover text
    state_add:  [  50, "_addst"],  # State add text
    state_rmv:  [  50, "_rmvst"],  # State remove text
    buff_add:   [  50, "_addbf"],  # Buff text
    debuff_add: [  50, "_adddbf"], # Debuff text
    buff_rmv:   [  50, "_rmvbf"],  # Clear buff text
  } # Don't remove
  #--------------------------------------------------------------------------
  # * Set damage display behavior
  #    The damage display have 3 phases: Start, Middle and End.
  #    It's possible to set diffent behaviors for each of these phases
  #    The behaviors are set on the VE_POP_BEHAVIOR constant bellow
  #--------------------------------------------------------------------------
  VE_DAMAGE_MOVE = {
   #type:       [  Start, Middle,    Fim],
    default:    [  :wait,  :wait,  :wait], # Default text
    hp_damage:  [  :pop1,  :pop2,  :wait], # HP damage
    mp_damage:  [  :pop1,  :pop2,  :wait], # MP damage
    tp_damage:  [  :pop1,  :pop2,  :wait], # TP damage
    hp_recover: [ :zoom1,    :up,    :up], # HP recover
    mp_recover: [  :up_l,  :up_r,  :up_l], # MP recover
    tp_recover: [  :up_l,  :up_r,  :up_l], # TP recover
    miss_text:  [  :wait,  :wait,  :wait], # Miss text
    eva_text:   [  :wait,  :wait,  :wait], # Evade text
    crt_damage: [ :zoom1,  :wait, :rise1], # Critical damage
    crt_text:   [ :zoom2,  :wait, :rise2], # Critical text
    weakness:   [ :above,  :pop2,  :wait], # Weakness text
    resist:     [ :above,  :pop2,  :wait], # Resist text
    imune:      [ :above,  :pop2,  :wait], # Imune text
    absorb:     [ :zoom2,    :up,    :up], # Absorb text
    counter:    [    :up,  :wait,  :wait], # Counter text
    reflect:    [    :up,  :wait,  :wait], # Reflection text
    covered:    [    :up,  :wait,  :wait], # Cover text
    state_add:  [  :wait,  :wait,  :wait], # State add text
    state_rmv:  [  :wait,  :wait,  :wait], # State remove text
    buff_add:   [  :wait,  :wait,  :wait], # Buff add text
    debuff_add: [  :wait,  :wait,  :wait], # Debuff add text
    buff_rmv:   [  :wait,  :wait,  :wait], # Clear buff add text
  } # Don't remove
  #--------------------------------------------------------------------------
  # * Set the damage pop behavior for each phase
  #    ZoomX  : vertical zoom
  #    ZoomY  : horizontal zoom
  #    StartX : initial coordinate X (valid only for the Start phase)
  #    StartY : initial coordinate Y (valid only for the Start phase)
  #    MoveX  : horizontal movment
  #    MoveY  : vertical movement
  #    Gravt  : gravity effect (makes the damage "jumps")
  #    Random : random horizontal movement
  #--------------------------------------------------------------------------
  VE_POP_BEHAVIOR = {
   #type:  [ZoomX, ZoomY, StartX, StartY, MoveX, MoveY, Gravt, Random],
    wait:  [  1.0,   1.0,    0.0,    0.0,   0.0,   0.0,   0.0,  false],
    zoom1: [  2.0,   2.0,    0.0,    0.0,   0.0,   0.0,   0.0,  false],
    zoom2: [  2.0,   2.0,    0.0,   -8.0,   0.0,   0.0,   0.0,  false],
    rise1: [  1.0,   3.0,    0.0,    0.0,   0.0,  -2.0,   0.0,  false],
    rise2: [  1.0,   3.0,    0.0,    0.0,   0.0,  -5.0,   0.0,  false],
    up:    [  1.0,   1.0,    0.0,    0.0,   0.0,  -3.0,   0.0,  false],
    pop1:  [  1.0,   1.0,    0.0,    0.0,   0.0,   1.0,   4.0,  false],
    pop2:  [  1.0,   1.0,    0.0,    0.0,   0.0,   0.5,   2.0,  false],
    above: [  1.0,   1.0,    0.0,   -8.0,   0.0,   1.0,   4.0,  false],
    up_r:  [  1.0,   1.0,    0.0,    0.0,   1.0,  -1.0,   0.0,  false],
    up_l:  [  1.0,   1.0,    0.0,    0.0,  -1.0,  -1.0,   0.0,  false],
  } # Don't remove
  #--------------------------------------------------------------------------
  # * required
  #   This method checks for the existance of the basic module and other
  #   VE scripts required for this script to work, don't edit this
  #--------------------------------------------------------------------------
  def self.required(name, req, version, type = nil)
    if !$imported[:ve_basic_module]
      msg = "The script '%s' requires the script\n"
      msg += "'VE - Basic Module' v%s or higher above it to work properly\n"
      msg += "Go to http://victorscripts.wordpress.com/ to download this script."
      msgbox(sprintf(msg, self.script_name(name), version))
      exit
    else
      self.required_script(name, req, version, type)
    end
  end
  #--------------------------------------------------------------------------
  # * script_name
  #   Get the script name base on the imported value, don't edit this
  #--------------------------------------------------------------------------
  def self.script_name(name, ext = "VE")
    name = name.to_s.gsub("_", " ").upcase.split
    name.collect! {|char| char == ext ? "#{char} -" : char.capitalize }
    name.join(" ")
  end
end

$imported ||= {}
$imported[:ve_damage_pop] = 1.09
#Victor_Engine.required(:ve_damage_pop, :ve_basic_module, 1.27, :above)

#==============================================================================
# ** Cache
#------------------------------------------------------------------------------
#  This module loads each of graphics, creates a Bitmap object, and retains it.
# To speed up load times and conserve memory, this module holds the created
# Bitmap object in the internal hash, allowing the program to return
# preexisting objects when the same bitmap is requested again.
#==============================================================================

module Cache
  #--------------------------------------------------------------------------
  # * New method: digits
  #--------------------------------------------------------------------------
  def self.digits(filename)
    load_bitmap("Graphics/Digits/", filename)
  end
end

#==============================================================================
# ** Game_Action
#------------------------------------------------------------------------------
#  This class handles battle actions. This class is used within the
# Game_Battler class.
#==============================================================================

class Game_Action
  #--------------------------------------------------------------------------
  # * Alias method: evaluate_item_with_target
  #--------------------------------------------------------------------------
  alias :evaluate_item_with_target_ve_damage_pop :evaluate_item_with_target
  def evaluate_item_with_target(target)
    result = evaluate_item_with_target_ve_damage_pop(target)
    target.result.clear
    result
  end
end

#==============================================================================
# ** Game_ActionResult
#------------------------------------------------------------------------------
#  This class handles the results of actions. This class is used within the
# Game_Battler class.
#==============================================================================

class Game_ActionResult
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :resist
  attr_accessor :tp_drain
  #--------------------------------------------------------------------------
  # * Alias method: clear_damage_values
  #--------------------------------------------------------------------------
  alias :clear_damage_values_ve_damage_pop :clear_damage_values
  def clear_damage_values
    clear_damage_values_ve_damage_pop
    @resist   = nil
    @tp_drain = 0
  end
end

#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  This class deals with battlers. It's used as a superclass of the Game_Actor
# and Game_Enemy classes.
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :damaged
  attr_accessor :counter
  attr_accessor :reflect
  attr_accessor :covered
  attr_accessor :missed
  attr_accessor :no_dmg
  #--------------------------------------------------------------------------
  # * Alias method: item_element_rate
  #--------------------------------------------------------------------------
  alias :item_element_rate_ve_damage_pop :item_element_rate
  def item_element_rate(user, item)
    result = item_element_rate_ve_damage_pop(user, item)
    @result.resist = :weakness if result > 1.0
    @result.resist = :resist   if result < 1.0 && result > 0.0
    @result.resist = :imune    if result == 0.0
    @result.resist = :absorb   if result < 0.0
    result
  end
  #--------------------------------------------------------------------------
  # * Alias method: item_apply
  #--------------------------------------------------------------------------
  alias :item_apply_ve_damage_pop :item_apply
  def item_apply(user, item)
    item_apply_ve_damage_pop(user, item)
    @damaged = ($game_party.in_battle && @result.hit?)
    @missed  = ($game_party.in_battle && alive? && !@result.hit?)
    @no_dmg  = item.damage.none?
  end
  #--------------------------------------------------------------------------
  # * Alias method: regenerate_hp
  #--------------------------------------------------------------------------
  alias :regenerate_hp_ve_damage_pop :regenerate_hp
  def regenerate_hp
    regenerate_hp_ve_damage_pop
    @damaged |= $game_party.in_battle && damaged?
  end
  #--------------------------------------------------------------------------
  # * Alias method: regenerate_mp
  #--------------------------------------------------------------------------
  alias :regenerate_mp_ve_damage_pop :regenerate_mp
  def regenerate_mp
    regenerate_mp_ve_damage_pop
    @damaged |= $game_party.in_battle && damaged?
  end
  #--------------------------------------------------------------------------
  # * Alias method: regenerate_tp
  #--------------------------------------------------------------------------
  alias :regenerate_tp_ve_damage_pop :regenerate_tp
  def regenerate_tp
    regenerate_tp_ve_damage_pop
    @result.tp_damage = -mtp * trg unless $imported[:ve_custom_slip_effect]
    @damaged |= $game_party.in_battle && damaged?
  end
  #--------------------------------------------------------------------------
  # * Alias method: execute_damage
  #--------------------------------------------------------------------------
  alias :execute_damage_tp_ve_damage_pop :execute_damage
  def execute_damage(user)
    execute_damage_tp_ve_damage_pop(user)
    if @result.hp_drain != 0 || @result.mp_drain != 0
      user.damaged = true
      user.result.hp_damage = -@result.hp_drain
      user.result.mp_damage = -@result.mp_drain
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: remove_states_auto
  #--------------------------------------------------------------------------
  alias :remove_states_auto_ve_damage_pop :remove_states_auto
  def remove_states_auto(timing)
    old_states = states.dup
    remove_states_auto_ve_damage_pop(timing)
    @damaged |= $game_party.in_battle && old_states != states.dup
    @no_dmg   = @result.hp_damage == 0 || @result.mp_drain == 0
  end
  #--------------------------------------------------------------------------
  # * New method: clear_damage_flags
  #--------------------------------------------------------------------------
  def clear_damage_flags
    @damaged = false
    @counter = false
    @reflect = false
    @covered = false
    @missed  = false
    @no_dmg  = false
  end
end

#==============================================================================
# ** Sprite_Battler
#------------------------------------------------------------------------------
#  This sprite is used to display battlers. It observes a instance of the
# Game_Battler class and automatically changes sprite conditions.
#==============================================================================

class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_damage_pop :initialize
  def initialize(viewport, battler = nil)
    initialize_ve_damage_pop(viewport, battler)
    @damage_sprite = Game_Damage.new(viewport, @battler, self) 
  end
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :update_effect_ve_damage_pop :update_effect
  def update_effect
    update_effect_ve_damage_pop
    set_damage if @battler.damaged || @battler.missed
    @damage_sprite.update
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
    @damage_sprite.set_damage(@battler) if @battler && @battler.use_sprite?
    @battler.clear_damage_flags
  end
end

#==============================================================================
# ** Window_BattleLog
#------------------------------------------------------------------------------
#  This window shows the battle progress. Do not show the window frame.
#==============================================================================

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # * Overwrite method: display_critical
  #--------------------------------------------------------------------------
  def display_critical(target, item)
    if target.result.critical
      color = [255, 255, 255, 192] if VE_CRT_FLASH
      $game_troop.screen.start_flash(Color.new(*color), 10) if VE_CRT_FLASH
      text = target.actor? ? Vocab::CriticalToActor : Vocab::CriticalToEnemy
      add_text(text) unless $imported[:ve_skip_log] && !VE_CRITICAL_MESSAGE
    end
  end  
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Alias method: invoke_counter_attack
  #--------------------------------------------------------------------------
  alias :invoke_counter_attack_ve_damage_pop :invoke_counter_attack
  def invoke_counter_attack(target, item)
    target.counter = true if VE_COUNTER_POP && counter_pop_up?(target, item)
    target.damaged = true if VE_COUNTER_POP && counter_pop_up?(target, item)
    invoke_counter_attack_ve_damage_pop(target, item)
  end
  #--------------------------------------------------------------------------
  # * Alias method: invoke_magic_reflection
  #--------------------------------------------------------------------------
  alias :invoke_magic_reflection_ve_damage_pop :invoke_magic_reflection
  def invoke_magic_reflection(target, item)
    target.reflect = true if VE_REFLECT_POP && reflect_pop_up?(target, item)
    target.damaged = true if VE_REFLECT_POP && reflect_pop_up?(target, item)
    invoke_magic_reflection_ve_damage_pop(target, item)
  end
  #--------------------------------------------------------------------------
  # * Alias method: apply_substitute
  #--------------------------------------------------------------------------
  alias :apply_substitute_ve_damage_pop :apply_substitute
  def apply_substitute(target, item)
    new_target = apply_substitute_ve_damage_pop(target, item)
    target.covered = true if new_target != target && VE_COVER_POP
    target.damaged = true if new_target != target && VE_COVER_POP
    new_target
  end
  #--------------------------------------------------------------------------
  # * New method: counter_pop_up?
  #--------------------------------------------------------------------------
  def counter_pop_up?(target, item)
    !$imported[:ve_retaliation_damage] || !damage_on_counter?(target, item)
  end
  #--------------------------------------------------------------------------
  # * New method: reflect_pop_up?
  #--------------------------------------------------------------------------
  def reflect_pop_up?(target, item)
    !$imported[:ve_retaliation_damage] || !damage_on_reflect?(target, item)
  end
end

#==============================================================================
# ** Game_Damage
#------------------------------------------------------------------------------
#  This class handles the damage display. This class is used within the 
# Sprite_Battler.
#==============================================================================

class Game_Damage
  include Victor_Engine
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, battler, sprite)
    @x   = 0
    @y   = 0
    @exw = 0
    @viewport = viewport
    @battler  = battler
    @sprite   = sprite
    @damage_sprites = []
  end
  #--------------------------------------------------------------------------
  # * results
  #--------------------------------------------------------------------------
  def result
    @battler.result
  end
  #--------------------------------------------------------------------------
  # * hp_damage
  #--------------------------------------------------------------------------
  def hp_damage
    result.hp_damage.abs
  end
  #--------------------------------------------------------------------------
  # * mp_damage
  #--------------------------------------------------------------------------
  def mp_damage
    result.mp_damage.abs
  end
  #--------------------------------------------------------------------------
  # * tp_damage
  #--------------------------------------------------------------------------
  def tp_damage
    result.tp_damage.abs
  end
  #--------------------------------------------------------------------------
  # * set_damage
  #--------------------------------------------------------------------------
  def set_damage(battler)
    @battler  = battler
    @dmg_text = damage_value.to_s
    @dmg_type = damage_type
    create_damage_sprites
  end
  #--------------------------------------------------------------------------
  # * damage_value
  #--------------------------------------------------------------------------
  def damage_value
    return VE_COUNTER_TEXT if @battler.counter
    return VE_REFLECT_TEXT if @battler.reflect
    return VE_COVER_TEXT   if @battler.covered
    return sprintf(VE_HP_DAMAGE,  hp_damage) if result.hp_damage > 0
    return sprintf(VE_MP_DAMAGE,  mp_damage) if result.mp_damage > 0
    return sprintf(VE_TP_DAMAGE,  tp_damage) if result.tp_damage > 0
    return sprintf(VE_HP_RECOVER, hp_damage) if result.hp_damage < 0
    return sprintf(VE_MP_RECOVER, mp_damage) if result.mp_damage < 0
    return sprintf(VE_TP_RECOVER, tp_damage) if result.tp_damage < 0
    return VE_MISS_TEXT    if result.missed
    return VE_EVADE_TEXT   if result.evaded
    return "" if @battler.no_dmg
    return 0  
  end
  #--------------------------------------------------------------------------
  # * damage_type
  #--------------------------------------------------------------------------
  def damage_type
    return :counter    if @battler.counter
    return :reflect    if @battler.reflect
    return :covered    if @battler.covered
    return custom_type if custom_type
    return :crt_damage if result.hp_damage > 0 && result.critical
    return :hp_damage  if result.hp_damage > 0
    return :mp_damage  if result.mp_damage > 0
    return :tp_damage  if result.tp_damage > 0
    return :hp_recover if result.hp_damage < 0
    return :mp_recover if result.mp_damage < 0
    return :tp_recover if result.tp_damage < 0
    return :miss_text  if result.missed
    return :eva_text   if result.evaded
    return :default
  end
  #--------------------------------------------------------------------------
  # * custom_type
  #--------------------------------------------------------------------------
  def custom_type
    return nil unless @battler.current_action
    return nil unless @battler.current_action.item
    note = @battler.current_action.item.note
    type = nil
    type = eval(":#{$1}") if note =~ /<DAMAGE BEHAVIOR: ([^>< ]*)>/i
    type
  end
  #--------------------------------------------------------------------------
  # * create_damage_sprites
  #--------------------------------------------------------------------------
  def create_damage_sprites
    @damage_sprites.compact!
    set_normal_damage
    set_critical if result.critical && VE_CRT_POP
    set_resist   if result.resist   && VE_RESIST_POP
    set_states
  end
  #--------------------------------------------------------------------------
  # * state_change
  #--------------------------------------------------------------------------
  def state_change
    (result.added_states + result.removed_states + result.added_buffs +
     result.removed_buffs)
  end
  #--------------------------------------------------------------------------
  # * state_changed?
  #--------------------------------------------------------------------------
  def state_changed?
    !state_change.empty?
  end
  #--------------------------------------------------------------------------
  # * set_normal_damage
  #--------------------------------------------------------------------------
  def set_normal_damage
    @rnd = 2.0 - (rand(400) / 100.0)
    @exw = 0
    set  = []
    n    = damage_value.numeric?
    @dmg_text.size.times {|i| set.push(set_sprite(@dmg_text, @dmg_type, i, n)) }
    set.each {|sprite| sprite.plus = @exw }
    @damage_sprites.push(set)
    @exw = @rnd = 0
  end
  #--------------------------------------------------------------------------
  # * set_critical
  #--------------------------------------------------------------------------
  def set_critical
    set = [set_sprite(VE_CRT_TEXT, :crt_text, -1)]
    set.each {|sprite| sprite.set_position }
    @damage_sprites.push(set)
  end
  #--------------------------------------------------------------------------
  # * set_resist
  #--------------------------------------------------------------------------
  def set_resist
    set = [set_sprite(get_resist, result.resist, -1)]
    set.each {|sprite| sprite.set_position }
    @damage_sprites.push(set)
  end
  #--------------------------------------------------------------------------
  # * set_states
  #--------------------------------------------------------------------------
  def set_states
    set_state_sprite(result.added_states,   :state_add)
    set_state_sprite(result.removed_states, :state_rmv)
    set_buff_sprite(result.added_buffs,     :buff_add)
    set_buff_sprite(result.added_debuffs,   :debuff_add)
    set_buff_sprite(result.removed_buffs,   :buff_rmv)
  end
  #--------------------------------------------------------------------------
  # * set_other
  #--------------------------------------------------------------------------
  def set_other
    set = [set_sprite(VE_COUNTER_TEXT, :counter, -1)] if @battler.counter
    set = [set_sprite(VE_REFLECT_TEXT, :reflect, -1)] if @battler.reflect
    set = [set_sprite(VE_COVER_TEXT,   :covered, -1)] if @battler.covered
    set.each {|sprite| sprite.set_position }
    @damage_sprites.push(set)
  end
  #--------------------------------------------------------------------------
  # * set_sprite
  #--------------------------------------------------------------------------
  def set_sprite(text, type, index = 0, num = false, state = nil)
    x = @sprite.x
    y = @sprite.y - (VE_HEIGHT_ADJ ? @sprite.center_y : 64)
    size = @damage_sprites.size
    info = {i: index, text: text, type: type, x: x, y: y, size: size, num: num}
    sprite = Sprite_Damage.new(@viewport, @battler, @exw, @rnd, state, info)
    @exw += sprite.space unless index < 0
    sprite
  end
  #--------------------------------------------------------------------------
  # * get_resist
  #--------------------------------------------------------------------------
  def get_resist
    case result.resist
    when :weakness then VE_WEAK_TEXT
    when :resist   then VE_RESIST_TEXT
    when :imune    then VE_IMUNE_TEXT
    when :absorb   then VE_ABSORB_TEXT
    else ""
    end
  end
  #--------------------------------------------------------------------------
  # * set_state_sprite
  #--------------------------------------------------------------------------
  def set_state_sprite(list, type)
    list.each do |id| 
      next if no_state_display(type, id)
      behavior = state_type(id, type)
      name = state_text(id, type)
      set  = [set_sprite(name, behavior, -1, false, id)]
      set.each {|sprite| sprite.set_position }
      @damage_sprites.push(set)
    end
  end
  #--------------------------------------------------------------------------
  # * no_state_display
  #--------------------------------------------------------------------------
  def no_state_display(type, id)
    note = $data_states[id].note
    return true if note =~ /<NO DISPLAY ADD>/i
    return true if type == :state_add && note =~ /<NO DISPLAY ADD>/i
    return true if type == :state_rmv && note =~ /<NO DISPLAY RMV>/i
    return false
  end
  #--------------------------------------------------------------------------
  # * set_buff_sprite
  #--------------------------------------------------------------------------
  def set_buff_sprite(list, type)
    list.each do |id| 
      set = [set_sprite(buff_text(id, type), type, -1, false, id)]
      set.each {|sprite| sprite.set_position }
      @damage_sprites.push(set)
    end
  end
  #--------------------------------------------------------------------------
  # * state_text
  #--------------------------------------------------------------------------
  def state_text(id, type)
    sprintf(get_state_text(type), $data_states[id].name)
  end
  #--------------------------------------------------------------------------
  # * buff_text
  #--------------------------------------------------------------------------
  def buff_text(id, type)
    sprintf(get_state_text(type), Vocab::param(id))
  end
  #--------------------------------------------------------------------------
  # * get_state_text
  #--------------------------------------------------------------------------
  def get_state_text(type)
    case type
    when :state_add  then VE_STATE_ADD
    when :state_rmv  then VE_STATE_REMOVE
    when :buff_add   then VE_BUFF_ADD
    when :debuff_add then VE_DEBUFF_ADD
    when :buff_rmv   then VE_BUFF_RMV
    end
  end
  #--------------------------------------------------------------------------
  # * state_type
  #--------------------------------------------------------------------------
  def state_type(id, type)
    note = $data_states[id].note
    type = type
    type = eval(":#{$1}") if note =~ /<DAMAGE[ _]*BEHAVIOR:? +([^>< ]*)>/i
    type
  end
  #--------------------------------------------------------------------------
  # * update
  #--------------------------------------------------------------------------
  def update
    @damage_sprites.each do |set|
      set.each do |sprite|
        sprite.update
        set.delete_if {|sprite| sprite.disposed? }
      end
      set.compact!
    end
    @damage_sprites.delete_if {|set| set.empty? }
  end
  #--------------------------------------------------------------------------
  # * dispose
  #--------------------------------------------------------------------------
  def dispose
    @damage_sprites.each do |set|
      set.each {|sprite| sprite.dispose unless sprite.disposed? }
    end
  end
end

#==============================================================================
# ** Sprite_Damage
#------------------------------------------------------------------------------
#  This sprite is used to display damage. It observes a instance of the
# Game_Damage class and automatically changes sprite conditions.
#==============================================================================

class Sprite_Damage < Sprite_Base
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize(wiewport, battler, exw, rnd, state, info)
    super(wiewport)
    @battler = battler
    @exw     = exw
    @rnd     = rnd
    @state   = state ? $data_states[state] : nil
    start_info(info)
    start_basic
    start_misc
  end
  #--------------------------------------------------------------------------
  # * start_info
  #--------------------------------------------------------------------------
  def start_info(info)
    @index    = info[:i]
    @text     = info[:text]
    @type     = info[:type]
    @pos_x    = info[:x]
    @pos_y    = info[:y]
    @dmg_size = info[:size]
    @numeric  = info[:num]
  end
  #--------------------------------------------------------------------------
  # * start_basic
  #--------------------------------------------------------------------------
  def start_basic
    @wait   = VE_DAMAGE_DISPLAY == :text ? get_text[4] : get_sprite[0]
    @base   = VE_DAMAGE_DISPLAY == :text ? get_text[4] : get_sprite[0]
    @delay  = VE_MULTI_POP ? @index * 4 : 1
    @digit  = VE_DIGIT_ROLL
    @each   = VE_DIGIT_EACH
    @adjust = VE_AUTO_ADJ
  end
  #--------------------------------------------------------------------------
  # * start_misc
  #--------------------------------------------------------------------------
  def start_misc
    @size   = text? ? 0.75 : (@text.size / 2.0) - @index
    @move   = VE_DAMAGE_MOVE[@type]
    @pop    = VE_POP_BEHAVIOR
    @plus   = 0
    @adj_zx = 0.0
    @adj_zy = 0.0
    @speed  = 0.0
    @list   = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    @dmg_bitmap = create_bitmap(@index)
    self.opacity = 0
  end
  #--------------------------------------------------------------------------
  # * create_bitmap
  #--------------------------------------------------------------------------
  def create_bitmap(i, n = nil)
    VE_DAMAGE_DISPLAY == :text ? create_text(i, n) : create_sprite(i, n)
  end
  #--------------------------------------------------------------------------
  # * create_sprite
  #--------------------------------------------------------------------------
  def create_sprite(index, fixed = nil)
    text = fixed ? fixed.to_s : index < 0 ? @text : @text[index..index]
    begin
      digit = Cache.digits(text.to_s + get_sprite[1])
    rescue
      digit = Cache.digits(text.to_s)
    end
    bitmap = Bitmap.new(digit.width, digit.height)
    rect   = Rect.new(0, 0, digit.width, digit.height)
    bitmap.blt(0, 0, digit, rect)
    bitmap
  end
  #--------------------------------------------------------------------------
  # * create_text
  #--------------------------------------------------------------------------
  def create_text(index, fixed = nil)
    text = fixed ? fixed.to_s : index < 0 ? @text : @text[index..index]
    dummy_bitmap = Bitmap.new(160, font_size + 2)
    dummy_bitmap.font.size   = font_size
    dummy_bitmap.font.name   = font_name
    dummy_bitmap.font.bold   = font_bold
    dummy_bitmap.font.italic = font_italic
    dummy_bitmap.sfont = $sfont[0] if $imported[:ve_sfonts]
    adjust = font_italic ? 4 : 2
    size   = dummy_bitmap.text_size(text).width + adjust
    dummy_bitmap.dispose
    bitmap = damage_bitmap(size)
    bitmap.draw_text(1, 0, size, font_size, text)
    bitmap
  end
  #--------------------------------------------------------------------------
  # * damage_bitmap
  #--------------------------------------------------------------------------
  def damage_bitmap(size)
    bitmap = Bitmap.new(size, font_size)
    bitmap.font.size   = font_size
    bitmap.font.name   = font_name
    bitmap.font.bold   = font_bold
    bitmap.font.italic = font_italic
    bitmap.font.color.set(*get_color)
    bitmap.sfont = $sfont[0] if $imported[:ve_sfonts] && VE_ALL_SFONT
    bitmap
  end
  #--------------------------------------------------------------------------
  # * get_color
  #--------------------------------------------------------------------------
  def get_color
    add_color = /<ADD COLOR: ((?:\d+,? *){3})>/i
    rmv_color = /<REMOVE COLOR: ((?:\d+,? *){3})>/i
    if @state && @type == :state_add && @state.note =~ add_color
      color = get_state_color($1.dup)
    elsif @state && @type == :state_rmv && @state.note =~ rmv_color
      color = get_state_color($1.dup)
    else
      color = [get_text[0], get_text[1], get_text[2]]
    end
    color
  end
  #--------------------------------------------------------------------------
  # * get_text
  #--------------------------------------------------------------------------
  def get_text
    VE_DAMAGE_TEXTS[@type] ? VE_DAMAGE_TEXTS[@type] : VE_DAMAGE_TEXTS[:default]
  end
  #--------------------------------------------------------------------------
  # * get_sprite
  #--------------------------------------------------------------------------
  def get_sprite
    VE_DAMAGE_IMGS[@type] ? VE_DAMAGE_IMGS[@type] : VE_DAMAGE_IMGS[:default]
  end
  #--------------------------------------------------------------------------
  # * font_size
  #--------------------------------------------------------------------------
  def font_size
    get_text[3]
  end
  #--------------------------------------------------------------------------
  # * font_bold
  #--------------------------------------------------------------------------
  def font_bold
    get_text[5]
  end
  #--------------------------------------------------------------------------
  # * font_italic
  #--------------------------------------------------------------------------
  def font_italic
    get_text[6]
  end
  #--------------------------------------------------------------------------
  # * font_name
  #--------------------------------------------------------------------------
  def font_name
    get_text[7]
  end
  #--------------------------------------------------------------------------
  # * get_state_color
  #--------------------------------------------------------------------------
  def get_state_color(info)
    if info =~ /(\d+) *,? *(\d+) *,? *(\d+)/i
      color = [$1.to_i, $2.to_i, $3.to_i]
    else
      color = [255, 255, 255]
    end
    color
  end
  #--------------------------------------------------------------------------
  # * space
  #--------------------------------------------------------------------------
  def space
    @dmg_bitmap.width + VE_DIGIT_SPACE
  end
  #--------------------------------------------------------------------------
  # * Definição de posição
  #--------------------------------------------------------------------------
  def set_position
    update_digit_bitmap
    @base_x = @dmg_bitmap ? @dmg_bitmap.width / 2  : 0
    @base_y = @dmg_bitmap ? @dmg_bitmap.height / 2 : 0
    adjust_x = text? ? 0 : @plus / 2 - @base_x
    adjust_y = (@adjust && @text != "") ? @dmg_size * 16 : 0
    move = @pop[@move[0]]
    self.zoom_x = move[0]
    self.zoom_y = move[1]
    self.x = @pos_x + @exw + move[2] - adjust_x - spriteset_viewport.ox
    self.y = @pos_y + move[3] - adjust_y - spriteset_viewport.oy
    self.z = 3000
  end
  #--------------------------------------------------------------------------
  # * spriteset_viewport
  #--------------------------------------------------------------------------
  def spriteset_viewport
    SceneManager.scene.spriteset.viewport1
  end
  #--------------------------------------------------------------------------
  # * text?
  #--------------------------------------------------------------------------
  def text?
    @index < 0
  end
  #--------------------------------------------------------------------------
  # * plus
  #--------------------------------------------------------------------------
  def plus=(plus)
    @plus = plus
    set_position
  end  
  #--------------------------------------------------------------------------
  # * update
  #--------------------------------------------------------------------------
  def update
    @delay -= 1
    return if self.disposed? || @delay > 0
    super
    @wait -= 1
    update_digit_bitmap
    update_speed
    update_damage_move
    update_zoom
    update_move
    update_opacity
  end
  #--------------------------------------------------------------------------
  # * update_digit_bitmap
  #--------------------------------------------------------------------------
  def update_digit_bitmap
    if @each && each_digit  
      self.bitmap = nil
    elsif @numeric && @digit && !waiting && digit_roll
      self.bitmap = create_bitmap(@index, random_digit)
    else
      self.bitmap = @dmg_bitmap
    end
  end
  #--------------------------------------------------------------------------
  # * waiting
  #--------------------------------------------------------------------------
  def waiting
    (Graphics.frame_count % 3 != 0 && !VE_FAST_ROLL)
  end
  #--------------------------------------------------------------------------
  # * each_digit
  #--------------------------------------------------------------------------
  def each_digit    
    (@wait - (@index * 5) + (@dmg_size * 5) >= @base)
  end
  #--------------------------------------------------------------------------
  # * digit_roll
  #--------------------------------------------------------------------------
  def digit_roll
    (@wait > (@base * 0.5) + (@each ? @index * 5 : 0))
  end
  #--------------------------------------------------------------------------
  # * random_digit
  #--------------------------------------------------------------------------
  def random_digit
    digit = @list.random!
    @list = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] if @list.empty?
    digit
  end
  #--------------------------------------------------------------------------
  # * update_damage_move
  #--------------------------------------------------------------------------
  def update_damage_move
    a = @pop[@move[0]]
    b = @pop[@move[1]]
    c = @pop[@move[2]]
    if @wait > @base * 2.0 / 3.0
      set_move_values(a[0], b[0], a[1], b[1], a[4], a[5], a[6], a[7])
    elsif @wait < @base / 3.0
      set_move_values(b[0], c[0], b[1], c[1], c[4], c[5], c[6], c[7])
    else
      set_move_values(0, 0, 0, 0, b[4], b[5], b[6], b[7])
    end
  end
  #--------------------------------------------------------------------------
  # * Definição dos valores de movimento
  #     args : valores
  #--------------------------------------------------------------------------
  def set_move_values(*args)
    @adj_x = (args[0] - args[1]) / (@base * 0.33)
    @adj_y = (args[2] - args[3]) / (@base * 0.33)
    @zoom_max_x = args[1]
    @zoom_max_y = args[3]
    @move_x = args[4] * (args[7] ? @random : 1.0) * (@damage_mirror ? -1 : 1)
    @move_y = args[5]
    @gravity = -args[6]
  end  
  #--------------------------------------------------------------------------
  # * update_zoom
  #--------------------------------------------------------------------------
  def update_zoom
    self.zoom_x -= @adj_x
    self.zoom_y -= @adj_y 
    self.zoom_x = [self.zoom_x, @zoom_max_x].max if @adj_x > 0
    self.zoom_x = [self.zoom_x, @zoom_max_x].min if @adj_x < 0
    self.zoom_y = [self.zoom_y, @zoom_max_y].max if @adj_x > 0
    self.zoom_y = [self.zoom_y, @zoom_max_y].min if @adj_x < 0
  end
  #--------------------------------------------------------------------------
  # * update_speed
  #--------------------------------------------------------------------------
  def update_speed
    duration = @wait * 100.0 / @base
    case duration
    when 66...100
      @speed = (duration - 81) * 10 / @base
    when 33...66
      @speed = (duration - 50) * 10 / @base
    when 0...33
      @speed = (duration - 16) * 10 / @base
    end
  end
  #--------------------------------------------------------------------------
  # * update_move
  #--------------------------------------------------------------------------
  def update_move
    self.x += @move_x
    self.y += @move_y + (@gravity * @speed)
    size_value = (@exw / 4) * @size * (self.zoom_x - 1)
    self.ox = @base_x + (size_value / self.zoom_x)
    self.oy = @base_y + ((@base_y - (@base_y / self.zoom_y)) / 2)
  end
  #--------------------------------------------------------------------------
  # * update_opacity
  #--------------------------------------------------------------------------
  def update_opacity
    case @wait
    when 1..10
      self.opacity -= 25
    when (@base - 10)..@base
      self.opacity += 25
    when 0
      self.dispose
    else
      self.opacity = 255
    end
  end
end
