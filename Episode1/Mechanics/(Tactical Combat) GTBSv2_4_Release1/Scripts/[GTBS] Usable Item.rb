#===============================================================================
# Scope Expansion Functions
#===============================================================================
class RPG::UsableItem < RPG::BaseItem
  alias gtbs_for_all_additional_scopes for_all?
  def for_all?
    returnValue = gtbs_for_all_additional_scopes
    if !returnValue and @scope == 12
      returnValue = true
    end
    returnValue
  end  
  def apply_direction
    return true
  end
end
class RPG::Skill < RPG::UsableItem
  def apply_direction
    return true unless SceneManager.scene.is_a?(Scene_Battle_TBS) && GTBS.skill_ignore_dmg_dir(self.id)
  end
end