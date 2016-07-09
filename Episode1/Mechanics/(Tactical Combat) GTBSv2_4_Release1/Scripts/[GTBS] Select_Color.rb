#===============================================================================
# Window Select Color
#===============================================================================
# Used to display all the available COLORS and allow a selection.
#----------------------------------------------------------------------------
class Window_Select_Color < TBS_Window_Selectable
  #----------------------------------------------------------------------------
  # Object Initialization
  #----------------------------------------------------------------------------
  def initialize
    super(120,320,380,64)
    self.contents = Bitmap.new(width-32, height-32) 
    #@item_max = 11
    #@column_max = 11
    self.index = -1
    refresh
  end
  #----------------------------------------------------------------------------
  # Item Max - Returns the amount of items that are held within the dialog
  #----------------------------------------------------------------------------
  def item_max
    return 11
  end
  #----------------------------------------------------------------------------
  # Column Max - Returns the max amount of colums that should be displayed
  #----------------------------------------------------------------------------
  def col_max
    return 11
  end
  #----------------------------------------------------------------------------
  # Refresh
  #----------------------------------------------------------------------------
  def refresh
    pinwheel = GTBS::Colors
    x = 6; y = 6
    for i in 0...pinwheel.size
      rect = Rect.new(x+(i*32), y, 18, 18)
      #xx = i
      self.contents.fill_rect(rect, pinwheel[i].color )
    end
  end
  
  #----------------------------------------------------------------------
  # return the selected color
  #----------------------------------------------------------------------
  def get_color
    return GTBS::Colors[self.index ]
  end
  #----------------------------------------------------------------------------
  # Update Cursor Size/Location
  #----------------------------------------------------------------------------
  
  def update
    super  
    if @index >= 0
      self.cursor_rect.set((@index*32), 0, 31, 31)
    end
  end
  #else
  #  def update_cursor_rect
  #    self.cursor_rect.set((@index*32), 0, 31, 31)
  #  end
  #end
end