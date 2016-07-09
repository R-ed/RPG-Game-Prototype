#===============================================================================
# Draw Actor Name in the window (only used for actors)
#===============================================================================
class Window_Actor_Display < TBS_Window_Base
  def initialize(y)
    super(0,0,120,60)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.visible = false
  end
  #----------------------------------------------------------------------------
  # Refresh
  #----------------------------------------------------------------------------
  def refresh(actor)
    self.contents.clear
    if (actor != nil)
      draw_actor_name(actor,0,0) #draws actors name
    end
  end
end