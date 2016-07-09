class RPG::State
  def is_doom_state?
    return @id == GTBS::DOOM_ID
  end
  def doom_turns(id)
    return is_doom_state? ? [2,GTBS::doom_turn?(id)].max : 0#min must be at least 2
  end
  def ai_effect
    return (GTBS::STATE_RATE_EFFECT[self.id] or 1)
  end
  def distance
    return (GTBS::STATE_PUSH_INFO[@id] || 0)
  end
end