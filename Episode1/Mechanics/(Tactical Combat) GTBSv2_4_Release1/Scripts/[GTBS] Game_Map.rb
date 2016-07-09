class Game_Map
  attr_reader :start_locations
  def gtbs_setup(map_id)
    setup(map_id)
    create_battle_events
  end
  #--------------------------------------------------------------------------
  # * Create Events 
  #--------------------------------------------------------------------------
  Battler_Types = ['actor', 'enemy', 'neutral']
  Acceptable_Types = Battler_Types + ['battle_event', 'extra', 'place']
  def create_battle_events
    enemy_loc = {}
    actor_loc = {}
    neu_loc = {}
    place_loc = []
    #battle_events = $game_system.battle_events
    @extras = {}
    for j in @events.keys
      event = @events[j]
      next if event.name == nil
      for i in 0...Acceptable_Types.size
        type = Acceptable_Types[i]
        if event.name.downcase.include?(type)
          id = event.name.downcase.delete(type).to_i
          next if id == 0 if Battler_Types.include?(type)
          case i 
          when 0 #actors
            actor_loc[id] = event
          when 1 #enemies
            enemy_loc[id] = event
          when 2 #neutrals
            neu_loc[id] = event
          when 3 #battle_events
            $game_system.battle_events[j] = event
          when 4 #extras
            @extras[j] = event
          when 5 #place
            place_loc.push([event.x, event.y])
          end
        end
      end
    end
    
    @start_locations = [enemy_loc, actor_loc, neu_loc, place_loc]
  end
  
  #-------------------------------------------------------------
  #*return all the gtbs events to create sprite_event
  #------------------------------------------------------------
  def gtbs_events
    return $game_system.battle_events.values + @extras.values
  end
  #--------------------------------------------------------------------------
  # * Isometric map?
  #--------------------------------------------------------------------------
  def iso?
    return false
  end
  #-------------------------------------------------------------------------
  # Occupied? - Is cursor location occupied by battler (living or dead)
  #-------------------------------------------------------------------------
  def occupied_by?(x, y)
    return nil if !SceneManager.scene_is?(Scene_Battle_TBS)
    battlers = SceneManager.scene.tactics_all
    for battler in battlers  
      if (battler.death_state? && GTBS::REMOVE_DEAD == 2)
        next
      elsif (battler.death_state? && battler.enemy? && GTBS::REMOVE_DEAD > 0)
        next
      else
        if battler.at_xy_coord(x,y)
          return battler
        end
      end
    end
    return nil #not occupied?
  end
  #-------------------------------------------------------------------------
  # Get cost of the move from x, y to nu_x, nu_y for actor
  #-------------------------------------------------------------------------
  def add_cost_move(bat, x,y, dir, nu_x, nu_y, flying = false, adtnlParam = true) # mod MGC
    tt = terrain_tag(x, y)  #get terrain tag value
    if bat.actor?
      type = GTBS.get_act_traverse(bat.id)
    else
      type = GTBS.get_en_traverse(bat.enemy_id)
    end
    if type == 1 && tt == 1
      tt = 0
    elsif type == 2 && tt == 2
      tt = 0
    elsif type == 3 && (tt == 1 || tt == 2)
      tt = 0
    end
    tt = 0 if tt > 4        #is terrain tag less than 4?
    return tt
  end
  #----------------------------------------------------------------
  # Pos Distance - Compares the two objects x,y to determine distance
  #----------------------------------------------------------------
  def distance(p1, p2)
    return ((p1.x-p2.x).abs + (p1.y-p2.y).abs)
  end
  #--------------------------------------------------------------------------
  # * Update Normal Scroll - This is the process to update the map postion to current  
  #--------------------------------------------------------------------------  
  def update_gtbs_scroll(cursor_x, cursor_y)
    return true if scrolling?
    update_normal_scroll(cursor_x, cursor_y)
  end
  #--------------------------------------------------------------------------
  # ? Center X
  #--------------------------------------------------------------------------
  def center_x
    (Graphics.width / 32 - 1) / 2.0
  end
  #--------------------------------------------------------------------------
  # ? Center_Y
  #--------------------------------------------------------------------------
  def center_y
    (Graphics.height / 32 - 1) / 2.0
  end
  #--------------------------------------------------------------------------
  # * Update Non Iso Scroll - This is the process to update the map postion to current 
  #--------------------------------------------------------------------------  
  def update_normal_scroll(cursor_x, cursor_y)
    ax1 = $game_map.adjust_x($tbs_cursor.last_x)
    ay1 = $game_map.adjust_y($tbs_cursor.last_y)
    ax2 = $game_map.adjust_x(cursor_x)
    ay2 = $game_map.adjust_y(cursor_y)
    $game_map.scroll_down (ay2 - ay1) if ay2 > ay1 && ay2 > center_y
    $game_map.scroll_left (ax1 - ax2) if ax2 < ax1 && ax2 < center_x
    $game_map.scroll_right(ax2 - ax1) if ax2 > ax1 && ax2 > center_x
    $game_map.scroll_up   (ay1 - ay2) if ay2 < ay1 && ay2 < center_y
    return false
  end 
  #---------------------------------------------------------------------
  # Map Region Transfer ID
  #---------------------------------------------------------------------
  def map_reg_trans(area_id) 
    #This will return the opoening map_id to transfer to when a battle starts 
    return GTBS::MAP_Region_Transfer[@map_id][area_id] rescue return nil
  end
  
  # Folder is the folder used within pictures to contain the backdrops
  BG_Folder = "Backdrop/"
  
  # returns bmp image file name to be used as background
  def get_backdrop_image(position)
    reg_id = region_id(position[0], position[1])
    back = map_reg_battleback(reg_id)
    back = map_default_back if back.nil?
    back = GTBS::Default_Backdrop if back.nil?
    BG_Folder + back
  end 
  #---------------------------------------------------------------------
  # Map Region BattleBack 
  # * AreaID
  #---------------------------------------------------------------------
  def map_reg_battleback(area_id) 
    #This will returrn the battleback string that is defined on a map's area_id
    return GTBS::Battleback_Region[@map_id][area_id] rescue return nil
  end
  #---------------------------------------------------------------------
  # Map Default Backdrop
  #---------------------------------------------------------------------
  def map_default_back
    return GTBS::BackDrop_MAP_Default[@map_id] #will return nil when invalid
  end
end  