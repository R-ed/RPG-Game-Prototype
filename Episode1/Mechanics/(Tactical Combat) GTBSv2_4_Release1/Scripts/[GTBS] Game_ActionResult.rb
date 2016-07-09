#--------------------------------------------------------------------------
# VE Engine Vocab Additions for GTBS
#--------------------------------------------------------------------------
module Victor_Engine  
  GAIN_EXP_TXT = Vocab_GTBS::POP_Gain_Exp
  LEVEL_GAINED = Vocab_GTBS::Level_Up
  DOOM_TXT = Vocab_GTBS::DOOM
end
#--------------------------------------------------------------------------
# Game Action Result Additions to VE Engine by GubiD
#--------------------------------------------------------------------------
class Game_ActionResult
  attr_accessor :exp_gain_amt
  attr_accessor :doom
  #--------------------------------------------------------------------------
  alias clear_damage_values_gtbs clear_damage_values
  def clear_damage_values
    clear_damage_values_gtbs
    self.exp_gain_amt = ""
    self.doom = ""
  end
  #--------------------------------------------------------------------------
  def set_gain_exp(value)
    self.exp_gain_amt = value
    self.used = true
    @battler.damaged = true
    @battler.missed = false
  end
  def set_doom_text(counter = nil)
    if (counter.nil?)
      self.doom = DOOM_TXT
    else
      self.doom = sprintf("%2d", counter);
    end
    self.used = true;
    @battler.damaged = true;
    @battler.missed = false;
  end
end