module BattleManager
  def self.preemptive
    return @preemtive
  end
  def self.surprise
    return @surprise
  end
  def self.can_lose?
    return @can_lose
  end
  def self.foe_data
    return @foe_data
  end
  def self.foe_data=(value)
    @foe_data = value
  end
  def self.reset_team_data
    @foe_data  = {"actor" => "enemy", "enemy" => "actor"}
  end
end

module Sound
  def self.play_decision
    play_ok
  end
end

module SceneManager
  class << self
    alias :gtbs_scn_mgr_first_scene :first_scene_class
  end

  def self.first_scene_class
    result = gtbs_scn_mgr_first_scene
    if result == Scene_Battle && GTBS::BTEST_TBS == true
      result = Scene_Battle_TBS
    end
    return result
  end
end