#===============================================================================
# This Script is made specfically for usage with GTBS version 1.5.1.4 by GubiD.
#===============================================================================

#----------------------------------------------------------------------------
# Sprite Range - Used to display all "RANGES" during battle
#----------------------------------------------------------------------------
class Sprite_Range < Sprite_Base
  attr_reader :pos
  #----------------------------------------------------------------------------
  #Constants
  #----------------------------------------------------------------------------
  ANIM_FRAMES = 4
  ANIM_SPEED = 6
  @@cache_bitmap = {} 
  #----------------------------------------------------------------------------
  # Object initialization
  #----------------------------------------------------------------------------
  #   type = 1-7, passed by 'def draw_ranges' from Scene_Battle_TBS
  #----------------------------------------------------------------------------
  def initialize(viewport, type, x, y)
    moveto(x, y)
    super(viewport) 
    self.opacity = 100
    @wait = 6
    @pattern = [0,1,2,3]
    @p_index = 0 #pattern index
    @type = type
    @pos = POS.new(x, y)
    @iso = $game_map.iso? 
    @anim = GTBS::ANIM_TILES
    self.ox = 16
    refresh
  end
  
  #----------------------------------------------------------------------------
  # Map is Iso?
  #----------------------------------------------------------------------------
  def iso?
    return @iso
  end
  
  def get_color(type)
    case type
    when 1; $game_system.attack_color
    when 2; $game_system.move_color
    when 3; $game_system.help_skill_color
    when 4; $game_system.attack_skill_color
    when 5; $game_system.attack_skill_color
    when 6; $game_system.help_skill_color
    when 7; $game_system.attack_color
    end
  end
  Transparent = Color.new(220,0,0,200)
  #----------------------------------------------------------------------------
  # Refresh - Process to update/set the bitmap for the object
  #----------------------------------------------------------------------------
  def refresh
    
    gtbs_color = get_color(@type)
    bmp = @@cache_bitmap[gtbs_color]
    
    unless bmp
      #create rectangle to fill if not using a picture
      iso = iso? ? '_iso' : ''
      bmp_name = sprintf( "GTBS/%s%s_range", gtbs_color.name, iso) 
      
      if @anim and FileTest.exist?(sprintf("Graphics/Pictures/%s.png", bmp_name))
        bmp = Cache.picture(bmp_name )
        @anim = (bmp.width >  2 * bmp.height)
      else
        bmp = draw_bitmap(gtbs_color)
      end
      @@cache_bitmap[gtbs_color] = bmp
    end
    
    self.bitmap = bmp
    if [5,6,7].include?(@type)
      self.opacity = 255
    end
    if @anim
      @cw = self.bitmap.width / ANIM_FRAMES 
    else
      @cw = self.bitmap.width
    end
    @ch = self.bitmap.height 
    update
    update_location
  end

  #----------------------------------------------------------------------------
  # draw bitmap
  #----------------------------------------------------------------------------
  def draw_bitmap(gtbs_color)
    color = gtbs_color.color
    if iso?
      #draw diamond
      h_tile = 30
      bmp = Bitmap.new(64, 32)
      rect = Rect.new(31, 16 - (h_tile / 2), 2, 1)
      for i in 0...(h_tile / 2)
        bmp.fill_rect(rect, color)
        rect.y =  32 - rect.y - 1
        bmp.fill_rect(rect, color)
        rect.y = 32 - rect.y
        rect.x -= 2
        rect.width += 4
      end
      self.ox = 32
    else
      #draw rectangle
      rect = Rect.new(1, 1, 30, 30)
      bmp = Bitmap.new(32, 32) 
      bmp.fill_rect(rect, color)
    end
    @anim = false
    return bmp
  end

  def moveto(x, y)
    if @pos.nil?
      @pos = POS.new(x,y)
    end
    @pos.moveto(x, y)
    @x = x % $game_map.width
    @y = y % $game_map.height
    @real_x = @x
    @real_y = @y
  end
  def screen_x
    $game_map.adjust_x(@real_x) * 32 + 16
  end
  def screen_y
    $game_map.adjust_y(@real_y) * 32
  end
  def screen_z
    return 0 
  end
  #----------------------------------------------------------------------------
  # Update Process
  #----------------------------------------------------------------------------
  def update
    super unless self.disposed?
    update_location
    return unless @anim
    update_animation
    update_bitmap
    
  end
  #----------------------------------------------------------------------------
  # Update Location - Updates the sprite location on the screen
  #----------------------------------------------------------------------------
  def update_location
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
  end
  
  #----------------------------------------------------------------------------
  # Update animation - used to progress the animation frame index
  #----------------------------------------------------------------------------
  def update_animation
    if @wait != 0
      @wait += 1
      if @wait % ANIM_SPEED == 0
        @wait %= ANIM_SPEED
        @p_index += 1 
        @p_index %= @pattern.size
      end
    end
  end
  
  #----------------------------------------------------------------------------
  # Update bitmap based on pattern
  #----------------------------------------------------------------------------
  def update_bitmap 
    sx = @pattern[@p_index] * @cw rescue sx = 0
    self.src_rect.set(sx, 0, @cw, @ch) 
  end
  
  #----------------------------------------------------------------------------
  # Updates X, Y, Z coords
  #----------------------------------------------------------------------------
  def update_location
    self.x = screen_x unless self.disposed?
    self.y = screen_y unless self.disposed?
    self.z = screen_z unless self.disposed?
  end
  
  #----------------------------------------------------------------------------
  # Dispose all the bitmap at the end of the battle
  #----------------------------------------------------------------------------
  def self.clear_bitmaps
    for bmp in @@cache_bitmap.values
      bmp.dispose
    end
    @@cache_bitmap.clear
  end
end