class RPG::Enemy::Action
  def attack?(user)
    @skill_id == user.attack_skill_id
  end
  def guard?(user)
    @skill_id == user.guard_skill_id
  end
  def item?(user)
    false
  end
  def skill?(user)
    return true if !attack?(user) and !guard?(user)
    return false
  end
end