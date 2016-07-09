#===============================================================================
# This Script is made specfically for usage with GTBS version 1.5.1.4 by GubiD.
#===============================================================================

#----------------------------------------------------------------------------
# Window Full Status
#----------------------------------------------------------------------------
# Calls the default Window Status but doesnt require an actor
#----------------------------------------------------------------------------
class Window_Full_Status < Window_Status
  include GTBS_Win_Base
#~   #----------------------------------------------------------------------------
#~   # Object initialization
#~   #----------------------------------------------------------------------------
#~   # Allows actor to be nil, which cancels the refresh method
#~   #----------------------------------------------------------------------------
#~   def initialize(actor = nil)
#~     super(actor)
#~     create_gtbs_back
#~   end
  #----------------------------------------------------------------------------
  # Refresh - unless actor is not nil, dont process
  #----------------------------------------------------------------------------
  def refresh(actor = nil)
    return if actor.nil?
    @actor = actor
    super() #process normal refresh method
    update
  end
  #----------------------------------------------------------------------------
  # Update Background image
  #----------------------------------------------------------------------------
  def update 
#~     refresh(@actor)    if self.active and @actor and @pattern != @actor.pattern 
    super
  end
  #----------------------------------------------------------------------------
  # draw_equipments
  #----------------------------------------------------------------------------
  def draw_equipments(x, y)
    return if @actor.is_a?(Game_Enemy)
    super
  end 
  #----------------------------------------------------------------------------
  # draw_exp_info
  #----------------------------------------------------------------------------
  def draw_exp_info(x, y)
    return if @actor.is_a?(Game_Enemy)
    super
  end 
end
