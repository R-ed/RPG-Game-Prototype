#===============================================================================
# Window ActList
#===============================================================================
class Window_ActList < TBS_Window_Selectable
  Max_Updates = 400
  Max_List_Size = 20
  Offset_Down = 20
  WLH = 32
  #--------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------
  def initialize(actor, act_list = nil)
    @act_list = act_list  
    @actor = actor
    div = 8
    x = (Graphics.width/2) - 120
    y = 60
    super(x,y,240, Max_List_Size * WLH + 32)
    self.height = Graphics.height - y - Offset_Down 
    self.index = 0
    @item_max =1
    refresh
    self.activate
  end
  def col_max
    return 1
  end
  def item_max
    @act_list.size
  end
  def update
    last_index = self.index
    super
    if last_index != self.index
      refresh
    end
  end
  #--------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------
  def refresh
    self.contents.clear
    for i in 0...@act_list.size
      draw_list_item(i)
    end
  end
  #--------------------------------------------------------------
  # * Draw List Item
  #--------------------------------------------------------------
  def draw_list_item(i)
    if @act_list[i].is_a?(Array)
      string = @act_list[i][0].name
      string += "("+@act_list[i][1][0].name+")"
    else
      string = @act_list[i].name
    end
    if @act_list[i] == @actor
      self.contents.font.color = GTBS::Act_List_Active_Color
    elsif @act_list[i] == @act_list[self.index]
      self.contents.font.color = GTBS::Act_List_Select_Color
    else
      self.contents.font.color = GTBS::Act_List_Normal_Color
    end

    rect = item_rect(i)
    self.contents.draw_text(rect,"#{i+1} : #{string}")
  end
  #--------------------------------------------------------------
  # Data - Returns the actor for the selected line
  #--------------------------------------------------------------
  def data
    actor = @act_list[self.index]
    if actor.is_a?(Array)
      return actor[0]
    else
      return actor
    end
  end
end