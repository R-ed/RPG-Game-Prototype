class Scene_Battle_TBS
  #----------------------------------------------------------------------
  # update Battle Option window
  #---------------------------------------------------------------------
  def upd_battle_option
    @windows[Win_Option].update
    if Input.trigger?(Input::C) 
      case @windows[Win_Option].option
      when  Battle_Option::Act_List
        @windows[Act_List] = Window_ActList.new(@active_battler, populate_list)
        @windows[Win_Option].active = false
        @windows[Win_Option].visible = false
        Sound.play_decision 

      when Battle_Option::End_Turn
        Sound.play_decision
        @windows[Win_Option].active = false
        @windows[Win_Option].visible = false
        @phase_count += 1
        $game_system.acted.clear
        #@active_battler.blink = false unless @active_battler == nil
        @active_battler = nil
        for battler in tactics_allies
          battler.clear_tbs_actions
        end
        set_turn(Turn_Enemy)
        @cursor.active = false
        next_enemy
        
      when Battle_Option::Config
        Sound.play_decision
        @windows[Win_Option].active = false
        @windows[Win_Option].visible = false
        @windows[Win_Config].active = true
        @windows[Win_Config].visible = true
        @windows[Win_Config].index = 0
        
      when Battle_Option::Conditions
        Sound.play_decision
        @windows[Win_Option].active = false
        @windows[Win_Option].visible = false
        @windows[Win_Option].update
        battle_start(true)
        @cursor.active = true
        
      when Battle_Option::Cancel
        Sound.play_decision
        @windows[Win_Option].active = false
        @windows[Win_Option].visible = false
        @cursor.active = true
      end  

    elsif Input.trigger?(Input::B)
      Sound.play_cancel
      @windows[Win_Option].active = false
      @windows[Win_Option].visible = false
      @cursor.active = true
    end    
  end
    
  #----------------------------------------------------------------------
  # update Act_List window
  #---------------------------------------------------------------------
  def upd_act_list
    @windows[Act_List].update
    if Input.trigger?(Input::C)  
      Sound.play_decision
      selected = @windows[Act_List].data
      @cursor.moveto(selected) 
      @windows[Act_List].dispose
      @windows.delete(Act_List)
      @cursor.active = true
      return
    elsif Input.trigger?(Input::B) 
      Sound.play_cancel
      @windows[Act_List].dispose
      @windows.delete(Act_List)
      @windows[Win_Option].active = true
      @windows[Win_Option].visible = true
      return
    end
  end
  
  #----------------------------------------------------------------------------
  # Update Config
  #----------------------------------------------------------------------------
  def upd_win_config
    if @windows[Win_Config].win_color.active
      @windows[Win_Config].win_color.update
      if Input.trigger?(Input::B)
        Sound.play_cancel
        close_color_window
        return
      elsif Input.trigger?(Input::C)
        Sound.play_decision
        close_color_window(true)
        return
      end
    else
      @windows[Win_Config].update
      if Input.trigger?(Input::B)  
        Sound.play_cancel
        close_config
      elsif Input.trigger?(Input::C)  
        ##custom battle system enable/disable
        case @windows[Win_Config].index
        when 0
          $game_system.reset_default_gtbs_config
        when 1
          Sound.play_buzzer #Need to just remove this option. 
        when 2
          Sound.play_decision
          if $game_system.scroll_cursor == true
            $game_system.scroll_cursor = false
          else
            $game_system.scroll_cursor = true
          end
        when 3..6
          Sound.play_decision
          activate_win_color #350
        when 7
          close_config
        end
        #@windows[Win_Config].create_contents
        @windows[Win_Config].refresh 
      end
    end
  end
  #--------------------------------------------------------------------------
  # Close Config - Closes the config dialog and returns to 'options'
  #--------------------------------------------------------------------------
  def close_config
    @windows[Win_Config].deactivate
    @windows[Win_Config].hide
    @windows[Win_Option].activate
    @windows[Win_Option].show
  end
  #--------------------------------------------------------------------------
  # Activate Win Color - Brings "COLOR" window to front and centers on config option
  #--------------------------------------------------------------------------
  def activate_win_color
    @windows[Win_Config].win_color.activate
    @windows[Win_Config].win_color.show
    @windows[Win_Config].win_color.index = 0
    @windows[Win_Config].win_color.y = @windows[Win_Config].cursor_rect.y
  end  
  #--------------------------------------------------------------------------
  # Close Color Window ( Apply ) - Closes the active color window.  Applies selected
  #   color to system object if told to do so. 
  #--------------------------------------------------------------------------
  def close_color_window(apply=false)
    @windows[Win_Config].win_color.deactivate
    @windows[Win_Config].win_color.hide
    @windows[Win_Config].activate
    @windows[Win_Config].show
    @windows[Win_Config].refresh 
    @windows[Win_Config].select_color if apply
  end
  #--------------------------------------------------------------------------
  #* populate_list
  #-------------------------------------------------------------------------
  def populate_list
    next_battler_list = []
    list_battlers = tactics_all
    hash_battlers = {}
    list_battlers.each{ |bat| hash_battlers[bat.clone] = bat }
    fake_tatics_battlers = hash_battlers.keys
    while next_battler_list.size < 20
      next_battler = fake_process_atb(fake_tatics_battlers)
      if next_battler
        if next_battler.is_a?(Array)#skill_wait
          for bat, skill in next_battler
            next_battler_list.push([hash_battlers[bat], skill])
          end
        else
          next_battler_list.push( hash_battlers[next_battler])
        end
      end
    end
    return next_battler_list
  end
end