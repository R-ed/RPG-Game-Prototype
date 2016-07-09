#===============================================================================
# This Script is made specfically for usage with GTBS version 1.5.1.4 by GubiD.
#===============================================================================

#----------------------------------------------------------------------------
# Draw Item window and contents
#----------------------------------------------------------------------------
class TBS_Item < Window_BattleItem
  include GTBS_Win_Base
  #----------------------------------------------------------------------------
  # Object Initialize
  #----------------------------------------------------------------------------
  def initialize(*args)
    super(*args)
    self.height = 256
    create_gtbs_back
  end
 
  #--------------------------------------------------------------------------
  # * Update @back if defined
  #--------------------------------------------------------------------------
  def update
    super
    if @back
      @back.x = self.x
      @back.y = self.y
      @back.update
    end
  end
  #-----------------------------------------------------------
  # This change checks for a background image and if exist set its visiblity
  #-----------------------------------------------------------
  def visible=(bool)
    if @back
      @back.visible = bool
    end
    super(bool)
  end
end


