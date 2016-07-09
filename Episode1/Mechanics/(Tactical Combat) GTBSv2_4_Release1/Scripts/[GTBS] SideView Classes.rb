class Sprite_Battler_MiniGTBS < Sprite_Battler_GTBS
  #----------------------------------------------------------------------------
  # Initialize - add new pos args
  #----------------------------------------------------------------------------
  def initialize(*args)
    @pos = POS.new(0,0)
    super(*args)
  end
  #--------------------------------------------------------------------------
  # Return the original pos
  #--------------------------------------------------------------------------
  def pos
    return @pos
  end
  #--------------------------------------------------------------------------
  # Set the origin pos
  #--------------------------------------------------------------------------
  def pos=(newpos)
    @pos = newpos if newpos != nil
    init_gtbs_movement_vars #update 'origin' and other movement variables
    @pos
  end
  #----------------------------------------------------------------------------
  # Update Location - Updates the x,y,z of the sprite
  #----------------------------------------------------------------------------
  
  ###NEED TO MOVE TO USING SAME METHOD AS SPRITE_BATTLERGTBS
  #def update_position
  #  self.x = @pos.x
  #  self.y = @pos.y
  #end
  
  #----------------------------------------------------------------------------
  def update
    if @character.nil?
      return
    end
    super
  end
  #----------------------------------------------------------------------------
  # Offset Large Unit - Sprite
  #----------------------------------------------------------------------------
  def offset_large_unit
  end
  #----------------------------------------------------------------------------
  # Is Mini?
  #----------------------------------------------------------------------------
  def is_mini?
    return true
  end
  #-------------------------------------------------------------
  # Get Direction - Override get direction from super in case another script
  # alias's it. 
  #-------------------------------------------------------------
  def get_direction
    return @dir if !@dir.nil?
    return 0 
  end
end
class Sprite_Battler_GTBS
  #alias upd_bmp_mini_force_refresh update_bitmap
  def update_bitmap(force = false)
    if force
      @character_name = "";
    end
    super()
    #upd_bmp_mini_force_refresh
  end
  def refresh
    update_bitmap(true)
  end
  def force_direction(dir)
    @dir = dir
  end
  def is_mini?
    return false
  end
  def gather_pos_data
    return self.x,self.y,@cw,@ch
  end
end
#----------------------------------------------------------------------------
# Sprite Character for VX Ace addition
#----------------------------------------------------------------------------
class Sprite_Character < Sprite_Base
  alias end_anim_spr_char_gtbs end_animation
  def end_animation
    return super if @character.nil?
    end_anim_spr_char_gtbs
  end
  alias end_bal_spr_char_gtbs end_balloon
  def end_balloon
    return if @character.nil?
    end_bal_spr_char_gtbs
  end
end
#----------------------------------------------------------------------------
# Mini Command UI - Used for Mini Battle Scene Command selection
#----------------------------------------------------------------------------
=begin
class Mini_Command_UI < Window_Selectable
  #----------------------------------------------------------------------------
  attr_reader :commands
  #----------------------------------------------------------------------------
  WLH = 24
  #----------------------------------------------------------------------------
  def initialize(x,y)
    super(x,y,160,64)
    create_contents
    @commands = []
  end
  #----------------------------------------------------------------------------
  #def create_contents
  #  self.bitmap = Bitmap.new(self.width-32, self.height-32)
  #end
  #----------------------------------------------------------------------------
  def commands=(cmds)
    @commands = cmds
    self.height = (@commands.size * 24) + 32
    create_contents
    refresh
  end
  #----------------------------------------------------------------------------
  def command
    return @commands[self.index]
  end
  #----------------------------------------------------------------------------
  def refresh
    draw_commands
  end
  #----------------------------------------------------------------------------
  def draw_commands
    for i in 0...@commands.size
      draw_item(i, @commands[i])
    end
  end
  #----------------------------------------------------------------------------
  def draw_item(index, cmd)
    ts = self.contents.text_size(cmd)
    self.contents.draw_text(0,index*WLH,ts.width, ts.height,cmd)
  end
end
=end

=begin
class Game_Battler

  def mini_cmds(defending = false)
    returnValue = []
    if (defending == false)#attacking
      returnValue << GTBS.atk_command(@class_id)
    else #defending!
      returnValue << GTBS.def_command(@class_id)
    end
    # Area to add more attack/defensive commands. 
    return returnValue
  end

  def set_temp_direction(dir)
    @temp_dir = dir
  end
  def clear_temp_dir
    @temp_dir = nil
  end
  def direction
    if @temp_dir != nil
      return @temp_dir
    else
      return @direction
    end
  end
end
=end