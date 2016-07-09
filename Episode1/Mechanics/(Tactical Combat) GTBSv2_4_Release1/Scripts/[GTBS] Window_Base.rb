#===============================================================================
# This Script is made specfically for usage with GTBS version 1.5.1.4 by GubiD.
#===============================================================================
module GTBS_Win_Base
  WLH = 24
  attr_accessor :active
  #--------------------------------------------------------------------------
  # Create Contents
  #--------------------------------------------------------------------------
  def create_contents
    super
    create_gtbs_back
  end
  #--------------------------------------------------------------------------
  # * Update @back if defined
  #--------------------------------------------------------------------------
  def update
    super
    if @back
      @back.x = self.x
      @back.y = self.y
      @back.update
    end
  end 

  #-----------------------------------------------------------
  # This change checks for a background image and if exist set its visiblity
  #-----------------------------------------------------------
  def visible=(bool)
    if @back
      @back.visible = bool
    end
    super(bool)
  end
    #------------------------------------------------------------------------
  #* Use picture for window backround in gtbs
  # can't have incompatibility issue
  #------------------------------------------------------------------------
  def create_gtbs_back 
    case self
    when Windows_Status_GTBS
      back_name = 'TBS_Status.png'
    when  Window_EXP_Earn
      back_name = 'TBS_Exp_Gain.png'
    when Commands_All
      back_name = 'Commands_All.png'
    when Battle_Option
      back_name = 'TBS_Battle_Option.png'
    when Command_Confirm
      back_name = 'Command_Confirm.png'
    when Window_Actor_Display
      back_name = 'Actor_Display.png'
    when Window_Config
      back_name = 'TBS_Config.png'
    when  Window_Select_Color
      back_name = 'TBS_Select_Color.png'
    when TBS_Item, TBS_Skill
      back_name = 'TBS_Item_Skill.png'
    when Window_Full_Status
      back_name = 'TBS_Full_Status.png'
    end
    if back_name and FileTest.exist?('Graphics/Pictures/GTBS/' + back_name)
      @back = Sprite.new
      self.opacity = 0
      @back.bitmap = Cache.picture('GTBS/' + back_name)
      @back.visible = false
      @back.opacity = GTBS::CONTROL_OPACITY
    else
      self.opacity = GTBS::CONTROL_OPACITY
    end
  end
  #--------------------------------------------------------------------------
  # * move the window in the position
  #   using Num_Pad as reference for position
  #--------------------------------------------------------------------------
  def move_to(pos)
    if (@current_pos != nil && @current_pos == pos)
      return
    end
    if pos == 5
      self.x = (Graphics.width - self.width) / 2
      self.y = (Graphics.height - self.height) / 2
    end
    if [1, 2, 3].include?(pos)#bottom
      self.y = Graphics.height - self.height
      if @win_help != nil
        self.y -= @win_help.height
      end
    end
    if [1, 4, 7].include?(pos)#left
      self.x = 0
    end
    if [7, 8, 9].include?(pos)#top
      self.y = 0
    end
    if [3, 6, 9].include?(pos)#right
      self.x = Graphics.width - self.width
    end
    @current_pos = pos
  end

    #----------------------------------------------------------------------------
  # draw_state_icon
  #---------------------------------------------------------------------------- 
  def draw_state_icon(state,x,y,size = 24)
    unless state.nil?
      draw_icon(state.icon_index, x, y, self.contents.width)  
    end
  end
  #----------------------------------------------------------------------------
  # draw_actor_state  (Compatibiliy?)
  #----------------------------------------------------------------------------  
  def draw_actor_state(actor,x,y,width=120)
    for i in 0...actor.states.size
      key = actor.states[i]
      if key.is_a?(RPG::State)
        state = key
      else
        state = $data_states[key]
      end
      draw_state_icon(state,x+(24*i),y)
    end
  end

  #--------------------------------------------------------------------------
  # * return battle menu skill name, by actors class
  #--------------------------------------------------------------------------
  def get_class(class_id)
    return GTBS.get_class_skill_name(class_id)
  end
  
  #---------------------------------------------------------------------------- 
  # Set Dimensions - Used for setting cutwidth and height of an image
  #----------------------------------------------------------------------------
  def set_dimensions(actor, bitmap)
    if !actor.animated?
      cw = bitmap.width / 4
      ch = bitmap.height / 4
    else
      w,h = actor.check_frame_pose_overrrides
      cw = bitmap.width / w
      ch = ((bitmap.height / h) / 4)
    end
    return cw, ch
  end  
  
  #--------------------------------------------------------------------------
  # * Draw Graphic
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #-------------------------------------------------------------------------- 
  def draw_actor_graphic(actor, x, y)
    args =  [actor.character_name, actor.character_hue]
    bitmap = Cache.battler(*args) 
    
    sx = 0
    sy = 0
  
    cw,ch = set_dimensions(actor, bitmap)
  
    src_rect = Rect.new(sx, sy, cw, ch)
    self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
  end

  #--------------------------------------------------------------------------
  # * Draw HP
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : Width
  #--------------------------------------------------------------------------
  def draw_actor_hp(actor, x, y, width = 120)
    if actor.hide_info?
      draw_actor_hp_gauge(actor, x, y, width)
      self.contents.font.color = system_color
      self.contents.draw_text(x, y, 30, WLH, Vocab::hp_a)
      self.contents.font.color = hp_color(actor)
      last_font_size = self.contents.font.size
      xr = x + width
      if width < 120
        self.contents.draw_text(xr - 44, y, 44, WLH, "???", 2)
      else 
        self.contents.draw_text(xr - 99, y, 44, WLH, "???", 2)
        self.contents.font.color = normal_color
        self.contents.draw_text(xr - 55, y, 11, WLH, "/", 2)
        self.contents.draw_text(xr - 44, y, 44, WLH, "???", 2) 
      end
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # * Draw HP gauge
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : Width
  #-------------------------------------------------------------------------- 
  def draw_actor_hp_gauge(actor, x, y, width = 120)
    if actor.hide_info?
      gw = width * 100 / 100
      gc1 = hp_gauge_color1
      gc2 = hp_gauge_color2
      self.contents.fill_rect(x, y + WLH - 8, width, 6, gauge_back_color)
      self.contents.gradient_fill_rect(x, y + WLH - 8, gw, 6, gc1, gc2)
    else
      super
    end
  end
  #--------------------------------------------------------------------------
  # * Draw MP
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : Width
  #-------------------------------------------------------------------------- 
  def draw_actor_mp(actor, x, y, width = 120)
    if actor.hide_info?
      draw_actor_mp_gauge(actor, x, y, width)
      self.contents.font.color = system_color
      self.contents.draw_text(x, y, 30, WLH, Vocab::mp_a)
      self.contents.font.color = mp_color(actor)
      last_font_size = self.contents.font.size
      xr = x + width
      if width < 120
        self.contents.draw_text(xr - 44, y, 44, WLH, "???", 2)
      else
        self.contents.draw_text(xr - 99, y, 44, WLH, "???", 2)
        self.contents.font.color = normal_color
        self.contents.draw_text(xr - 55, y, 11, WLH, "/", 2)
        self.contents.draw_text(xr - 44, y, 44, WLH, "???", 2) 
      end
    else
      super
    end
  end 

  #--------------------------------------------------------------------------
  # * Draw MP Gauge
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : Width
  #-------------------------------------------------------------------------- 
  def draw_actor_mp_gauge(actor, x, y, width = 120)
    if actor.hide_info?
      gw = width * 100 / [100, 1].max
      gc1 = mp_gauge_color1
      gc2 = mp_gauge_color2
      self.contents.fill_rect(x, y + WLH - 8, width, 6, gauge_back_color)
      self.contents.gradient_fill_rect(x, y + WLH - 8, gw, 6, gc1, gc2) 
    else
      super
    end 
  end
  #--------------------------------------------------------------------------
  # * Draw Face Graphic
  #     face_name  : Face graphic filename
  #     face_index : Face graphic index
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     size       : Display size
  #--------------------------------------------------------------------------
  def draw_face(face_name, face_index, x, y, size = 96)
    begin
      super
    rescue
      return
    end
  end
end

#===============================================================================
# Class TBS_Window_Base
#===============================================================================
# Meta class to not affect the standard methods and improve compatibility with other scripts
#--------------------------------------------------------------------------------------------------------------------------
class TBS_Window_Base < Window_Base
  include GTBS_Win_Base
end
#===============================================================================
# Class TBS_Window_Selectable
#===============================================================================
# Just adding some new classes for easier commands within the window
#--------------------------------------------------------------------------
class TBS_Window_Selectable < Window_Selectable
  include GTBS_Win_Base
  def disabled_color
    return Color.new(155,155,155)
  end  
end
class TBS_Window_Command < Window_Command
  include GTBS_Win_Base
  def disabled_color
    return Color.new(155,155,155)
  end
end
class TBS_Win_Actor < Window_ActorCommand
  include GTBS_Win_Base  
  def disabled_color
    return Color.new(155,155,155)
  end
end

#===============================================================================
# Class Window_Message 
#===============================================================================

class TBS_Window_Message < Window_Message
  include GTBS_Win_Base
  #--------------------------------------------------------------------------
  # * Set Window Position and Opacity Level
  #-------------------------------------------------------------------------- 
  def reset_window
    super 
    position = $game_message.position
    case position
    when 0  # up
      self.y = 16
    when 1  # middle
      self.y = 160
    when 2  # down
      self.y = 304
    end 
  end
end 