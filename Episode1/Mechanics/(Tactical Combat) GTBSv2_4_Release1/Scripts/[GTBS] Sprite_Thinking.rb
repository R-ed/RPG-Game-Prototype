#===============================================================================
# Class Sprite_Thinking 
#===============================================================================
class Sprite_Thinking < Sprite
  #----------------------------------------------------------------
  # Draws the Thinking... at start of AI thinking
  # actor are usable for further add-on/modification
  #----------------------------------------------------------------
  def initialize(actor)
    super()
    @think_time = GTBS::ENEMY_THINK_TIME*Graphics.frame_rate
    reset_text
    self.bitmap = Bitmap.new(250, 24)
    update
  end
  #----------------------------------------------------------------
  # Draws the Thinking... .. . bitmap while AI is running 
  #----------------------------------------------------------------
  def update
    if @think_time % 6 == 0
      self.bitmap.clear 
      @think_text +="." 
      if self.bitmap.text_size(@think_text).width > self.width
        reset_text
      end
      self.bitmap.draw_outline_text(0, 0, self.width, self.height, @think_text)
    end
    super
    if @think_time > 0
      @think_time -= 1
      return true
    else
      return false
    end
  end
  #----------------------------------------------------------------
  # Reset thinking text
  #----------------------------------------------------------------
  def reset_text 
    @think_text = GTBS::THINKING_TEXT
  end
  #----------------------------------------------------------------
  # Dispose
  #----------------------------------------------------------------
  def dispose
    self.bitmap.dispose
    super
  end
end