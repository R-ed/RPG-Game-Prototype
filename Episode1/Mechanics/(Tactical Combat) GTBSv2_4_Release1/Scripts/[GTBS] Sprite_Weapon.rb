=begin
#==============================================================================
# Sprite_Weapon
#------------------------------------------------------------------------------
# Weapon for display the sprites.
#==============================================================================
module RPG
  class Weapon
    def graphic
      GTBS.get_weapon_graphic(@id)
    end
  end
end

class Sprite_Weapon < Sprite_Base
  #--------------------------------------------------------------------------
  # Constants
  #--------------------------------------------------------------------------
  ORIGIN          = 0
  ANGLE_S         = 1
  ANGLE_E         = 2
  XSCALE          = 3
  YSCALE          = 4
  FRAME_COUNT     = 5
  ROTATE_ALLOWED  = 6
  FRAME_SPEED     = 7
  
  #--------------------------------------------------------------------------
  # Properties
  #--------------------------------------------------------------------------
  attr_accessor :battler
  
  #--------------------------------------------------------------------------
  # ● Initialize method
  #--------------------------------------------------------------------------
  def initialize(viewport,battler = nil)
    super(viewport)
    @battler = battler
    @action = []
    self.bitmap = Bitmap.new(1,1)
    reset
    self.visible = false
  end
  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose if self.bitmap != nil
    super
  end
  #--------------------------------------------------------------------------
  # ● Assign Weapon Graphics. 
  #--------------------------------------------------------------------------  
  def weapon_graphics(left = false)
    return if @battler.nil?
    #if @battler.actor?
      weapon = @battler.current_weapon
    #else
    #  weapon = $data_weapons[@battler.weapon]
    #end
    return if weapon == nil # If there is no weapons cancel
    if weapon.graphic == ""  # If you use the icon
      icon_index = weapon.icon_index
      self.bitmap = Cache.system("Iconset")
      self.src_rect.set(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    else # If you have specified ID icon, if that is the graphics.
      self.bitmap = Cache.character(weapon.graphic)
    end
  end

  #--------------------------------------------------------------------------  
  # reset
  #--------------------------------------------------------------------------  
  def reset
    @action.clear    #Action Information Storage
    set_rotation_point(5)

    #reset scale offsets
    self.zoom_x = 1
    self.zoom_y = 1
    
    #reset rotation
    @rotate_start = 0
    @rotate_end   = 0
    self.z = 0
    self.angle = 0
    
    #Reset local variables
    @frame_count = 0
    @current_frame = 0
    @frame_speed = 0
    @can_rotate = false
    
    self.mirror = false
    self.visible = false
  end
  
  def set_rotation_point(dir)
    #Set OX
    case dir
    when 7,4,1
      self.ox = 0
    when 8,5,2
      self.ox = self.src_rect.width/2
    when 9,6,3
      self.ox = self.src_rect.width
    end
    
    #Set OY
    case dir
    when 7,8,9
      self.oy = 0
    when 4,5,6
      self.oy = self.src_rect.height/2
    when 1,2,3
      self.oy = self.src_rect.height/2
    end
  end
  
  #--------------------------------------------------------------------------
  # ● Get the weapons freeze action
  #--------------------------------------------------------------------------  
  def weapon_action(action)
    # If you do not have name to hide
    if action == ""
      reset
    end
    # unarmed to hide
    if @weapon_id == 0
      reset
    # receive a weapon Action Information
    else
      weapon_graphics  #sets graphic icon
      @action = action
      
      @origin_sprite = SceneManager.scene.get_battler_sprite(@battler)
      @origin_sprite.update_position
      set_rotation_point(@action[ORIGIN])

      self.zoom_x = @action[XSCALE]
      self.zoom_y = @action[YSCALE]
      @rotate_start = @action[ANGLE_S]
      @rotate_end = @action[ANGLE_E]
      @can_rotate = @action[ROTATE_ALLOWED]
      if @can_rotate
        dir = @origin_sprite.get_direction
        rotate_count = 0
        reverse_anim = false
        case dir
        when 4
          if @battler.weapon_index == 1
            self.z = @origin_sprite.z + 1
          end
        when 2
          rotate_count = 1
          self.z = @origin_sprite.z + 1
          if @battler.weapon_index == 1
            reverse_anim = true
          end
        when 6
          rotate_count = 2
          if @battler.weapon_index != 1
            self.z = @origin_sprite.z + 1
          end
          reverse_anim = true
        when 8 
          rotate_count = 3
          if @battler.weapon_index == 1
            reverse_anim = true
          end
        end
        change_rotate = rotate_count * 90
        @rotate_start += change_rotate
        @rotate_end += change_rotate
        if reverse_anim == true
          temp_end = @rotate_end
          temp_start = @rotate_start
          @rotate_start = temp_end + 270
          @rotate_end = temp_start + 270
          self.mirror = true
          if self.ox == self.src_rect.width
            self.ox = 0
          elsif self.ox == self.src_rect.width/2
            self.ox == self.src_rect.width/2
          else
            self.ox = self.src_rect.width
          end          
        end
      end
      self.angle = @rotate_start;
      
      set_position
      
      @frame_count = @action[FRAME_COUNT]
      @current_frame = 0;
      @frame_speed = @action[FRAME_SPEED] || 1
      calculate_movement_info
      self.visible = true
      self.update
    end
  end  
  
  def set_position
    self.x = @origin_sprite.x
    self.y = @origin_sprite.y - @origin_sprite.oy/2
    return if @origin_sprite.nil?
    
    dir = @origin_sprite.get_direction
    if dir == 6
      self.x += self.src_rect.width/3
    elsif dir == 4
      self.x -= self.src_rect.width/3
    elsif dir == 8
      self.y -= self.src_rect.height/3
    end
  end
  
  def calculate_movement_info
    @angling = (@rotate_end - @rotate_start)/@frame_count
  end
  
  def update
    if @current_frame < @frame_count && self.visible #&& Graphics.frame_count % @frame_speed == 0
      self.angle += @angling
      @current_frame += 1
    elsif @current_frame >= @frame_count && self.visible
      reset
    end
    super
  end
end
=end