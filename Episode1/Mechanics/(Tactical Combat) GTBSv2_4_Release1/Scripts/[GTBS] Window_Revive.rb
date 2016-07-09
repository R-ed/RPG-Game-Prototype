#===============================================================================
# TBS_Window Revive - Used to revive dead actors when removed from map.
#===============================================================================
class TBS_Window_Revive < TBS_Window_Selectable
  #----------------------------------------------------------------------------
  # Object Initialization
  #----------------------------------------------------------------------------
  def initialize() 
    @item_max = 0;
    #create window
    super(0,0,line_height + standard_padding*2,64)
    self.visible = false
    self.index = -1
  end

  def dead
    scn = SceneManager.scene
    return scn.dead_friends_of(scn.active_battler)
  end
  
  #----------------------------------------------------------------------------
  # Refresh
  #----------------------------------------------------------------------------
  def refresh(range)
    @dead_range = range
    #dead = @scene.dead_friends_of #get dead actors
    h = WLH*dead.size + 64 #set height to #dead*32 + 64
    #determine window width
    bmp = Bitmap.new(1,1)
    w = bmp.text_size(Vocab_GTBS::Revive_Who).width
    for act in dead
      wd = bmp.text_size(act.name).width
      if wd > w
        w = wd
      end
    end
    w += 32
    bmp.dispose
    self.width  = (w > 0 ? w:1) #returns 1 if width is <= 0
    self.height = (h > 0 ? h:1) #returns 1 if height is <= 0
    create_contents
    #Draw Contents based on new size
    y = 0
    self.contents.font.color = system_color
    self.contents.draw_text(0,y,width,WLH,Vocab_GTBS::Revive_Who, 0)
    y += line_height
    self.contents.font.color = normal_color
    for act in dead #draw actors names
      act.sprite_effect_type = :whiten
      self.contents.draw_text(0,y,width,line_height,act.name)
      y+=line_height
    end
    self.height = 100
    @item_max = dead.size
  end
  #--------------------------------------------------------------------------
  # * Calculate Width of Window Contents
  #--------------------------------------------------------------------------
  def contents_width
    width - standard_padding * 2
  end
  #--------------------------------------------------------------------------
  # * Calculate Height of Window Contents
  #--------------------------------------------------------------------------
  def contents_height
    h = height - standard_padding * 2
    h + (@item_max * line_height)
  end
  def item_max
    return @item_max
  end
  
  def chosen_revive
    bat = dead[self.index]
    if bat and (GTBS::REVIVE_ANY_DEAD or @dead_range & bat.positions != [])
      return bat
    else
      return nil
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get Rectangle for Drawing Items
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing)
    rect.y = line_height + (index / col_max * item_height)
    rect
  end
  
  def update
    super
    if dead.size > 0
      bat = dead[self.index]
      bat.sprite_effect_type = :whiten
    end
  end
  #----------------------------------------------------------------------------
  # Update Cursor Size/Position
  #----------------------------------------------------------------------------
  #def update_cursor_rect
  #  self.cursor_rect.set(0, (self.index*WLH+32), width-32, 32)
  #end
end