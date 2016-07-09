class Scene_Battle_TBS
  
  #--------------------------------------------------------------------------
  # * Prepare Place - This method prepares for the placement of characters(you choose)
  #--------------------------------------------------------------------------  
  def start_actor_place
    #place actors manual
    #highlight tiles that characters can be placed on
    @spriteset.draw_range(@place_loc, 2)
    @cursor.moveto( @place_loc.first )

    @index = -1
    next_actor_to_place
    
    @windows[Win_Status].visible = true
    @windows[Win_Status].update($game_party.all_members[@index]) 
    @windows[Win_Help].move_to(8)
    @windows[Win_Help].move_to(2)
    @windows[Win_Help].set_text(Vocab_GTBS::Place_Message)
    
    @temp_placed = nil
    @cursor.active = true
    @cursor.range = @place_loc
    
    loop do
      Graphics.update     # Update game screen
      Input.update                # Update input information
      $game_map.update(false)
      @spriteset.update               # Update sprite set
      update_battlers 
      next if update_screen
      if @windows[Win_Confirm].active 
        if win_confirm_update
          break
        end 
      #this will never append?
      elsif scene_changing? 
        break
      else
        place_update
      end 
    end
  end
  
  #--------------------------------------------------------------------------
  # Set_Place_Finished?
  #--------------------------------------------------------------------------
  def set_place_finish?
    @windows[Win_Confirm].ask(Command_Confirm::Place)
  end
  
  #--------------------------------------------------------------------------
  # * Place Update - This method updates the placement phase
  #--------------------------------------------------------------------------  
  def place_update
    @spriteset.update
    $game_map.update(false)
    update_cursor
    update_screen
    @windows[Win_Status].update($game_party.all_members[@index])
    if Input.trigger?(Input::Z)
      @cursor.moveto_next
    elsif @temp_placed
      place_follow
    else
      place_init
    end
  end
    
  #--------------------------------------------------------------------------
  # * Place Init - This method is the "initial" update to be processed during the 
  #    character placement phase
  #--------------------------------------------------------------------------  
  def place_init
    actor = $game_party.all_members[@index] 
    if Input.trigger?(Input::B) 
      if tactics_actors.size == 0#Cannot exit setup if no actors placed
        Sound.play_buzzer
      else
        Sound.play_cancel
        set_place_finish?
      end
      
    elsif Input.trigger?(Input::C) 
      #valid in range?
      if @cursor.in_range?
        if temp_placed = occupied_by?   #if occupied
          @cursor.target_positions = [@cursor.pos]
          @cursor.target_area[0] = 1
          @temp_placed = temp_placed
          Sound.play_decision
        else
          if actor.hidden?
            if actor.death_state?
              Sound.play_buzzer
              return
            else
              Sound.play_decision
              actor.gtbs_entrance(@cursor.x, @cursor.y)
              create_character(@spriteset.viewport1, actor)
              next_actor_to_place
              @cursor.moveto_next
              if tactics_actors.size == $game_party.placable?
                set_place_finish?
              end
            end
          #not allowed to place an actor that was forced by a map place
          elsif !@place_loc.include?(actor.pos)
            Sound.play_buzzer
            return
          else #if actor already placed, move to location
            Sound.play_decision 
            actor.moveto(@cursor.x, @cursor.y)
            actor.update 
          end

        end
      else #valid not in range
        Sound.play_buzzer
      end
      
    #next actor 
    elsif Input.trigger?(Input::L) 
      Sound.play_cursor
      next_actor_to_place
    #previous actor
    elsif Input.trigger?(Input::R) 
      Sound.play_cursor
      previous_actor_to_place
    end
  end

  #--------------------------------------------------------------------------
  # * Place Follow - This updates the "follow up" of the place scene.  For
  #    character replacement/swaping prior to battle
  #--------------------------------------------------------------------------  
  def place_follow
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @temp_placed = nil 
      clear_r_sprites
    elsif Input.trigger?(Input::A)
      if @cursor.at?( @temp_placed )
        @temp_placed.hide
        @temp_placed.tbs_battler = false
        @temp_placed.clear_tbs_pos
        dispose_character(@temp_placed)
        clear_r_sprites
        @temp_placed = nil;
      end
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      #if cursor location still over initially selected actor, delete and replace
      if @cursor.at?( @temp_placed )
        @temp_placed.hide
        @temp_placed.tbs_battler = false
        @temp_placed.clear_tbs_pos
        dispose_character(@temp_placed)
        @temp_placed = nil
        
        
        actor = $game_party.all_members[@index]
        actor.gtbs_entrance(@cursor.x, @cursor.y)
        create_character(@spriteset.viewport1, actor)
        
        #@spriteset.actor_sprites.push(Sprite_Battler_GTBS.new(@spriteset.viewport1, actor))
        #actor.moveto()
        #actor.update
        #if actor.hidden?
        #  actor.adjust_special_states
        #  actor.appear
        
        #end
        clear_r_sprites
        next_actor_to_place
      
      #if cursor is now somewhere else
      elsif @cursor.in_range?
        swap = occupied_by?(@cursor.x, @cursor.y)
        if swap #occupied by someone else, swap!
          Sound.play_decision
          
          temp_x, temp_y = @temp_placed.pos
          @temp_placed.moveto(swap.x, swap.y)
          @temp_placed.update
          swap.moveto(temp_x, temp_y)
          swap.update
          @temp_placed = nil 
          clear_r_sprites
        else #move temp to new location
          Sound.play_decision
          @temp_placed.moveto(@cursor.x, @cursor.y)
          @temp_placed.update
          @temp_placed = nil 
          clear_r_sprites
        end
      else
        Sound.play_buzzer
      end
    end
  end
  #------------------------------------------------------------------
  #* next actor, ignoring unplacable actor
  #------------------------------------------------------------------
  def next_actor_to_place
    party_members = $game_party.all_members
    for i in 0...party_members.size
      #select next actor
      @index += 1 
      @index %= party_members.size
      actor = party_members[@index]
      next unless actor.hidden? and !@place_loc.include?(actor.pos)
      return
    end
  end
            #------------------------------------------------------------------
  #* next actor, ignoring unplacable actor
  #------------------------------------------------------------------
  def previous_actor_to_place
    party_members = $game_party.all_members
    for i in 0...party_members.size
      #select next actor
      @index -= 1 
      @index %= party_members.size
      actor = party_members[@index]
      next if !actor.hidden? and !@place_loc.include?(actor.pos)
      return
    end
  end
end