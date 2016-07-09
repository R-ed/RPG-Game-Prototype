class TBS_Window_Help < Window_Help
  attr_reader :text
  include GTBS_Win_Base
  
  def set_text(text)
    if (@text != text)
      @text = text
      if self.contents != nil
        self.contents.clear
      else 
        self.contents = new Bitmap(width-standard_padding, height-standard_padding)
      end
      draw_text(self.contents.rect, @text, 1)
    end
    if self.visible == false
      show
      activate
      open
    end
  end
end
