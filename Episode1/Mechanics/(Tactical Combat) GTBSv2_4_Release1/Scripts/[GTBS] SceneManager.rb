class << SceneManager 
  alias sceneMgrCallGTBS call
end
module SceneManager
  #--------------------------------------------------------------------------
  # * Call
  #--------------------------------------------------------------------------
  def self.call(scene_class)
    if scene_class == Scene_Battle && $game_system.gtbs_enabled?
      scene_class = Scene_Battle_TBS
    end
    sceneMgrCallGTBS(scene_class)
  end
end
#--------------------------------------------------------------------------
class Scene_Map < Scene_Base
  alias pre_term_scn_map_gtbs pre_terminate
  def pre_terminate
    pre_term_scn_map_gtbs
    pre_battle_scene if SceneManager.scene_is?(Scene_Battle_TBS)
  end
end

    