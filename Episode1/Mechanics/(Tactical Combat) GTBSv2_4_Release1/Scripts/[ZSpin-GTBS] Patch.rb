if defined?(ZiifManager)
module ZiifManager
  IconSet[:move] = Hash.new(467)
  IconSet[:wait] = Hash.new(506) 
  
end
class Commands_All < TBS_Win_Actor
  def update
    if @actor != nil
      if defined?(Layy_Meta) && Layy_Meta.active
        self.x, self.y = @actor.lm_x-(width/2)+48, @actor.lm_y-(width/2)+32
      else
        self.x, self.y = @actor.screen_x-(width/2)+48, @actor.screen_y-(width/2)+32
      end
    end
    super
  end
  alias setup_gtbs_zii_spin setup
  def setup(actor)
    setup_gtbs_zii_spin(actor)
    self.height = self.width
  end
end
end