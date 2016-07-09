class Window_BattleLog < Window_Selectable
  def show_exp_gain(actor, exp)
    $game_message.new_page
    $game_message.add(sprintf(Vocab_GTBS::LOG_Gain_Exp, actor.name, exp))
  end
end