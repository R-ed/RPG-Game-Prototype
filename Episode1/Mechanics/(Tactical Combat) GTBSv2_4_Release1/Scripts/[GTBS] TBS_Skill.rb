#----------------------------------------------------------------------------
# Draw Skill Window and contents
#----------------------------------------------------------------------------
class TBS_Skill < Window_BattleSkill
  include GTBS_Win_Base
  attr_reader     :data
  #----------------------------------------------------------------------------
  # Initialize
  #----------------------------------------------------------------------------
  def initialize(*args)
    super(*args)
    self.height = 256
    create_gtbs_back
  end
  #----------------------------------------------------------------------------
  # Refresh Process
  #----------------------------------------------------------------------------
  # The local refresh is run first, and then must call the super
  #----------------------------------------------------------------------------
  def refresh(actor = nil)
    @actor = actor
    super() if @actor != nil
  end
  #----------------------------------------------------------------------------
  # Return data for index
  #----------------------------------------------------------------------------
  def skill
    if @data == nil
      return nil
    else
      return @data[self.index]
    end
  end 
  #--------------------------------------------------------------------------
  # Select Last (Used to highlight the actors last skill, memory cursor)
  #--------------------------------------------------------------------------
  def select_last
    return if @actor.nil?
    super
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
  #-----------------------------------------------------------
  # Update help when changing index
  #-----------------------------------------------------------
  def select(*args)
    super(*args)
    call_update_help
  end
end    
