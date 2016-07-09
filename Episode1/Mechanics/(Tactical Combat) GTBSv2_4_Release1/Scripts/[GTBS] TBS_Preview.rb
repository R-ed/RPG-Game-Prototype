#----------------------------------------------------------------------------
# class Window_TBS_Preview
# This class alow to draw preview damages for all affected battlers
#----------------------------------------------------------------------------

class Window_TBS_Preview < TBS_Window_Base
  WLH = 24
  Height = 2 * WLH
  #---------------------ICI---------------------------
  Heal_Color = Color.new(0, 255, 0, 255)
  Mp_Damage_Color = Color.new(0, 0, 255, 255)
  Default_Damage_Color = Color.new(255, 255, 255, 255)
  #---------------------LA-----------------------------
  #----------------------------------------------------------------------------
  # * initialize 
  #----------------------------------------------------------------------------
  def initialize(index, battler)
    @battler = battler
    width = 250
    height = 2 * WLH + 32
    if index == -1
      x = Graphics.width - width
      y = 155 - height
    else
      x = 0
      y = index * height
    end
    super(x, y, width, height)
    draw_name if index != -1
    self.opacity = 0
  end
  
  #----------------------------------------------------------------------------
  # * Draw Name 
  #----------------------------------------------------------------------------
  def draw_name
    self.contents.draw_text(0,0,width-32, WLH, @battler.name)
  end
  
  #----------------------------------------------------------------------------
  # * refresh 
  #----------------------------------------------------------------------------
  def refresh(result)
    bmp = self.contents
    hit, dmg, amp, hit_states,rem_states, mp = result 
    ts = bmp.text_size("Hit %: #{hit}")
    x = 5
    y = bmp.height-ts.height
    state_y = bmp.height-24
    w = ts.width
    h = ts.height
    bmp.fill_rect(0,y,bmp.width,h,Color.new(0,0,0,0))
    bmp.font.size = 18
    bmp.draw_outline_text(x, y, w, h, "Hit %: #{hit}")
    x = ts.width + 5
    w = bmp.width-ts.width-5
    color = bmp.font.color.clone
    if dmg < 0
      dmg = -dmg
      bmp.font.color = Heal_Color
    elsif mp
      bmp.font.color = Mp_Damage_Color
    else
       bmp.font.color = Default_Damage_Color
    end
    if dmg != 0
      bmp.draw_outline_text(x,y,w,h, "#{dmg}(+/- #{amp})", 2) 
    elsif  (hit_states.size > 0 or rem_states.size > 0)
      draw_states(x,state_y,rem_states, rem_states)
    else
      bmp.draw_outline_text(x,y,w,h, "#{dmg}(+/- #{amp})", 2) 
    end
     bmp.font.color = color
   end
     #----------------------------------------------------------------------------
  # Draws State Icons for Plus/Minus states, called via dmg_preview
  #----------------------------------------------------------------------------
  def draw_states(x,y,plus,minus = []) 
    i = 0
    for state in plus + minus
      if state.is_a?(Numeric)
        state = $data_states[state]
      end
      if state != nil
        draw_state_icon(state,x+(24*i),y)
        i += 1
      end
    end
  end

end