#===============================================================================
# Window EXP Earn
#===============================================================================
# Displays for each actor the gained experience
#----------------------------------------------------------------------------
class Window_EXP_Earn < TBS_Window_Selectable
  #----------------------------------------------------------------------------
  # Object Initialization
  #----------------------------------------------------------------------------
  def initialize(attacker = nil, level = {})
    @attacker = attacker
    @level = level
    h = level.size * 32 + 64
    super(120, 60, 352, h)
    refresh
  end
   #----------------------------------------------------------------------------
  # Refresh Process
  #----------------------------------------------------------------------------
  def refresh
    return if @attacker = nil
    self.contents.clear
    self.contents.draw_text(0, 0, 320, 24, "-LEVEL-", 1)
    y = 32 
    for actor, lvl in @level
      self.draw_actor_name(actor, 4, y)
      self.contents.font.color = system_color
      self.contents.draw_text(168, y, 24, 32, "Lv")
      self.contents.draw_text(228, y, 24, 32, " -→>")
      self.contents.font.color = normal_color
      lv1, lv2 = lvl
      self.contents.draw_text(192, y, 32, 32, lv1.to_s, 2)
      self.contents.draw_text(254, y, 32, 32, lv2.to_s)
      y += 32
    end 
  end
end