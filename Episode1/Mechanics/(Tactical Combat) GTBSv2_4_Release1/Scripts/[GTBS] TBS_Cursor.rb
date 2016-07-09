class TBS_Cursor < POS
  attr_accessor :active
  attr_reader :target_area,  :target_positions, :mode
  attr_reader :last_x, :last_y
  attr_accessor :range
  
  Attack = 'attack'
  Skill = 'skill'
  Item = 'item'
  Move = 'move'
  #
  #      @target_area = [
  #        6, 7, 8           #type
  #        bool             #line skill
  #        bool             #exclude center
  #        Numeric      #AoE range
  #        [0,0]
  #       ]
  #----------------------------------------------------------
  # cursor initilization
  #----------------------------------------------------------
  def initialize
    super
    @active = false 
    @mode = nil                      #not use yet
    @target_area = []
    @target_positions = []
    @targets = []
    @range = []
    @last_x, @last_y, @x, @y = 0,0,0,0
  end
  
  #------------------------------------------------------
  #* If active, check keyboard input
  #------------------------------------------------------
  def update
    return false unless @active
    nu_x, nu_y = @x, @y
    if Input.repeat?(Input::RIGHT)
        nu_x += 1 
    elsif Input.repeat?(Input::LEFT)
        nu_x -= 1 
    elsif Input.repeat?(Input::DOWN)
        nu_y += 1 
    elsif Input.repeat?(Input::UP)
        nu_y -= 1 
      end
    #check if moved and not moved outside the map
    if (nu_x != @x or nu_y != @y) and $game_map.valid?(nu_x, nu_y)
      moveto( nu_x, nu_y)
      Sound.play_cursor
      return true
    end
    return false
  end
  
  #----------------------------------------------------------
  #* set the mode of selction: move/Attack/Skill/Item/No_Select
  #----------------------------------------------------------
  def mode=(select_mode)
    #ensure active
    if select_mode
      @active = true 
    else
      @target_area.clear
    end
    @mode = select_mode
  end
  
  #------------------------------------------------------
  #* move cursor to position
  #------------------------------------------------------
  def moveto(pos, y=nil)
    @last_x, @last_y = @x, @y
    case pos
    when POS, Game_Battler
      super(pos.x, pos.y) 
    when Array
      super(*pos)
    when nil
      return
    else
      super(pos, y) 
    end
    if @last_x != @x or @last_y != @y
      @target_need_refresh = true
    end
  end
  #---------------------------------------------------------
  #* Move cursor to the next positions in range
  #--------------------------------------------------------
  def moveto_next
    return if @range.empty?
    if index = @range.index(self.pos)
      @index = index
    end
    @index += 1
    @index %= @range.size
    moveto @range[@index]
  end
  def range=(nu_range)
    @index = -1
    @range = nu_range
  end
  #-------------------------------------------------------------------------
  # In_Range? - Is cursor in 'range'? 
  #-------------------------------------------------------------------------
  def in_range?
    return self.range.include?([@x, @y])
  end
  #------------------------------------------------------
  #* Is cursor at position?
  #------------------------------------------------------
  def at?(pos, y=nil)
    case pos
    when POS, Game_Battler
      return (pos.x == @x and pos.y == @y)
    when Array
      return (pos.at(0) == @x and pos.at(1) == @y)
    else
      return (x == @x and x == @y)
    end
  end
  #------------------------------------------------------
  #* return all battler in range
  #------------------------------------------------------
  def targeted_battlers
    result = []
    for battler in SceneManager.scene.tactics_all
      next if battler.hidden?
      result.push battler if battler.positions & @target_positions != []
    end
    return result
  end
  #------------------------------------------------------
  #* update ranges_sprites when target_positions is modified
  #------------------------------------------------------
  def target_positions=(positions)
    @target_need_refresh = true
    @reselect_targets = true
    set_targets([])
    @target_positions = positions
  end
  def target_need_refresh?
    if @target_need_refresh
      @target_need_refresh = false
      return true
    else
      return false
    end
  end
  def need_target_update?
    return false if @target_area.empty?
    return @target_need_refresh
  end
  
  #---------------------------------------------------------------------------
  #* set_targets
  #-------------------------------------------------------------------------
  attr_reader :targets
  attr_accessor :reselect_targets
  def set_targets(targets)
    if targets != @targets
      for target in targets
        target.targeted = [@target_area[0]]
      end
      @reselect_targets = true
      @targets = targets.clone 
    end
  end
  #--------------------------------------------------------------------------------------------------------------
  #* calc_pos_spell
  #  use to draw area of effect for spell or weapon attack
  #-------------------------------------------------------------------------------------------------------------
  def calculate_aoe( range_max, range_min, x = @x, y = @y, v_range_aoe = 0) # mod MGC
    return [] if range_max == nil    
    return [[x, y]]  if range_max == 0

    #prevents items from being pushed if height change between core and outer is less than range/2
    positions = []
    #save position for later processing 
    
    #prevents items from being pushed if height change between core and outer is less than range/1.5
    for i in 0..range_max
      it = range_max - i  
      #test all couples (it, oy) like: 0 <= it+oy <= range_max
      for oy in 0..i
        next if it+oy < range_min 
        for ux, uy in[ [x - it, y - oy], [x - it, y + oy], [x + it, y + oy], [x + it, y - oy] ]
          positions.push([ux, uy]) if valid_new_aoe_pos(ux, uy, x , y, v_range_aoe) and not positions.include?([ux, uy]) # mod MGC
        end
      end
    end
    return positions
  end
  #------------------------------------------------------------------------------
  #* check if ux, uy is a valid position
  #------------------------------------------------------------------------------
  def valid_new_aoe_pos(tx, ty, sx, sy, v_range_aoe) # mod MGC
    return false unless $game_map.valid?(tx, ty) 
    return true
  end
 
  #--------------------------------------------------------------------
  # Update_Target_Cursor -This redraws the target cursor each time around 
  #  so that it updates correctly on the screen when moved
  #--------------------------------------------------------------------
  def update_target(battler,  force = false) 
    if need_target_update?
      if force or in_range?
        positions = determine_cursor_area(battler)
      else
        positions = []
      end
      self.target_positions = positions
    end
  end
  #-------------------------------------------------------------
  #* determine_cursor_area
  #-------------------------------------------------------------
  def determine_cursor_area(battler)
    #calculate the range hit by the action
    line, exclude_caster, field, v_range_aoe = @target_area[1, 4]
    type = [line, field, self.range, exclude_caster, v_range_aoe]
    return battler.target_zone(battler.pos, self.pos, type)
  end
  #-------------------------------------------------------------
  #* determine distance from the cursor
  #-------------------------------------------------------------
  def distance(pos2)
    return $game_map.distance(self, pos2)
  end
end