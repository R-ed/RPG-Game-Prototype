#==============================================================================
# ** Scene_Battle_TBS
#==============================================================================
class Scene_Battle_TBS < Scene_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader :placement_done
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_lm_gtbs
    alias set_active_battler_mgc_lm_gtbs set_active_battler
    alias start_actor_place_mgc_lm_gtbs start_actor_place
    alias check_phase_mgc_lm_gtbs check_phase
    alias check_knock_back_mgc_lm_gtbs check_knock_back
    @already_aliased_mgc_lm_gtbs = true
  end
  #--------------------------------------------------------------------------
  # * Mise à jour pendant la rotation/translation
  #--------------------------------------------------------------------------
  def update_for_lm_transition
    unless placement_done
      Graphics.update
      Input.update
      update_battlers
    else  
      update_basic
    end
    $game_map.update(false)
    @spriteset.update
  end
  #-------------------------------------------------------------------------
  # * Set_Active_Battler - Sets the battler, as active and initiates battler phase
  #-------------------------------------------------------------------------
  def set_active_battler(battler, forcing = false)
    wait_for_effect
    if Layy_Meta.active
      Layy_Meta.focus_on_character(battler, 8)
    end
    set_active_battler_mgc_lm_gtbs(battler, forcing)
  end
  #--------------------------------------------------------------------------
  # * Prepare Place - This method prepares for the placement of characters(you choose)
  #--------------------------------------------------------------------------  
  def start_actor_place
    if Layy_Meta.active
      Layy_Meta.focus_on_coordinates(@place_loc.first[0], @place_loc.first[1])
    end
    start_actor_place_mgc_lm_gtbs
    @placement_done = true
  end
  #----------------------------------------------------------------------------
  # * Displays the current Phase Picture
  #----------------------------------------------------------------------------
  def check_phase
    if Layy_Meta.active && @turn == Turn_Enemy &&
      $game_system.acted.size >= tactics_enemies.size && !@active_battler
    then
      Layy_Meta.focus_on_character(tactics_actors.first, 8)
    end
    check_phase_mgc_lm_gtbs
  end
  #----------------------------------------------------------------------------
  # Used for skills that apply state "knock back"
  #----------------------------------------------------------------------------
  def check_knock_back(target)
    if Layy_Meta.active
      for state in target.states
        if GTBS::KNOCK_BACK_STATES.include?(state)
          data = $data_states[state]
          if data.distance != 0
            perform_knock_back(target, data, false)
          end
          target.remove_state(state) #remove knockback state
        end
      end
    else
      check_knock_back_mgc_lm_gtbs(target)
    end
  end
end