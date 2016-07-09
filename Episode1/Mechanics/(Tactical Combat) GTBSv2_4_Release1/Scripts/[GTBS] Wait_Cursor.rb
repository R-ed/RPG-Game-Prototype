#----------------------------------------------------------------------------
# Wait Cursor - This is the WAIT DIRECTION image that appears over battlers
#    when they select the WAIT command
#----------------------------------------------------------------------------
class Wait_Cursor < TBS_Battler_Cursor
  attr_reader :initial_dir
  #----------------------------------------------------------------------------
  # Constants
  #----------------------------------------------------------------------------
 
  #----------------------------------------------------------------------------
  # Object Initialization
  #----------------------------------------------------------------------------
  def initialize(viewport, actor)
    super
    @initial_dir = actor.direction
  end
  #----------------------------------------------------------------------------
  # * Update Process
  #----------------------------------------------------------------------------
  def update
    super
    if Input.trigger?(Input::DOWN)
      @actor.set_direction(2)
    elsif Input.trigger?(Input::LEFT)
      @actor.set_direction(4)
    elsif Input.trigger?(Input::RIGHT)
      @actor.set_direction(6)
    elsif Input.trigger?(Input::UP)
      @actor.set_direction(8)
    else
      return
    end
    moveto(@actor.x, @actor.y)
    update_bitmap
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
  end
  #----------------------------------------------------------------------------
  # Dispose process
  #----------------------------------------------------------------------------
  def dispose
    if self.bitmap != nil
      self.bitmap.dispose
    end
    super
  end
  #----------------------------------------------------------------------------
  # Create Bitmap
  #----------------------------------------------------------------------------
  def create_bitmap
    @direction = 0
    update_bitmap
  end
  #----------------------------------------------------------------------------
  # Updates the bitmap based on the current direction of the actor
  #----------------------------------------------------------------------------
  def update_bitmap
    if @direction != @actor.direction
      @direction = @actor.direction
      self.bitmap.dispose if self.bitmap and !self.bitmap.disposed?
      if !@iso
        self.bitmap = Cache.picture(sprintf("GTBS/wait%d", @direction))
      else
        self.bitmap = Cache.picture(sprintf("GTBS/wait_iso%d", @direction))
      end
    end
  end
end