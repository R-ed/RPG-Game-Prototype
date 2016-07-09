#===============================================================================
# Class Progress_Bar
#===============================================================================
class Progress_Bar
  
  #----------------------------------------------------------------------------
  # Constants
  #----------------------------------------------------------------------------
  Gauge_Width = 100
  Gauge_Height = 16
  Animation_Time = [1, GTBS::STAT_ANIM_TIME].max
  Gauge_Font_Size = GTBS::Status_Gauge_Font_Size
  Gauge_Gradient_Style = 1  #vertical gradient
  #Colors
  Back_Gauge_Color = Color.new(255,255,255,255)
  Transparent = Color.new(0,0,0,0) #for edge
  Inner_Color1 = Color.new(0,0,0,200)
  Inner_Color2 = Color.new(75,75,75,200)
  Gauge_Opacity = 200
  #----------------------------------------------------------------------------
  # * Object Intialization
  #    
  #----------------------------------------------------------------------------
  def initialize(window,ox, oy,  type)
    @width            = Gauge_Width
    @height           = Gauge_Height
    @window = window
    @rect = Rect.new(ox, oy, Gauge_Width, Gauge_Height)
    @ox, @oy, @wx, @wy = ox, oy, Gauge_Width, Gauge_Height
    @type             = type
    @current, @max    = 0,100
    @current2, @max2  = 0,100
    @animation_count  = 0
    @storage          = []
    resize_fill 
  end
    
  #----------------------------------------------------------------------------
  # Get bitmap, keep the link if the window is resize or other
  #----------------------------------------------------------------------------
  def bitmap
    @window.contents
  end
  
  #----------------------------------------------------------------------------
  # * refresh 
  #----------------------------------------------------------------------------
  def refresh(current = @current, max = @max)
    if !animating?
      @current2 = current
      @max2 = max
      if @current != @current2   or  @max != @max2
        @animation_count = Animation_Time
        resize_fill
      end
    else
      abort_current_animation
      @storage.push [current, max]
    end
    update
  end
  #----------------------------------------------------------------------------
  # Abort Current Animation - Aborts animation in favor of current request
  #----------------------------------------------------------------------------
  def abort_current_animation
    @animation_count = 1
  end
  #----------------------------------------------------------------------------
  # * animating? 
  #----------------------------------------------------------------------------
  def animating?
    return @animation_count > 0
  end
  
  #----------------------------------------------------------------------------
  # * calculate_fill_perc 
  #----------------------------------------------------------------------------
  def calculate_fill_perc(current, max)
    return 0 if max == 0
    return 1.0 if max == nil
    return current.to_f/max
  end
  
  #----------------------------------------------------------------------------
  # * resize_fill 
  #----------------------------------------------------------------------------
  def resize_fill
    @old_perc = calculate_fill_perc(@current, @max)
    @new_perc = calculate_fill_perc(@current2, @max2)
    @rate = 1 if @max == nil or @max2 == nil
    @rate = (@new_perc-@old_perc)/Animation_Time
  end
  
  #----------------------------------------------------------------------------
  # * update 
  #----------------------------------------------------------------------------
  def update
    if animating?
      @animation_count -= 1
      self.fill(@old_perc + (@rate*(Animation_Time-@animation_count)))
      if @animation_count == 0
        update_current_info
      end
    elsif @storage.size > 0
      current, max = @storage.shift
      refresh(current, max)
    end
  end
  
  #----------------------------------------------------------------------------
  # * update_current_info 
  #----------------------------------------------------------------------------
  def update_current_info
    @current, @min, @max = @current2, @min2, @max2
  end
  
  #----------------------------------------------------------------------------
  # * refresh 
  #----------------------------------------------------------------------------
  def get_color(rate)
    case @type
    when 0 #HP
      color1 = Color.new(80 - 24 * rate, 80 * rate, 14 * rate, Gauge_Opacity)
      color2 = Color.new(240 - 72 * rate, 240 * rate, 62 * rate, Gauge_Opacity)
    when 1 #MP
      color1 = Color.new(14 * rate, 80 - 24 * rate, 80 * rate, Gauge_Opacity)
      color2 = Color.new(62 * rate, 240 - 32 * rate, 240 * rate, Gauge_Opacity)
    when 2 #AT
      color1 = Color.new(180 * rate, 100 + 32 * rate, 30 * rate, Gauge_Opacity)
      color2 = Color.new(200 + 10 *  rate, 80 - 10 * rate, 30 * rate, Gauge_Opacity)
    else
      color1 = Color.new(30 * rate, 150 - 24 * rate, 20 * rate, Gauge_Opacity)
      color2 = Color.new(50 * rate, 180 - 24 * rate, 30 * rate, Gauge_Opacity)
    end 
    return color1, color2
  end
  
  #----------------------------------------------------------------------------
  # * fill 
  #----------------------------------------------------------------------------
  def fill(rate)
    self.bitmap.font.size = Gauge_Font_Size
    self.bitmap.clear_rect(@ox, @oy, Gauge_Width, Gauge_Height)
    color1, color2 = get_color(rate)
    fill_perc = rate*@width
    if rate >= 1.0
      rate = 1
    end
    
    draw_back_gauge
    #make_inner gauge
    ox, oy = @rect.x, @rect.y
    data_gauge = Bitmap.new(@width-4, @height-4)
    if GTBS::Use_Dual_Gradiant_Bars
      if @fill_back.nil?
        data_gauge.gradation_rect(0,0,(@width-4),@height-4, color1, color2, Gauge_Gradient_Style)
        @fill_back = data_gauge.clone
      end
    else
      if @fill_back.nil?
        @fill_back = fill_with_img(data_gauge)
      end
    end
    data_gauge = @fill_back.clone
    self.bitmap.blt(ox+2, oy+2, data_gauge, Rect.new(0,0,(@width-4)*rate,@height-4), Gauge_Opacity)
    data_gauge.dispose
    set_text
  end   
  #----------------------------------------------------------------------------
  # Fill with img
  #----------------------------------------------------------------------------
  def fill_with_img(bmp)
    case @symbol
    when Vocab.hp
      if (File.exist?("Graphics/System/GTBS/" + GTBS::HP_Status_Img))
        src_bitmap = Cache.system("GTBS/" + GTBS::HP_Status_Img)
        bmp.stretch_blt(bmp.rect, src_bitmap, src_bitmap.rect)
      else
        color1, color2 = get_color(1) #get color rate for full
        bmp.gradient_fill_rect(bmp.rect, color1, color2)
      end
    when Vocab.mp
      color1, color2 = get_color(1) #get color rate for full
      if (File.exist?("Graphics/System/GTBS/" + GTBS::MP_Status_Img))
        src_bitmap = Cache.system("GTBS/" + GTBS::MP_Status_Img)
        bmp.stretch_blt(bmp.rect, src_bitmap, src_bitmap.rect)
      else
        color1, color2 = get_color(1) #get color rate for full
        bmp.gradient_fill_rect(bmp.rect, color1, color2)
      end
    when Vocab.at
      color1, color2 = get_color(1) #get color rate for full
      if (File.exist?("Graphics/System/GTBS/" + GTBS::AT_Status_Img))
        src_bitmap = Cache.system("GTBS/" + GTBS::AT_Status_Img)
        bmp.stretch_blt(bmp.rect, src_bitmap, src_bitmap.rect)
      else
        color1, color2 = get_color(1) #get color rate for full
        bmp.gradient_fill_rect(bmp.rect, color1, color2)
      end
    else
      color1, color2 = get_color(1) #get color rate for full
      bmp.gradient_fill_rect(bmp.rect, color1, color2)
    end
    return bmp
  end
  #----------------------------------------------------------------------------
  # Draw Back Guage
  #----------------------------------------------------------------------------
  def draw_back_gauge
    unless @back_gauge
      @back_gauge = Bitmap.new(Gauge_Width, Gauge_Height)
      #make_back - white
      @back_gauge.fill_rect(0,0,@width, @height, Back_Gauge_Color)
      #make_rounded back
      @back_gauge.set_pixel(0, 0, Transparent)
      @back_gauge.set_pixel(0, @height, Transparent)
      @back_gauge.set_pixel(@width, @height, Transparent)
      @back_gauge.set_pixel(@width, 0, Transparent)
      @back_gauge.gradation_rect(1, 1, @width-2, @height-2, Inner_Color1, Inner_Color2, Gauge_Gradient_Style)
    end
    self.bitmap.blt(@rect.x, @rect.y, @back_gauge, @back_gauge.rect, Gauge_Opacity)
  end
  
  #----------------------------------------------------------------------------
  # * set_symbol 
  #----------------------------------------------------------------------------
  def set_symbol(sym)
    return if not sym.is_a?(String)
    @symbol = sym
    set_text
  end
  
  #----------------------------------------------------------------------------
  # * set_text 
  #----------------------------------------------------------------------------
  def set_text
    if @symbol != nil
      ts = self.bitmap.text_size(@symbol)
      self.bitmap.draw_outline_text(@ox,@oy,ts.width,@height, @symbol)
      if @max2 == nil
        string = sprintf("%s / %s", GTBS::Unknown_Text , GTBS::Unknown_Text ) 
      else
        string =  sprintf("%d / %d", @current2, @max2) 
      end
      self.bitmap.draw_outline_text(@ox,@oy,@width,@height,string,2)
    end
  end
end
