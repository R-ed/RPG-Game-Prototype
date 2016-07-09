class Turn_Sprite < Sprite_Base
  #---------------------------------------------------------------------------- 
  # * Doom Pop - This is used to display a "doom counter" during battle
  #---------------------------------------------------------------------------- 
  def doom_pop(value) #Used only for doom right now.
    dispose_damage
    if value.is_a?(Numeric)
      damage_string = value.abs.to_s
    else
      damage_string = value.to_s
    end
    bitmap = Bitmap.new(160, 48)
    bitmap.font.name = GTBS.font
    bitmap.font.size = 20
    bitmap.font.color.set(0, 0, 0)
    bitmap.draw_text(-1, 12-1, 160, 36, damage_string, 1)
    bitmap.draw_text(+1, 12-1, 160, 36, damage_string, 1)
    bitmap.draw_text(-1, 12+1, 160, 36, damage_string, 1)
    bitmap.draw_text(+1, 12+1, 160, 36, damage_string, 1)
    if value.is_a?(Numeric) and value < 0
      bitmap.font.color.set(176, 255, 144)
    else
      bitmap.font.color.set(255, 255, 255)
    end
    bitmap.draw_text(0, 12, 160, 36, damage_string, 1)
    @_damage_sprite = ::Sprite.new(self.viewport)
    @_damage_sprite.bitmap = bitmap
    @_damage_sprite.ox = 80
    @_damage_sprite.oy = 20
    @_damage_sprite.x = self.x
    @_damage_sprite.y = self.y - (self.oy / 1.5)
    @_damage_sprite.z = 3000
    @_damage_duration = 40
  end

  def start_animation(animation, mirror = false, direction = 8)
    return if animation.nil?
    @direction = direction
    @turnable = animation.name.downcase.include?("[turn]")
    @updated = false
    super(animation, mirror)
  end
  
  
  def animation_set_sprites(frame)
    super(frame)
    for i in 0..15
      sprite = @animation_sprites[i]
      if @turnable
        d = @direction
        sprite.angle += (d == 8 ? 0 : d == 6 ? 270 : d == 4 ? 90 : 180)
      end
    end
  end
  def initialize(viewport)
    @_damage_duration = 0
    super(viewport)
  end
  
  def dispose_damage
    if @_damage_sprite != nil
      @_damage_sprite.bitmap.dispose
      @_damage_sprite.dispose
      @_damage_sprite = nil
      @_damage_duration = 0
    end
  end
  
  def update
    update_damage
    super
  end
  
  def update_damage
    if @_damage_duration > 0
      @_damage_duration -= 1
      case @_damage_duration
      when 38..39
        @_damage_sprite.y -= 4
      when 36..37
        @_damage_sprite.y -= 2
      when 34..35
        @_damage_sprite.y += 2
      when 28..33
        @_damage_sprite.y += 4
      end
      @_damage_sprite.opacity = 256 - (12 - @_damage_duration) * 32
      if @_damage_duration == 0
        dispose_damage
      end
    end
  end

  def damage(value, critical)
    dispose_damage
    if value.is_a?(Numeric)
      damage_string = value.abs.to_s
    else
      damage_string = value.to_s
    end
    bitmap = Bitmap.new(160, 48)
    bitmap.font.name = "Arial Black"
    bitmap.font.size = 32
    bitmap.font.color.set(0, 0, 0)
    bitmap.draw_text(-1, 12-1, 160, 36, damage_string, 1)
    bitmap.draw_text(+1, 12-1, 160, 36, damage_string, 1)
    bitmap.draw_text(-1, 12+1, 160, 36, damage_string, 1)
    bitmap.draw_text(+1, 12+1, 160, 36, damage_string, 1)
    if value.is_a?(Numeric) and value < 0
      bitmap.font.color.set(176, 255, 144)
    else
      bitmap.font.color.set(255, 255, 255)
    end
    bitmap.draw_text(0, 12, 160, 36, damage_string, 1)
    if critical
      bitmap.font.size = 20
      bitmap.font.color.set(0, 0, 0)
      bitmap.draw_text(-1, -1, 160, 20, GTBS::Critical_Text, 1)
      bitmap.draw_text(+1, -1, 160, 20, GTBS::Critical_Text, 1)
      bitmap.draw_text(-1, +1, 160, 20, GTBS::Critical_Text, 1)
      bitmap.draw_text(+1, +1, 160, 20, GTBS::Critical_Text, 1)
      bitmap.font.color.set(255, 255, 255)
      bitmap.draw_text(0, 0, 160, 20, GTBS::Critical_Text, 1)
    end
    @_damage_sprite = ::Sprite.new(self.viewport)
    @_damage_sprite.bitmap = bitmap
    @_damage_sprite.ox = 80
    @_damage_sprite.oy = 20
    @_damage_sprite.x = self.x
    @_damage_sprite.y = self.y - (self.oy/1.5)
    @_damage_sprite.z = 3000
    @_damage_duration = 60
  end
end


#------------------------------------------------------------------------------
# * Bitmap - This class is used for all images, I added some new methods
#------------------------------------------------------------------------------
class Bitmap
  #============================================================================
  # CONSTANTS 
  #============================================================================
  
  Color_White_Text = Color.new(30,30,30,255)
  Color_Shadow_Text = Color.new(255,255,255,255)
  #============================================================================
  
  #----------------------------------------------------------------------------
  # * Draw Outline Text - Method to draw outlined text
  #----------------------------------------------------------------------------
  def draw_outline_text(x,y,w,h,text,align=0,clear = 1, ocolor = nil)
    color = self.font.color.clone
    if clear == 1
      self.font.color = Color.new(50,50,50,200)
    elsif clear == 0
      self.font.color = Color.new(0,0,0)
    end
    self.draw_text(x+1,y+1,w,h,text,align)
    self.draw_text(x+1,y-1,w,h,text,align)
    self.draw_text(x-1,y-1,w,h,text,align)
    self.draw_text(x-1,y+1,w,h,text,align)
    self.draw_text(x-1,y,w,h,text,align)
    self.draw_text(x+1,y,w,h,text,align)
    self.draw_text(x,y+1,w,h,text,align)
    self.draw_text(x,y-1,w,h,text,align)
    self.font.color = color
    self.draw_text(x,y,w,h,text,align)
  end
  
  #----------------------------------------------------------------------------
  # * Gradation Rect - Method to draw a fancy gradient rect
  #----------------------------------------------------------------------------
  def gradation_rect(x, y, width, height, color1, color2, align = 0)
    color = Color.new(0, 0, 0, 0)
    if align == 0
      for i in 0...width
        color.red   = color1.red + (color2.red - color1.red) * i / (width - 1)
        color.green = color1.green +
                (color2.green - color1.green) * i / (width - 1)
        color.blue  = color1.blue +
                (color2.blue - color1.blue) * i / (width - 1)
        color.alpha = color1.alpha +
                (color2.alpha - color1.alpha) * i / (width - 1)
        fill_rect(x + i, y, 1, height, color) rescue nil
      end
    elsif align == 1
      for j in 0...height
        color.red   = color1.red +
                (color2.red - color1.red) * j / (height - 1)
        color.green = color1.green +
                (color2.green - color1.green) * j / (height - 1)
        color.blue  = color1.blue +
                (color2.blue - color1.blue) * j / (height - 1)
        color.alpha = color1.alpha +
                (color2.alpha - color1.alpha) * j / (height - 1)
        fill_rect(x, y + j, width, 1, color) rescue nil
      end
    elsif align == 2
      for j in 0...height
        for i in 0...width
          color.red   = color1.red + (color2.red - color1.red) *
                  (i / (width - 1.0) + j / (height - 1.0)) / 2
          color.green = color1.green + (color2.green - color1.green) *
                  (i / (width - 1.0) + j / (height - 1.0)) / 2
          color.blue  = color1.blue + (color2.blue - color1.blue) *
                  (i / (width - 1.0) + j / (height - 1.0)) / 2
          color.alpha = color1.alpha + (color2.alpha - color1.alpha) *
                  (i / (width - 1.0) + j / (height - 1.0)) / 2
          set_pixel(x + i, y + j, color) rescue nil
        end
      end
    elsif align == 3
      for j in 0...height
        for i in 0...width
          color.red   = color1.red + (color2.red - color1.red) *
                (i / (width - 1.0) + j / (height - 1.0)) / 2
          color.green = color1.green + (color2.green - color1.green) *
                (i / (width - 1.0) + j / (height - 1.0)) / 2
          color.blue  = color1.blue + (color2.blue - color1.blue) *
                (i / (width - 1.0) + j / (height - 1.0)) / 2
          color.alpha = color1.alpha + (color2.alpha - color1.alpha) *
                (i / (width - 1.0) + j / (height - 1.0)) / 2
          set_pixel(x + width - i - 1, y + j, color) rescue nil
        end
      end
    end
  end
  
  #----------------------------------------------------------------------------
  # * draw_shadow_text
  #----------------------------------------------------------------------------
  def draw_shadow_text(x, y, w, h, text="", align=0, color1 = Color_White_Text, color2=Color_Shadow_Text)  
    self.font.color = color1
    self.draw_text(x+2,y+2,w,h, text, align)
    self.font.color = color2
    self.draw_text(x,y,w,h, text, align)  
  end
end
