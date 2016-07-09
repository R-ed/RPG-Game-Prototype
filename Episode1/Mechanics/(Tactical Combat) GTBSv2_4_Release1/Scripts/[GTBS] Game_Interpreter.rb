class Game_Interpreter
  def disable_tbs
    $game_system.tbs_enabled = false
  end
  def enable_tbs
    $game_system.tbs_enabled = true
  end
  def tbs_override_map(value)
    return if !value.is_a?(Numeric)
    $game_temp.map_id = [0,value].max
  end
  def tbs_victory(type=nil, val=nil, common=nil)
    $game_temp.victory_condition = type
    $game_temp.victory_val = val
    $game_temp.victory_common_event = common
  end
  def tbs_failure(type=nil, val=nil, common=nil)
    $game_temp.failure_condition = type
    $game_temp.failure_val = val
    $game_temp.failure_common_event = common
  end
  
  def tbs_occuppied?(type="actor")
    if SceneManager.scene_is?(Scene_Battle_TBS)
      scene = SceneManager.scene
      event = $game_map.events[@event_id]
      bat = scene.occupied_by?(event.x, event.y)
      return false if bat.nil?
      case type
      when "actor"
        return bat.actor?
      when "enemy"
        return bat.enemy?
      else #event
        return bat.is_a?(Game_Event)
      end
    end
    return false
  end
  def tbs_get_occupant
    if SceneManager.scene_is?(Scene_Battle_TBS)
      scene = SceneManager.scene
      event = $game_map.events[@event_id]
      return scene.occupied_by?(event.x, event.y)
    end
    return nil
  end
  def force_player_turn
    $game_temp.turn_start = "player";
  end
  def force_enemy_turn
    $game_temp.turn_start = "enemy";
  end
end