class Scene_Battle_TBS
  #-------------------------------------------------------------
  # Result Phase
  #-------------------------------------------------------------
  def result_phase
    show_congrat
    make_result_info
    exit_battle
  end
  #----------------------------------------------------------------------------
  # Show Congratulations
  #----------------------------------------------------------------------------
  def show_congrat
    congrat = Congrat_Sprite.new(@battle_exiting)
    while not congrat.disposed?
      Graphics.update
      $game_map.update(false)
      @spriteset.update
      congrat.update
    end
  end
  #----------------------------------------------------------------
  # Call Battle Exit Command
  #----------------------------------------------------------------
  def exit_battle
    return_to_map, return_x, return_y, return_dir = GTBS::battle_exit_info(@map_id)
    if return_to_map.nil? || return_to_map == false || return_to_map == 0
      return_to_map = @map_id
    end
    if (return_to_map == @map_id)
      $game_map.setup(@map_id )
    else
      $game_map.setup(return_to_map) 
    end
    $game_player.moveto(return_x, return_y) if return_x != nil
    $game_player.set_direction(return_dir) if return_dir != nil
    $game_party.clear_summons
    $game_party.clear_neutrals
    $game_troop.clear_summons
    @map_id = nil
    SceneManager.return
    $game_map.autoplay
    $game_player.refresh
    $game_player.center($game_player.x, $game_player.y)
    Graphics.freeze
    Graphics.fadeout(30)
  end
end