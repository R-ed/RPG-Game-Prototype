#----------------------------------------------------------------------------
# Battle Cursor - Used to navigate the map during battle
#----------------------------------------------------------------------------
class Battle_Cursor < Sprite_Base
  attr_reader   :map_x
  attr_reader   :map_y
  attr_reader   :real_x
  attr_reader   :real_y
  
  #----------------------------------------------------------------------------
  # Constants
  #----------------------------------------------------------------------------
  Color_Flash_Move = GTBS::RED.color
  Time_Flash = 30
  #----------------------------------------------------------------------------
  # Object initialization
  #----------------------------------------------------------------------------
  def initialize(viewport, x = $game_player.x, y = $game_player.y)
    super(viewport)
    @iso = $game_map.iso?
    
    set_bitmap
    self.ox = self.bitmap.width / 2
    self.oy = self.bitmap.height
    @target_sprites = []
    @targets_arrows = []
    @cursor = $tbs_cursor
    @grid_x, @grid_y = x,y #$game_player.x, $game_player.y
    create_cursor_position_info
    moveto(x, y)
    update
  end
  #----------------------------------------------------------------------------
  # Sets the bitmap to the cursor image, or draws it for you.
  #----------------------------------------------------------------------------
  def set_bitmap
    #self.bitmap = Bitmap.new(32,32)
    #self.bitmap.fill_rect(0,0,32,32,Color.new(0,0,0))
    #return;
    if @iso
      if FileTest.exist?('Graphics/Pictures/GTBS/iso_cursor.png')
        self.bitmap = Cache.picture("GTBS/iso_cursor")
      else
        #iso cursor draw method
        bmp = Bitmap.new(62,32)
        color = Color.new(255,255,255)
        for x in 0..62
          uy = (16 - x * (0.51)).to_i
          dy = (16 + x * (0.51)).to_i
          if x >= 31
            uy += 31
            dy -= 31
          end
          bmp.set_pixel(x,uy,color)
          bmp.set_pixel(x,dy,color)
        end
        self.bitmap = bmp
      end
    else
      if FileTest.exist?('Graphics/Pictures/GTBS/cursor.png')
        self.bitmap = Cache.picture("GTBS/cursor")
      else
      #create cursor manually
        bmp = Bitmap.new(32,32)
        # B B B B B B
        # B W W W W B
        # B W b b b b
        # B W b
        # B W b
        # B B b
        
        #upper left corner
        bmp.fill_rect(0,0,15,15,Color.new(0,0,0,255))#B
        bmp.fill_rect(1,1,13,13,Color.new(255,255,255,255))#W
        bmp.fill_rect(4,4,10,10,Color.new(0,0,0,255))#b
        bmp.fill_rect(5,5,13,13,Color.new(0,0,0,0))# blank
        #lower right corner
        bmp.fill_rect(18,18,15,15,Color.new(0,0,0,255))
        bmp.fill_rect(19,19,12,12,Color.new(255,255,255,255))
        bmp.fill_rect(18,18,10,10,Color.new(0,0,0,255))
        bmp.fill_rect(18,18,9,9,Color.new(0,0,0,0))
        #lower left corner
        bmp.fill_rect(0,18,15,15,Color.new(0,0,0,255))
        bmp.fill_rect(1,19,13,12,Color.new(255,255,255,255))
        bmp.fill_rect(4,18,10,10,Color.new(0,0,0,255))
        bmp.fill_rect(5,18,10,9,Color.new(0,0,0,0))
        #upper right corner
        bmp.fill_rect(18,0,15,15,Color.new(0,0,0,255))
        bmp.fill_rect(19,1,12,13,Color.new(255,255,255,255))
        bmp.fill_rect(18,4,10,10,Color.new(0,0,0,255))
        bmp.fill_rect(18,5,9,10,Color.new(0,0,0,0))
        self.bitmap = bmp
      end
    end
  end
  #----------------------------------------------------------------------------
  # MoveTo - Sets the X,Y position of the cursor
  #----------------------------------------------------------------------------
  def moveto(x, y)
    @map_x = x % $game_map.width
    @map_y = y % $game_map.height
    @real_x = @map_x
    @real_y = @map_y
    center(x,y) if !$game_system.scroll_cursor
  end
  #--------------------------------------------------------------------------
  # * Set Map Display Position to Center of Screen
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def center(x, y, rtrn_coords = false)
    $game_player.center(x,y)
    if rtrn_coords
      return $game_map.display_x, $game_map.display_y
    end
  end
  #----------------------------------------------------------------------------
  # Dispose method
  #----------------------------------------------------------------------------
  def dispose
    if self.bitmap != nil
      self.bitmap.dispose
    end
    super
  end
  def screen_x
    $game_map.adjust_x(@map_x) * 32 + 16
  end
  def screen_y
    $game_map.adjust_y(@map_y) * 32 + 32
  end
  def screen_z
    100 
  end
  #----------------------------------------------------------------------------
  # Update Process
  #----------------------------------------------------------------------------
  def update
    moveto($tbs_cursor.x, $tbs_cursor.y)
    if @map_x != @cursor.x or @map_y != @cursor.y
      moveto(@cursor.x, @cursor.y)
      flash(Color_Flash_Move, Time_Flash)
      update_location
    end
    self.visible = $tbs_cursor.active
    if @cursor.target_need_refresh?
      clear_target_sprites
      draw_target_sprites
    else
      update_ranges_sprites
    end
    if @cursor.reselect_targets
      @cursor.reselect_targets = false
      refresh_targets
    else
      update_targets
    end
    
    super
    
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z + 1
    
    
  end
  
  #----------------------------------------------------------------------------
  # Sets the sprite for location
  #----------------------------------------------------------------------------
  def create_cursor_position_info
    return if GTBS::HIDE_CURSOR_POSITION_INFO
    #create cursor tracking sprites
    @cur_location = Sprite.new
    @cur_location.bitmap = Bitmap.new(80,60)
    @cur_location.x = Graphics.width-@cur_location.bitmap.width
    @cur_location.y = Graphics.height-@cur_location.bitmap.height
    @cur_location.z = 1000 
  end
  def update_location
    return unless @cur_location
    if @cursor.active
      @cur_location.bitmap.clear
      @cur_location.bitmap.font.size = 30
      @cur_location.bitmap.draw_text(0,0,80,40,sprintf("%d, %d", @map_x, @map_y),2)
      @cur_location.bitmap.draw_text(0,24,80,40, sprintf("%d h", @h),2) if $game_map.iso?
    end
  end
  def dispose_location
    return unless @cur_location
    @cur_location.bitmap.dispose
    @cur_location.dispose
  end
  def visible=(bool)
    super
    @cur_location.visible = bool if @cur_location
  end
  #------------------------------------------------------------------
  #* draw and clear ranges sprites
  #------------------------------------------------------------------
  def clear_target_sprites
    for sprite in @target_sprites
      sprite.dispose
    end
    @target_sprites.clear
  end
  #------------------------------------------------------------------
  #* draw ranges sprites
  #------------------------------------------------------------------
  def draw_target_sprites
    type = @cursor.target_area[0]
    return unless type
    for x, y in @cursor.target_positions
      @target_sprites.push(Sprite_Range.new(self.viewport, type, x, y)) 
    end
  end
  #------------------------------------------------------------------
  #* update ranges sprites
  #------------------------------------------------------------------
  def update_ranges_sprites
    @target_sprites.each{|sp| sp.update}
  end
  
  def refresh_targets
    for sp in @targets_arrows
      sp.dispose
    end
    @targets_arrows.clear
    for bat in @cursor.targets.uniq
      @targets_arrows.push(TBS_Target_Cursor.new(self.viewport, bat.x, bat.y))
    end
  end
  def update_targets
    @targets_arrows.each{ |sp| sp.update }
  end
end