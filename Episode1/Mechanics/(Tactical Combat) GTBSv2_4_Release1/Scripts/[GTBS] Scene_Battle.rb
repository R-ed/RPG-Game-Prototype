class Scene_Battle < Scene_Base
  def set_character(*args)
  end
end

class Scene_Battle_TBS < Scene_Base
  attr_accessor  :spriteset 
  attr_reader    :hit_count 
  attr_reader    :active_battler
  attr_reader    :mini_showing
  #============================================================================
  # CONSTANTS
  #============================================================================
  HEAL_SCOPES   = [7,9,11] 
  ALL_TYPES     = [2,8,10] 
  MULTI_SCOPES  = [4,5,6] #dual, triple, and quad.
  #----------------------------------------------------------------------------
  #Window names: should be replaced by Integer for CPU efficiency  
    Win_Help = :help#'help'
    Menu_Actor = :actor #'actor'
    Win_Confirm = :confirm#'confirm'
    Win_Status, Win_Detail = :status, :detail#'status', 'detail'
    Win_Item, Win_Skill, Win_Revive = :item, :skill, :revive#'item', 'skill', 'revive'
    Win_Option, Win_Config, Win_Color = :option, :config, :color#'option', 'config', 'color'
    Win_LevelUp = :earned#'earned'
    Act_List = :act_list#'Act List'
  # TURN
    Turn_Player , Turn_Enemy = 'player', 'enemy'
  #type of battlers
    Battler_Actor, Battler_Enemy, Battler_Neutral = 'actor', 'enemy', 'neutral'
  #============================================================================

  
  def start
    super
    prepare_GTBS
  end
  #-----------------------------------------------------------------------------
  # Prepare GTBS - Initializes all required to draw scene data
  #-----------------------------------------------------------------------------
  def prepare_GTBS
    @ATB_Active = ($game_system.cust_battle == "ATB")#(GTBS::MODE == 0)
    $game_system.clear_battlers #clears battler hashs stored in game_system
    setup_map
    change_music
    setup_temp_info
    create_events
    create_battlers
    create_spriteset
    setup_mini_scene_variables
    start_center
    setup_victory_fail_events
  end
  #-----------------------------------------------------------------------------
  # Post Start
  #-----------------------------------------------------------------------------
  def post_start
    super # Calls perform transition the correct way since they changed it again
    create_windows
    if (waiting_on_place?)
      start_actor_place
    else
      @placement_done = true
    end
    return if scene_changing?
    face_enemies
    tbs_turn_count = 1
    open_scene?
    finish_prep
    battle_start
  end
  
  #--------------------------------------------------------------------------
  # * Execute Pre-battle Transition
  #--------------------------------------------------------------------------
  def perform_transition
    Graphics.transition(80, "Graphics/System/#{GTBS::TRANSITION_IMAGE}", 80)
  end
  
  def pre_terminate
    
  end
  
  def terminate
    for bat in tactics_allies
      bat.recover_after_battle?
    end
    $game_party.clear_tbs_positions
    dispose_spriteset
    $game_system.clear_battlers
    @windows.keys.each {|win| @windows[win].dispose}
  end  
  def dispose_spriteset
    @spriteset.dispose
    #@cursor.dispose
  end
  def setup_map
    if GTBS::BTEST_TBS && $BTEST
      if GTBS::BTEST_ID != 0
        @map_id = GTBS::BTEST_ID
      else
        raise "No battle test map was specified to be used"
        SceneManager.clear
        SceneManager.goto(SceneManager.first_scene_class)
        return
      end
    else
      @map_id = $game_map.map_id
    end
    battle_map_id = determine_battle_map(@map_id)
    $game_map.gtbs_setup(battle_map_id)
    #create death events
    @dead_actors = [] 
    @death_actor = GTBS::check_death_action(@map_id, 0)
    @death_enemy = GTBS::check_death_action(@map_id, 1)
  end
  
  #--------------------------------------------------------------------------
  # Determine Battle Map
  #--------------------------------------------------------------------------
  def determine_battle_map(map_id)
    return map_id if $BTEST
    region_id = $game_player.region_id
    tmap = $game_map.map_reg_trans(region_id)
    tmap == nil ? map_id = GTBS.battle_map(map_id) : map_id = tmap #In case area is undefined...
    if $game_temp.map_id != nil && $game_temp.map_id > 0 
      map_id = $game_temp.map_id
    end
    $game_temp.map_id = 0 #reset map_id
    return map_id
  end
  
  #--------------------------------------------------------------------------
  # * Change Music
  #--------------------------------------------------------------------------
  if GTBS::PHASE_MUSIC
    def change_music(turn = Turn_Player) 
      if turn == Turn_Player
        bgm_name = GTBS.actor_phase_music
      else
        bgm_name = GTBS.enemy_phase_music
      end
      bgm = RPG::BGM.new
      bgm.name = bgm_name
      bgm.play
    end
  else#no change music
    def change_music(*args)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Setup Temp Info 
  #--------------------------------------------------------------------------
  def setup_temp_info
    BattleManager.method_wait_for_message = nil
    BattleManager.battle_start
    BattleManager.method_wait_for_message = method(:wait_for_message)
    
    #Get team data
    BattleManager.reset_team_data
    if $game_temp.foe_data != nil
      for key, data in $game_temp.foe_data
        BattleManager.foe_data[key] = data
      end
      $game_temp.foe_data = nil
    end
    
    
    #create cursor
    @cursor = TBS_Cursor.new
    $tbs_cursor = @cursor
    
    #create temp variables
    @wait_count = 0 
    @show_dmg_pop_ind = []
    @use_spell = []
    @exp_gained = [] 
    @counters = []
    @melee = true
    @targets = []
    
    #create phase temp variables
    @temp_acted = 0
    @phase_count = 0
    
    #create event queue
    @common_event_q = []
    @common_events = $data_common_events 
    
    @queued_batters_for_collapse = []
    #Set Character Later
    @set_character_later = []
    @battle_exiting = nil

    @escape_cooldown = 0
  end 
  #--------------------------------------------------------------------------
  # * Create Events 
  #--------------------------------------------------------------------------
  def create_events
    @enemy_loc, @actor_loc, @neu_loc, @place_loc = $game_map.start_locations 
  end
  #--------------------------------------------------------------------------
  # * Create Battlers - This creates the battler arrays, and places them
  #--------------------------------------------------------------------------
  def create_battlers
    team_regex = /team\s*=\s*(.+)/
    #add actors to their starting events
    if GTBS::ACTOR_PLACE_USES_INDEX
      for battler in $game_party.all_members
        index = battler.index + 1
        battler.hide
        act_pos = @actor_loc[index]
        if act_pos
          battler.gtbs_entrance(act_pos.x, act_pos.y)
          act_pos.notes.downcase.scan(team_regex)
          if $1
            battler.set_team($1.to_s)
          end
        end
      end
    else # Not using index
      for key, pos in @actor_loc
        if actor = $game_actors[key]
          actor.gtbs_entrance(pos.x, pos.y)
          actor.animation_id = 0
          pos.notes.downcase.scan(team_regex)
          if $1
            actor.set_team($1.to_s)
          end
        end
      end
    end
    #add enemies to their starting events
    for battler in $game_troop.members
      battler.hide
      en_pos = @enemy_loc[battler.index + 1]
      if en_pos
        battler.gtbs_entrance(en_pos.x, en_pos.y)
        battler.letter = ""
        en_pos.notes.downcase.scan(team_regex)
        if $1
          battler.set_team($1.to_s)
        end
      end
    end
    #add neutral actors to their starting events
    for key, pos in @neu_loc
      if actor = $game_actors[key]
        actor.gtbs_entrance(pos.x, pos.y, true)#neutral = true
        actor.animation_id = 0
        pos.notes.downcase.scan(team_regex)
        if $1
          actor.set_team($1.to_s)
        end
      end
    end
    #Abort battle to title if map has no actors placed on it.
    if tactics_actors.size == 0 and @place_loc.size == 0
      raise Vocab_GTBS::No_Actors_Placed
      SceneManager.clear
      SceneManager.goto(SceneManager.first_scene_class)
    #Abort battle to title if map has no enemies placed on it.
    elsif tactics_enemies.size == 0
      raise Vocab_GTBS::No_Enemy_Placed
      SceneManager.clear
      SceneManager.goto(SceneManager.first_scene_class)
    end
  end
  #--------------------------------------------------------------------------
  # Create Spriteset
  #--------------------------------------------------------------------------
  def create_spriteset
    @spriteset = Spriteset_Map.new
  end
  #--------------------------------------------------------------------------
  # Create Character
  #--------------------------------------------------------------------------
  def create_character(viewport, obj)
    sprite = nil
    if obj.is_a?(Game_Actor)
      @spriteset.actor_sprites[obj] = (sprite = Sprite_Battler_GTBS.new(viewport, obj))
    elsif obj.is_a?(Game_Enemy)
      @spriteset.enemy_sprites[obj] = (sprite = Sprite_Battler_GTBS.new(viewport, obj))
    else #event
      @spriteset.event_sprites[obj] = (sprite = Sprite_Character_GTBS.new(viewport, obj))
    end
    return sprite
  end
  #--------------------------------------------------------------------------
  # Dispose Character sprite
  #--------------------------------------------------------------------------
  def dispose_character(char)
    #First attempt
    sprite = @spriteset.get_battler_sprite(char)
    if sprite != nil
      sprite.dispose
    end
    #Second Attempt - Does this because mini battle might exist
    sprite = @spriteset.get_battler_sprite(char)
    if sprite != nil
      sprite.dispose
    end
    @spriteset.actor_sprites.delete(char)
    @spriteset.event_sprites.delete(char)
    @spriteset.enemy_sprites.delete(char)
  end
  #--------------------------------------------------------------------------
  # Queue Collapse - Sets the character ready for removal from the battle scene
  #--------------------------------------------------------------------------
  def queue_collapse(char)
    unless @queued_batters_for_collapse.include?(char)
      @queued_batters_for_collapse << char 
      #sprite = @spriteset.get_battler_sprite(char)
      #sprite.start_effect(:collapse) if sprite != nil
    end
  end
  #--------------------------------------------------------------------------
  # * Centering screen at start battle
  #--------------------------------------------------------------------------
  def start_center
    if @place_loc.size > 0
      x, y = @place_loc.first
      @spriteset.cursor.center(x, y) 
    elsif @actor_loc.keys.size > 0
      coord = @actor_loc.values.first
      @spriteset.cursor.center(coord.x, coord.y) 
    elsif @neu_loc.keys.size > 0
      coord = @neu_loc.values.first
      @spriteset.cursor.center(coord.x, coord.y)
    end
    @spriteset.update
  end  
  #--------------------------------------------------------------------------
  # * Setup Victory/Failure Events
  #--------------------------------------------------------------------------
  def setup_victory_fail_events
    if $game_temp.victory_condition != nil
      @vic_condition = $game_temp.victory_condition
      @vic_val = $game_temp.victory_val
      @vic_com = $game_temp.victory_common_event
    end
    if $game_temp.failure_condition != nil
      @fail_condition = $game_temp.failure_condition
      @fail_val = $game_temp.failure_val
      @fail_com = $game_temp.failure_common_event
    end
    $game_temp.victory_condition = nil
    $game_temp.victory_val = nil
    $game_temp.victory_common_event = nil
    $game_temp.failure_condition = nil
    $game_temp.failure_val = nil
    $game_temp.failure_common_event = nil
  end
  
  #----------------------------------------------------------------------------
  # Defines windows
  #----------------------------------------------------------------------------
  def create_windows
    @windows = {}
    ##Help - Creates the help window
    @windows[Win_Help] = TBS_Window_Help.new
    @windows[Win_Help].move_to(2)
    ##Create Command Window
    create_command_window
    ##Create Status Windows - Both Full and Mini
    create_status_windows
    ##Create Confirmation Window
    create_confirm_window
    ##Create Item/Skill windows
    create_itemskill_windows
    ##Create Revive Window
    create_revive_window
    ##Create Options Windows
    create_options_windows
    ##Create Log Window
    create_log_window
    ##make all items partially transparent
    for type, window in @windows
      window.back_opacity = GTBS::CONTROL_OPACITY
      window.visible = false
      window.active = false
    end
    ##Assign help dialogs
    for type in [Win_Skill, Win_Item, Menu_Actor] 
      @windows[type].help_window = @windows[Win_Help]
    end
    #message_window
    @message_window = TBS_Window_Message.new
    @message_window.back_opacity = GTBS::CONTROL_OPACITY
    @message_window.z = 1000
    @message_window.visible = false
  end
  def create_command_window
    ##This window will cover all move and battle options, and disable items 
    ##accordingly.
    @windows[Menu_Actor] = Commands_All.new 
    @windows[Menu_Actor].set_handler(:move, method(:actor_menu_move))
    @windows[Menu_Actor].set_handler(:attack, method(:actor_menu_attack))
    @windows[Menu_Actor].set_handler(:status, method(:actor_menu_status))
    @windows[Menu_Actor].set_handler(:wait, method(:actor_menu_wait))
    @windows[Menu_Actor].set_handler(:defend, method(:actor_menu_wait))
    @windows[Menu_Actor].set_handler(:skill, method(:actor_menu_skill))
    @windows[Menu_Actor].set_handler(:item, method(:actor_menu_item))
    @windows[Menu_Actor].set_handler(:escape, method(:actor_menu_escape))
    @windows[Menu_Actor].set_handler(:cancel, method(:actor_menu_cancel))
    @windows[Menu_Actor].set_handler(:equip, method(:actor_menu_equip))
  end
  def create_status_windows
    ##Detailed status
    @windows[Win_Detail] = Window_Full_Status.new(nil)
    ##Get current event(actor/enemy) status
    @windows[Win_Status] = Windows_Status_GTBS.new
    @windows[Win_Status].win_help = @windows[Win_Help];
  end
  def create_confirm_window
    ##Confirm - action, move, wait?
    @windows[Win_Confirm] = Command_Confirm.new 
    # since this is only OK/Cancel the existing notifiers will work without 
    # assigning our own
  end
  def create_itemskill_windows
    ##Item - Displays items for usage
    @windows[Win_Item] = TBS_Item.new(@windows[Win_Help], @spriteset.viewport2)
    ##Skill - Displays skills for usage
    @windows[Win_Skill] = TBS_Skill.new(@windows[Win_Help], @spriteset.viewport2)
    @windows[Win_Skill].height = Graphics.height/2
  end
  def create_revive_window
    #Revive Window - Displays dead characters that can be revived.
    @windows[Win_Revive] = TBS_Window_Revive.new()
  end
  def create_options_windows
    #Options - Displays available 'options' for battle system type
    @windows[Win_Option] = Battle_Option.new
    #Config - Displays Config Menu
    @windows[Win_Config] = Window_Config.new 
    @windows[Win_Config].win_color.hide
    @windows[Win_Config].win_color.deactivate
  end
  #--------------------------------------------------------------------------
  # * Create Log Window
  #--------------------------------------------------------------------------
  def create_log_window
    @log_window = Window_BattleLog.new
    # Commented these out as it was causing 'lag' when the window was shown
    #@log_window.method_wait = method(:wait)
    #@log_window.method_wait_for_effect = method(:wait_for_effect)
  end
  #--------------------------------------------------------------------------
  # * Wait Until Effect Execution Ends
  #--------------------------------------------------------------------------
  def wait_for_effect
    update_for_wait
    update_for_wait while @spriteset.effect?
  end
  def waiting_on_place?
    if GTBS::Always_Allow_Place and @place_loc.size > 0
      return true
    end
    if tactics_actors.size == 0 and @place_loc.size > 0
      return true
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Create Escape Ratio
  #--------------------------------------------------------------------------
  def make_escape_ratio
    actors_agi = $game_party.average_agi
    enemies_agi = $game_troop.average_agi
    @escape_ratio = 150 - 100 * enemies_agi / actors_agi
  end  
  def tbs_turn_count=(val)
    step = val - $game_troop.turn_count
    while val > $game_troop.turn_count
      $game_troop.increase_turn
    end
  end
  #--------------------------------------------------------------------------
  # * Opening Scene? - This process checks to see if a "open scene" event was 
  #    defined before battle started 
  #--------------------------------------------------------------------------  
  def open_scene?
    id = $game_temp.open_scene_event_id
    if id != nil
      interpreter = Game_Interpreter.new
      $game_temp.open_scene_event_id = nil
      event = $game_map.events[id]
      interpreter.setup(event.list, event.id)
      while interpreter.running?
        interpreter.update
        update_basic
        wait_for_message
        @message_window.update
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Face Enemies - This makes actors/enemies face each other
  #--------------------------------------------------------------------------  
  def face_enemies
    if GTBS::FACE_ENEMY
      actors, enemies = friends_of(Battler_Actor), friends_of(Battler_Enemy)
      for actor in actors
        actor.turn_to(enemies[0])
      end
      for enemy in enemies
        enemy.turn_to(actors[0])
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Finish Prepare - This process completes the loading process for the battle
  #--------------------------------------------------------------------------  
  def finish_prep
    @windows[Win_Help].hide
    if @ATB_Active
      setup_start_atb
    else
      choose_team_start
    end
  end
  #--------------------------------------------------------------------------  
  # Choose Team Start - Selects the Team that gets to take the first turn
  #--------------------------------------------------------------------------   
  def choose_team_start 
    if BattleManager.preemptive
      team = Turn_Player
    elsif BattleManager.surprise
      team = Turn_Enemy
    else
      team = (rand(2) == 0) ? Turn_Enemy : Turn_Player
    end
    if ($game_temp.turn_start != nil)
      team = $game_temp.turn_start;
      $game_temp.turn_start = nil;
    end
    set_turn(team) 
  end
  #----------------------------------------------------------------------------
  #Change the team turn and show phase
  #----------------------------------------------------------------------------
  def set_turn(team)
    @turn = team
    @spriteset.update
    change_music(@turn) 
    phase_picture = TBS_Phase_Sprite.new(@turn)
    while not phase_picture.disposed?
      Graphics.update
      $game_map.update(false)
      phase_picture.update
      @spriteset.update
    end
  end
  #--------------------------------------------------------------------------  
  # Setup Starting ATB
  #--------------------------------------------------------------------------  
  def setup_start_atb
    if BattleManager.preemptive
      for battler in $game_party.existing_members
        battler.setup_atb(100)
      end
      for battler in $game_troop.existing_members
        battler.setup_atb(0)
      end
    elsif BattleManager.surprise
      for battler in $game_party.existing_members
        battler.setup_atb(0)
      end
      for battler in $game_troop.existing_members
        battler.setup_atb(100)
      end
    else
      for battler in $game_party.existing_members + $game_troop.existing_members
        battler.setup_atb(rand(100))
      end
    end
  end
  #--------------------------------------------------------------------------  
  # Battle Start
  #--------------------------------------------------------------------------  
  def battle_start( in_battle = false )
    if BattleManager.preemptive
      add_text = "preemptive"
    elsif BattleManager.surprise
      add_text = "surprised !"
    else
      add_text = ""
    end
    vic_sprite = TBS_Battle_Start_Sprite.new(@vic_condition, @fail_condition, @vic_val, @fail_val,in_battle, add_text)
    show_tbs_info_sprite(vic_sprite)
  end
  #----------------------------------------------------------------------------
  # Wait loop for Info_Sprites
  #----------------------------------------------------------------------------
  def show_tbs_info_sprite(sprite)
    while not sprite.disposed? 
      update_basic
      sprite.update
    end
  end
  def tactics_actors
    #$game_party.all_members.select{|mem| mem.exist?}# + $game_party.summoned
    $game_party.existing_members
  end
  def tactics_enemies
    $game_troop.existing_members #.select{|mem| mem.exist?}# + $game_troop.summoned
  end
  def tactics_neutral
    $game_party.neutrals
  end
  def tactics_allies
    tactics_actors + tactics_neutral
  end
  def tactics_all
    tactics_allies + tactics_enemies + tactics_dead
  end
  def tactics_alive
    (tactics_allies + tactics_enemies).select {|mem| !mem.death_state?}
  end
  def tactics_dead
    all_dead = []
    all_dead += $game_troop.tbs_dead_members
    all_dead += $game_party.tbs_dead_members 
    all_dead += tactics_neutral.select{|mem| mem.death_state?}
    return all_dead
  end
  #----------------------------------------------------------------------------
  # Clear Tile and Range sprites
  #----------------------------------------------------------------------------
  def clear_tr_sprites
    @spriteset.dispose_tile_sprites
    clear_r_sprites
  end
  def clear_r_sprites
    @cursor.target_positions = []
  end
  #----------------------------------------------------------------------------
  # Occupied by
  #----------------------------------------------------------------------------
  def occupied_by?(x=@cursor.x, y=@cursor.y)
    return $game_map.occupied_by?(x, y)
  end
  #--------------------------------------------------------------------------
  # * Basic Update Processing
  #     main : Call from main update method
  #--------------------------------------------------------------------------
  def update_basic(main = false)
    super()
    $game_troop.update              # Update enemy group
    $game_map.update(false)         # Update map data
    @spriteset.update               # Update sprite set
    update_win_visible
    update_battlers
    if @message_window.visible != $game_message.visible
      @message_window.visible = $game_message.visible
      @message_window.update          # Update message window
    end
  end
  #----------------------------------------------------------------------------
  # Update Window Visible
  #----------------------------------------------------------------------------
  def update_win_visible
    update_selected
    if @tbs_process_phase
      @windows[Win_Status].visible = false
    else
      @windows[Win_Status].update(@selected)
      @windows[Win_Status].visible = true if @show_dmg_pop_ind.size != 0
    end
  end
  #----------------------------------------------------------------------------
  # Update Battlers - Updates for movement and animations
  #----------------------------------------------------------------------------
  def update_battlers
    for battler in tactics_all# + tactics_dead
      battler.update
    end
    update_queued_battlers
  end
  #----------------------------------------------------------------------------
  # Update Queued Battlers
  #----------------------------------------------------------------------------
  def update_queued_battlers
    for battler in @queued_batters_for_collapse
      sprite = @spriteset.get_battler_sprite(battler)
      if sprite != nil and !(sprite.effect? or sprite.animation?)
        dispose_character(battler)
        @queued_batters_for_collapse.delete(battler)
        
        battler.hide #this line MUST be here in order for character removal from
        #the map.  However, if hidden, like this, then they cannot be revived via
        #the current 'locate active battlers' criteria.
        #In order to accomodate this, I have added a new 'dead flag' so that we
        #can still revive them.  
        
        #this should prevent them from being noted as visible and detected for 
        #placement reasons
        #BLARG
      end
    end
  end
  #----------------------------------------------------------------------------
  # Update Process
  #----------------------------------------------------------------------------
  def update
    return if scene_changing?
    update_basic(true)
    $game_troop.setup_battle_event
    update_battle_event
    wait_for_message
    return  if update_processes
    # Checks cursor position and prepares info for status window display 
    unless @battle_exiting
      return if check_abort
      update_phase
      # Updates Windows
      unless $game_troop.interpreter.running?
        ### AI process###
        if @active_battler and @active_battler.ai_controlled?
          update_ai_unit
        ###Player phase###
        elsif @wait_pic
          actor_wait_phase #Choose wait direction
        elsif @windows[Win_Detail].active 
          update_window_detail
        elsif @windows[Win_Item].active 
          update_window_item
        elsif @windows[Win_Skill].active  
          update_window_skill
        elsif @windows[Menu_Actor].active
          update_actor_menu
        #### Win_option update###
        elsif @windows[Act_List] #not nil
          upd_act_list
        elsif @windows[Win_Config].active
          upd_win_config
        elsif @windows[Win_Option].active
          upd_battle_option
        elsif @windows[Win_Confirm].active
          win_confirm_update
        elsif @windows[Win_Revive].active
          update_win_revive
        ###Curseur selection###
        elsif @cursor.active
          cursor_active_selection
        elsif @active_battler 
          #Added for Issue #417 - when confuse is cleared battle doesnt proceed
          deactivate_battler
        end
      end
      judge_win_loss
    else
      process_atb
      result_phase
    end
    update_transfer 
  end
  #----------------------------------------------------------------------------
  # Start Actor Place - Method moved to [GTBS] Place Actors for cleanliness
  #----------------------------------------------------------------------------
  #def start_actor_place
  #end
  
  #----------------------------------------------------------------------------
  # Updates Screen position using scroll methods from Game_Map
  #----------------------------------------------------------------------------
  def update_screen
    return true if @spriteset.animation? 
    #Normal scrolling method or iso scrolling
    return true if $game_map.update_gtbs_scroll(@cursor.x, @cursor.y) and !@cursor.active
  end
  def update_cursor
    @cursor.update
  end
  #----------------------------------------------------------------------------
  # Cursor phase selection
  #----------------------------------------------------------------------------
  def cursor_active_selection
    update_cursor
    update_target_cursor
    return if
    case @cursor.mode 
    when TBS_Cursor::Item
      update_cursor_item
    when TBS_Cursor::Skill
      update_cursor_skill
    when TBS_Cursor::Attack
      cursor_use_attack
    when TBS_Cursor::Move
      cursor_use_move
    else# No_Select
      cursor_no_select
    end
  end
  #--------------------------------------------------------------------
  # Update_Target_Cursor -This redraws the target cursor each time around 
  #  so that it updates correctly on the screen when moved
  #--------------------------------------------------------------------
  def update_target_cursor
    @cursor.update_target(@active_battler, @using_skill)
  end
  #----------------------------------------------------------------
  # Checks for Battle Defined Events for specified troop, also updates map related 
  # battle events that are defined.
  #----------------------------------------------------------------
  def update_battle_event 
    $game_troop.interpreter.update
    #$game_map.interpreter.update
    #check system battle events
    if $game_troop.interpreter.running?
      # Update interpreter
      $game_troop.interpreter.update
      unless $game_troop.interpreter.update
      # Rerun battle event set up if battle continues
        $game_troop.setup_battle_event
      end
    else
      #check map battle events
      if !$game_troop.interpreter.running?#$game_map.interpreter.running?
        for event in $game_system.battle_events.values
          event.update 
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Wait Until Message Display has Finished
  #--------------------------------------------------------------------------
  def wait_for_message
    @message_window.update
    while $game_message.visible 
      update_basic
    end
  end
  #----------------------------------------------------------------------------
  # Update Processes - Used to reset update process if...
  #----------------------------------------------------------------------------
  def update_processes
    return true if set_later?
    return true if using_skill?
    return true if gaining_exp?
    return true if update_screen
  end
  #----------------------------------------------------------------
  # Set Later
  #----------------------------------------------------------------
  def set_later?
    if @set_character_later.size > 0 && !@mini_showing
      data = @set_character_later.shift
      set_character(*data)
    end
  end
  #----------------------------------------------------------------
  # Use Skill - Processes skills are awaiting processing (wait skills)
  #----------------------------------------------------------------
  def using_skill?
    return false if @use_spell.empty? or @using_skill
    casting = @use_spell[0][1]
    pos = casting[1]
    target = casting[2]
    if target != nil
      pos = [target[0].x+target[1][0], target[0].y+target[1][1]]
    end
    @cursor.moveto( pos) 
    return true if update_screen
    @using_skill = true
    @active_battler = @use_spell.shift[0]
    @spell = casting[0]
    
    @active_battler.current_action.set_skill(@spell.id)
    #@active_battler.current_action.item_id = 0
    draw_ranges(@active_battler, 5)
    update_target_cursor
    @targets = @active_battler.get_targets
    activate_immediat_skill
    return true
  end
  
  #----------------------------------------------------------
  #*Play sound when level up
  #----------------------------------------------------------
  if GTBS::LEVEL_GAIN_SE and GTBS::LEVEL_GAIN_SE != ""
    def play_sound_levelup 
      Audio.se_play('Audio/SE/' + GTBS::LEVEL_GAIN_SE , 80, 100) 
    end 
  else# LEVEL_GAIN_SE = ""
    def play_sound_levelup 
    end
  end
  #----------------------------------------------------------------------------------------------------------------------
  # Gain Exp - Gains exp for the set battler and displays it, using the damage show function
  #----------------------------------------------------------------------------------------------------------------------
  def gaining_exp?
    return false if @exp_gained.empty?
    type, battler , targets  = @exp_gained.shift 
    #no exp for Enemy
    return false unless battler && battler.team == Battler_Actor && battler.actor?
    @windows[Win_Help].hide
    exp = battler.calculate_exp(targets)
    return false if exp == 0
    lev = {}  
    if GTBS::EXP_ALL
      actors = friends_of(Battler_Actor).select {|mem| mem.is_a?(Game_Actor)}
      actors_gain_exp = GTBS::NEUTRAL_EXP ? actors : actors.select{|mem| !mem.neutral}
      for bat in actors_gain_exp
        if bat == battler
          bat_exp = exp
        else
          bat_exp = (exp * (GTBS::EXP_PERC_FOR_PARTY/100)).to_i
        end
        apply_gain_exp(bat, bat_exp, lev)
      end
    else# !GTBS::EXP_ALL
      apply_gain_exp(battler, exp, lev)
    end
    if lev.keys.size > 0
      @windows[Win_LevelUp] = Window_EXP_Earn.new(battler, lev)
      @windows[Win_LevelUp].visible = true
      @windows[Win_LevelUp].active = true
      #play levelup sound
      play_sound_levelup
      while @windows[Win_LevelUp] != nil
        update_basic
        update_exp_window
      end
    end
    wait(GTBS::EXP_WAIT_TIME)
    return true
  end
  #-----------------------------------------------------------------------------
  #* check if bat levelup and make graphic setup
  #----------------------------------------------------------------------------
  def apply_gain_exp(battler, exp, lev)
    plev = battler.level
    @log_window.show_exp_gain(battler, exp * battler.final_exp_rate) if !GTBS::POP_EXP
    battler.gain_exp(exp)
    if GTBS::POP_EXP
      battler.result.set_gain_exp(sprintf(Vocab_GTBS::POP_Gain_Exp, exp * battler.final_exp_rate))
    else
      if battler.level > plev
        lev[battler] = [plev, battler.level]
      end
    end
  end
  #----------------------------------------------------------------
  # Check for input when exp gain window is displayed
  #----------------------------------------------------------------
  def update_exp_window
    @windows[Win_LevelUp].update
    if Input.trigger?(Input::B) or Input.trigger?(Input::C)
      Sound.play_decision
      @windows[Win_LevelUp].active = false
      @windows[Win_LevelUp].visible = false
      @windows[Win_LevelUp].dispose
      @windows.delete(Win_LevelUp)
    end
  end
  #----------------------------------------------------------------------------
  # Disable Cursor
  #----------------------------------------------------------------------------
  def disable_cursor(remain_active=false)
    @cursor.active = remain_active
    @cursor.mode = nil
  end
  #----------------------------------------------------------------------------
  # Use ITEM
  #----------------------------------------------------------------------------
  def update_cursor_item 
   update_status_revive(@item)
   
    if Input.trigger?(Input::B)
      Sound.play_cancel
      if @windows[Win_Revive].active
        cancel_win_revive
        @cursor.active = true
      else
        disable_cursor
        @windows[Win_Status].hide
        open_item_window
        clear_tr_sprites
      end
    elsif Input.trigger?(Input::C) 
      if @windows[Win_Revive].active
        @targets = [@dead_actors[@windows[Win_Revive].index]]
        valid_win_revive(@item)
      elsif @cursor.in_range?
        valid_item
      else
        Sound.play_buzzer
      end
    end
  end
  #----------------------------------------------------------------------------
  # Use skill Actor
  #----------------------------------------------------------------------------
  def update_cursor_skill
     update_status_revive(@spell)
    if Input.trigger?(Input::B)
      Sound.play_cancel
      if @windows[Win_Revive].active
        cancel_win_revive
      else
        @windows[Win_Status].clear_dmg_preview 
      end
      disable_cursor
      @spell = nil
      @cursor.active = false 
      clear_tr_sprites
      open_skill_window
      
    elsif Input.trigger?(Input::C)
      if @windows[Win_Revive].active
        valid_win_revive(@spell)
      elsif @cursor.in_range?
        valid_skill
      else
        #Out of range
        Sound.play_buzzer
      end
    end
  end
  #----------------------------------------------------------------------------
  # Actor Menu Open
  #----------------------------------------------------------------------------
  def actor_menu_open
    @windows[Menu_Actor].activate
    @windows[Menu_Actor].clear_help
    @windows[Menu_Actor].call_update_help
  end
  #----------------------------------------------------------------------------
  # Actor attack
  #----------------------------------------------------------------------------
  def cursor_use_attack
    if Input.trigger?(Input::B) 
      Sound.play_cancel
      disable_cursor
      clear_tr_sprites
      actor_menu_open
    elsif Input.trigger?(Input::C) 
      if @cursor.in_range?
        @active_battler.current_action.set_attack
        @targets = get_targets
        if @targets.size > 0
          @cursor.active = false
          @windows[Win_Status].dmg_preview(1, @active_battler, @targets)
          @windows[Win_Confirm].ask(Command_Confirm::Attack)
          Sound.play_decision
        else
          Sound.play_buzzer
        end
      else
        Sound.play_buzzer
      end
    end
  end
  #----------------------------------------------------------------------------
  # Actor Move
  #----------------------------------------------------------------------------
  def cursor_use_move
    if Input.trigger?(Input::B)
      Sound.play_cancel
      actor_menu_open
      disable_cursor #* actor Menu active
      clear_tr_sprites
      return true
    elsif Input.trigger?(Input::C)
      if @cursor.in_range? and [nil, @active_battler].include?(occupied_by?)
        Sound.play_decision
        @pre_x = @active_battler.x
        @pre_y = @active_battler.y
        if !@active_battler.can_teleport?
          @active_battler.run_route(@route[@cursor.pos])
          @active_battler.cost_for_move = @cost[@cursor.pos] 
        end
        #range at the destination position not drawn 
        @drawn = false
        loop do
          update_basic
          break unless @active_battler.moving? 
        end
        @windows[Win_Confirm].ask(Command_Confirm::Move, @active_battler.cost_for_move * GTBS::REQUIRED_TP_FOR_MOVE, Vocab.tp)
        return true
      else
        Sound.play_buzzer
      end
      return false
    end
  end
  #----------------------------------------------------------------------------
  # Phase 0 - No selected actor/enemy
  #----------------------------------------------------------------------------
  def cursor_no_select
    if  Input.trigger?(Input::B)
      check_area 
      return true
    elsif Input.trigger?(Input::C) 
      clear_tr_sprites
      if @ATB_Active
        atb_press_valid
      else#TEAM Mode
        team_mode_press_valid
      end
      return true
    end  
  end

  #-------------------------------------------------------------------------
  # Update_Selected - returns cursor selected actor
  #-------------------------------------------------------------------------
  def update_selected 
    #no select when exiting
    if @battle_exiting
      @selected = nil
      
    #fast update if @cursor didn't change position
    elsif @selected.nil? or not @selected.at_xy_coord(@cursor.x, @cursor.y) 
      @selected = nil
      battler = $game_map.occupied_by?(@cursor.x, @cursor.y)
      if battler != nil
      #for battler in tactics_all
      #  next if battler.nil? 
      #  if battler.at_xy_coord(@cursor.x, @cursor.y)
          @selected =  battler
          @windows[Win_Status].update(battler)
          #Modified to be hard coded to top right checking. 
          mx = Graphics.width - @windows[Win_Status].width
          mw = Graphics.width
          my = 0
          mv = @windows[Win_Status].height
          if @spriteset.cursor.x.between?(mx, mw) && @spriteset.cursor.y.between?(my,mv)
            @windows[Win_Status].move_to(3); #lower right
          else
            @windows[Win_Status].move_to(9); #upper right // Default
          end
          return
      #  end
      end 
    end
  end
  #----------------------------------------------------------------------------
  # Check Abort - Need to abort battle?
  #----------------------------------------------------------------------------
  def check_abort
    if BattleManager.aborting?
      return true
    end
    return false
  end 
  #----------------------------------------------------------------------------
  # Update Phase
  #----------------------------------------------------------------------------
  def update_phase
    if @ATB_Active
      if @temp_acted >= (tactics_all.select{|mem| !mem.death_state?}).size
        tbs_increase_turn
        @temp_acted = 0
      end
      process_atb
    else
      check_turn 
      check_phase 
      if @phase_count/2 > tbs_turn_count
        tbs_increase_turn
      end
    end 
  end

  #----------------------------------------------------------------------------
  # Displays the current Phase Picture
  #----------------------------------------------------------------------------
  def check_phase
    if @turn == Turn_Player
      if $game_system.acted.size >= (friends_of(Battler_Actor).select {|mem| !mem.death_state?}).size
        @phase_count += 1
        if @active_battler == nil
          $game_system.acted.clear
          set_turn( Turn_Enemy)
          next_enemy
        end
      end
    elsif @turn == Turn_Enemy
      if $game_system.acted.size >= (friends_of(Battler_Enemy).select {|mem| !mem.death_state?}).size
        @phase_count += 1
        if @active_battler == nil
          $game_system.acted.clear
          set_turn( Turn_Player)
          @cursor.moveto( tactics_actors.first)
        end
      end
    end
  end
  #----------------------------------------------------------------------------
  # Check Turn - Sets an active battler if an enemy/neutral needs to act
  #----------------------------------------------------------------------------
  def check_turn
    if @turn == Turn_Enemy
      next_enemy
    elsif @turn == Turn_Player
      next_actor
    end
  end
  #-------------------------------------------------------------------------
  # Next Enemy - determines what enemy will act next(only used in team mode)
  #-------------------------------------------------------------------------
  def next_enemy
    return if @active_battler != nil
    return if process_forced_action
    for battler in tactics_all
      next if battler.team == Battler_Actor #In other words, bypass all 'actors'
      next if $game_system.acted.include?(battler)
      next if battler.death_state?
      set_active_battler(battler)
      return
    end
  end
  
  #-------------------------------------------------------------------------
  # Next Actor - determines which actor will act next(only used in team mode)
  #-------------------------------------------------------------------------
  def next_actor
    return if @active_battler != nil
    return if process_forced_action
    for battler in tactics_all
      next if battler.team != Battler_Actor
      next if $game_system.acted.include?(battler)
      next unless battler.ai_controlled? 
      next if battler.death_state?
      set_active_battler(battler)
      return
    end
    if @active_battler.nil? and @cursor.active == false
      disable_cursor(true)
      battler = (tactics_allies.select {|bat| !$game_system.acted.include?(bat)}).first
      if battler != nil
        @cursor.moveto(battler.pos)
      end
    end
  end
  #--------------------------------------------------------------------------
  #* turn_count
  #-------------------------------------------------------------------------
  def tbs_increase_turn 
    $game_troop.increase_turn
    BattleManager.turn_end
    process_battle_event
    BattleManager.turn_start
    @escape_cooldown = [0, @escape_cooldown - 1].max
  end
  #-------------------------------------------------------------------------
  # Set Turn Count
  #-------------------------------------------------------------------------
  def tbs_turn_count=(val)    
    step = val - $game_troop.turn_count
    while val > $game_troop.turn_count
      $game_troop.increase_turn
    end
  end
  #-------------------------------------------------------------------------
  # Get current turn count
  #-------------------------------------------------------------------------
  def tbs_turn_count
    $game_troop.turn_count
  end
  #----------------------------------------------------------------------------
  # Process Battlers - Main battler update thread
  #----------------------------------------------------------------------------
  def process_atb 
    while @active_battler == nil
      process_forced_action
      for battler in tactics_all
        battler.check_casting
      end
      return if @using_skill
      @use_spell = next_wait_skill(tactics_all) 
      return unless @use_spell.empty?
      next_battler = next_atb_battler(tactics_all)
      if next_battler
        next_battler.reset_atb
        set_active_battler(next_battler)
        return
      else 
        update_atb(tactics_all)
      end
    end
  end
  
  #----------------------------------------------------------------------------
  # Process Battlers - battler update thread
  #----------------------------------------------------------------------------
  def fake_process_atb(list_battlers)
    use_spell = next_wait_skill(list_battlers)
    return use_spell unless use_spell.empty?
    
    next_battler = next_atb_battler(list_battlers)
    if next_battler
      next_battler.reset_atb 
    else
      update_atb(list_battlers)  
    end
    return next_battler 
  end
  #--------------------------------------------------------------------------
  #* check for skill_cast
  #-------------------------------------------------------------------------
  def next_wait_skill(list_battlers)
    use_spell = []
    for battler in list_battlers
      if battler.paralyzed? or battler.sleeping? or battler.knocked_out? or battler.muted?
        battler.skill_cast = nil
        battler.up_cast(true)
      elsif battler.cast != nil and !battler.casting?
        use_spell.push([battler, battler.cast])
        battler.skill_cast = nil
      end
    end
    return use_spell
  end
  #--------------------------------------------------------------------------
  #* update_atb
  #-------------------------------------------------------------------------
  def update_atb(list_battlers)
    for battler in list_battlers
      next if battler.paralyzed? or battler.sleeping? or battler.knocked_out? or battler.hidden?
      battler.atb_update
      battler.up_cast     if battler.casting? and !battler.muted?
    end
  end
  
  #--------------------------------------------------------------------------
  #* next atb battler: sort battlers by atb and check skill_cast
  #-------------------------------------------------------------------------
  def next_atb_battler(list_battlers)
    atb_list = []
    for bat in list_battlers
      next if bat.death_state?
      next if bat.atb < bat.recuperation_time
      atb_list.push [bat, bat.atb - bat.recuperation_time, bat.recuperation_time]
    end
    return nil if atb_list.empty?
    #find best battler
    next_bat =  atb_list.max{ |a, b|
      next a[1] - b[1] unless a[1] == b[1]
      next b[2] - a[2]
      }
      return next_bat[0]
  end
  #-------------------------------------------------------------------------
  # Set_Active_Battler - Sets the battler, as active and initiates battler phase
  #-------------------------------------------------------------------------
  def set_active_battler(battler, forcing = false)
    clear_tr_sprites
    @active_battler = battler
    play_select_active_sound
    set_active_cursor
    #reset spell/item
    @spell = nil
    @item = nil
    
    if @active_battler.death_state?
      @active_battler = nil;
      return;
    end
    
    #can move or act? recover...
    @active_battler.start_turn
    
    #reset player control: if player controlled, menu or cursor will be active
    disable_player_control
    if @active_battler.ai_controlled?
      while update_screen
        update_basic
      end
      update_AI(forcing)
    else
      @windows[Menu_Actor].setup(@active_battler)
      if GTBS::ENABLE_MOVE_START and !@active_battler.moved?
        active_cursor_move
      end
    end
  end

  #----------------------------------------------------------------------------
  # Desactivate active battler
  #----------------------------------------------------------------------------
  def deactivate_battler
    if @ATB_Active
      @temp_acted += 1
    else
      $game_system.acted.push(@active_battler)
    end
    @active_battler.on_turn_end
    @active_battler = nil
    disable_player_control
  end
  #-------------------------------------------------------------------------
  #ensure actor selection mode is disable
  #-------------------------------------------------------------------------
  def disable_player_control
    @windows[Menu_Actor].active = false
    @cursor.mode = nil
    @cursor.active = false
  end  
  #-------------------------------------------------------------------------
  #Plays Audio "SelectActive" when the actor has been selected.
  #-------------------------------------------------------------------------
  def play_select_active_sound
    if FileTest.exist?('Audio/SE/SelectActive.mp3') or 
      FileTest.exist?('Audio/SE/SelectActive.wav') or FileTest.exist?('Audio/SE/SelectActive.ogg')
      Audio.se_play('Audio/SE/SelectActive', 100, 100)
    end
  end
  #-------------------------------------------------------------------------
  # Set_Active_Cursor - Sets cursor (x,y) to active_battler (x,y)
  #-------------------------------------------------------------------------
  def set_active_cursor 
    if !@cursor.at?( @active_battler)
      @cursor.moveto( @active_battler)
      update_selected
    end
  end
  #-------------------------------------------------------------------------
  #  Update Actor Menu
  #-------------------------------------------------------------------------
  def actor_menu_attack
    @cursor.range = draw_ranges(@active_battler, 7) ;   update_target_cursor
    @cursor.mode = TBS_Cursor::Attack
    @windows[Menu_Actor].active = false
    @windows[Menu_Actor].visible = false 
  end
  #----------------------------------------------------------------------------
  def actor_menu_skill
    @windows[Menu_Actor].deactivate
    @windows[Menu_Actor].hide
    open_skill_window
  end
  #----------------------------------------------------------------------------
  def actor_menu_wait
    if GTBS::WAIT_CONFIRM
      if !@active_battler.moved?
        if !@active_battler.perfaction? 
          text = Vocab_GTBS::Do_Not_Move_Or_Attack
        else
          text = Vocab_GTBS::Do_Not_Move
        end
      elsif !@active_battler.perfaction? 
          text = Vocab_GTBS::Do_Not_Attack
      else 
        activate_wait_phase
        return
      end 
      @windows[Win_Confirm].ask( Command_Confirm::Wait, text) 
      @windows[Menu_Actor].active = false
      @windows[Menu_Actor].visible = false
    else 
      activate_wait_phase 
    end
  end
  #----------------------------------------------------------------------------
  def actor_menu_item
    @windows[Menu_Actor].active = false
    @windows[Menu_Actor].visible = false
    @windows[Win_Status].visible = false 
    open_item_window
  end  
  #----------------------------------------------------------------------------
  def actor_menu_escape
    if BattleManager.can_escape?
      if @escape_cooldown == 0
        process_escape 
      else
        $game_message.add(Vocab_GTBS::Escape_Cooldown)
        Sound.play_buzzer
        actor_menu_open
      end
    else
      Sound.play_buzzer
      actor_menu_open
    end
  end
  #----------------------------------------------------------------------------
  def process_escape
    $game_message.add(sprintf(Vocab::EscapeStart, $game_party.name))
    success = BattleManager.preemptive ? true : (rand < BattleManager.make_escape_ratio)
    Sound.play_escape
    if success
      end_battle(1) #abort has been remapped to 1 rather than 2
    else
      $game_message.add('\.' + Vocab::EscapeFailure)
      $game_party.clear_actions
      @escape_cooldown = GTBS::ESCAPE_COOLDOWN
    end
    
    for actor in tactics_actors
      next if actor == @active_battler
      if $game_system.cust_battle == Game_System::ATB_Mode
        actor.on_turn_end
        @temp_acted += 1
      else
        $game_system.acted << actor
        actor.on_turn_end
      end
    end
    deactivate_battler #performs end of turn data
    wait_for_message
  end
  #----------------------------------------------------------------------------
  def actor_menu_move
    active_cursor_move
  end
  #----------------------------------------------------------------------------
  def actor_menu_status
    #@windows[Win_Status].visible = false
    open_status_window(@active_battler)        
  end
  #----------------------------------------------------------------------------
  def actor_menu_equip
    Graphics.freeze
    
    for win in @windows.values
      win.hide
      win.deactivate
    end
   
    SceneManager.snapshot_for_background
    actor = @active_battler
    $game_party.menu_actor = actor
    index = @windows[Menu_Actor].index
    oy = @windows[Menu_Actor].oy
    previous_equips = actor.equips
    #---
    SceneManager.call(Scene_Equip)
    SceneManager.scene.main
    SceneManager.force_recall(self)
    #---
    
    actor.set_equip_cooldown if previous_equips != actor.equips
    
    actor_menu_open
    @windows[Menu_Actor].select(index)
    @windows[Menu_Actor].oy = oy
    @windows[Win_Status].refresh
    
    perform_transition
  end
  #----------------------------------------------------------------------------
  def actor_menu_cancel
    @windows[Menu_Actor].deactivate
    @windows[Menu_Actor].hide
    @windows[Win_Help].hide
    disable_cursor(true)
  end
  #----------------------------------------------------------------------------
  # Update Actor Menu
  #----------------------------------------------------------------------------
  def update_actor_menu
    if @active_battler == nil 
      @windows[Menu_Actor].deactivate
      return
    elsif @active_battler.death_state?
      deactivate_battler
      @windows[Menu_Actor].deactivate
      return
    elsif GTBS::Force_Wait and @active_battler.perfaction? and @active_battler.moved?
      activate_wait_phase
      return 
    end
    @windows[Menu_Actor].visible = true  #||=
    @windows[Menu_Actor].update
    #@windows[Menu_Actor].call_update_help
    set_active_cursor #sets active battler as selected for status dialog reasons
    @windows[Win_Status].visible = true
  end
  #-------------------------------------------------------------------------
  #  update_window_skill
  #-------------------------------------------------------------------------
  def update_window_skill
    @windows[Win_Skill].update #update should be called normally but it isnt
    @windows[Win_Status].hide
    #@windows[Win_Skill].call_update_help
    if Input.trigger?(Input::B)
      Sound.play_cancel
      close_window_skill 
      actor_menu_open
    elsif Input.trigger?(Input::C)
      # Get currently selected data on the skill window
      @spell = @windows[Win_Skill].skill
     
      if @spell and @active_battler.skill_can_use?(@spell)
        # Play decision SE
        Sound.play_decision
        # Set action
        @active_battler.current_action.set_skill(@spell.id) 
        # Make skill window invisible 
        close_window_skill
        @cursor.range = draw_ranges(@active_battler,5)  ;   update_target_cursor
        @cursor.mode = TBS_Cursor::Skill
      else # If it can't be used
        @spell = nil
        Sound.play_buzzer
      end 
    end 
  end 
  #-------------------------------------------------------------------------
  #  hide window skill
  #-------------------------------------------------------------------------
  def close_window_skill 
    @windows[Win_Skill].deactivate#active = false
    @windows[Win_Skill].hide#visible = false
    @windows[Win_Skill].index = -1
    @windows[Win_Help].move_to(2)
  end
  
  #-------------------------------------------------------------------------
  #  update_window_item
  #-------------------------------------------------------------------------
  def update_window_item 
    @windows[Win_Item].update
    @windows[Win_Status].hide
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @windows[Win_Item].deactivate
      @windows[Win_Item].hide
      #actor_menu_open
      actor_menu_open
      @windows[Win_Help].move_to(2)
      return
    elsif Input.trigger?(Input::C) 
      @item = @windows[Win_Item].item
      if $game_party.usable?(@item)
        Sound.play_decision
        @active_battler.current_action.set_item(@item.id)
        @cursor.range = draw_ranges(@active_battler, 8) ;   update_target_cursor
        @cursor.mode = TBS_Cursor::Item
        @windows[Win_Item].deactivate
        @windows[Win_Item].hide
        return
      else
        @item = nil
        Sound.play_buzzer
      end
    end
  end 
  #----------------------------------------------------------------------------
  # Check Victory Conditions
  #----------------------------------------------------------------------------
  def check_victory_conditions
    case @vic_condition
    when nil #All enemies dead
      en_alive = friends_of(Battler_Enemy).select {|mem| !mem.death_state?}
      if en_alive.size == 0
        add_vic_com
      end
    when GTBS::Vic_Reach
      for battler in friends_of(Battler_Actor)
        if battler.x == @vic_val[0] and battler.y == @vic_val[1]
          add_vic_com
          break
        end
      end
    when GTBS::Vic_Boss
      present = 0
      for battler in friends_of(Battler_Enemy)
        if battler.enemy_id == @vic_val && !battler.death_state?
          present = 1
        end
      end
      if present == 0
        add_vic_com
      end
    when GTBS::Vic_Critical_Enemy
      en = $data_enemies[@vic_val[0]].name
      for battler in friends_of(Battler_Enemy)
        if battler.name == en
          perc = battler.hp/battler.mhp.to_f * 100
          if @vic_val[1] != nil and perc <= @vic_val[1]
            add_vic_com
          end
        end
      end
    when GTBS::Vic_Critical_Actor
      actor = $game_actors[@vic_val[0]]
      perc = actor.hp/actor.mhp.to_f * 100
      if @vic_val[1] != nil and perc <= @vic_val[1]
        add_vic_com
      end
    when GTBS::Vic_Holdout
      if tbs_turn_count == @vic_val
        add_vic_com
      end
    end
  end
  #----------------------------------------------------------------------------
  # Check Failure Conditions
  #----------------------------------------------------------------------------
  def check_failure_conditions
    case @fail_condition
    when GTBS::Fail_Holdout
      if tbs_turn_count > @fail_val
        add_fail_com
      end
    when  GTBS::Fail_Death
      exist = false
      actor = $game_actors[@fail_val]
      if (tactics_dead.include?(actor))
        p "Failre to protect #{actor.name}"
        add_fail_com
      end
    end
  end
  #----------------------------------------------------------------------------
  # Judge - This determines battle results setup within victory/failure conditions
  #----------------------------------------------------------------------------
  def judge_win_loss
    return if update_processes or @spriteset.effect?
    #-------------------------------------------------------------
    # Check Victory Conditions
    check_victory_conditions

    #-------------------------------------------------------------
    # Check Failure conditions
    check_failure_conditions
    
    #If all Actors dead
    if (friends_of(Battler_Actor).select {|mem| !mem.death_state?}).empty?
      add_fail_com
    end
    update_event_queue
  end
  #----------------------------------------------------------------------------
  # Short hand method to make calling the victory event easier
  #----------------------------------------------------------------------------
  def add_vic_com
    if @vic_com != nil and @common_events[@vic_com] != nil
      @common_event_q += @common_events[@vic_com].list
    end
    if @common_events[GTBS::VIC_COM] != nil
      @common_event_q += @common_events[GTBS::VIC_COM].list
    end
    end_battle(0)
  end
  #----------------------------------------------------------------------------
  # Short hand method to make calling the fail event easier
  #----------------------------------------------------------------------------
  def add_fail_com
    if @fail_com != nil and @common_events[@fail_com] != nil
      @common_event_q += @common_events[@fail_com].list
    end
    if @common_events[GTBS::FAIL_COM] != nil and BattleManager.can_lose?
      @common_event_q += @common_events[GTBS::FAIL_COM].list
    end
    end_battle(2)
  end
  #----------------------------------------------------------------------------
  # Update Event Queue
  #----------------------------------------------------------------------------
  def update_event_queue
    if @common_event_q.size > 0
      if !$game_troop.interpreter.running?
        $game_troop.interpreter.setup(@common_event_q, 0)
        @common_event_q = []
      end
      return true
    end
    return false
  end
  #----------------------------------------------------------------------------
  # Checks for Player Transfer request
  #----------------------------------------------------------------------------
  def update_transfer
    return unless $game_player.transfer?
    transfer_player
  end
  def transfer_player
    end_battle(1) #escape battle routine
    exit_battle
    $game_player.perform_transfer
  end
  #===================================================================
  #                                                                                       WIN CONFIRM
  #===================================================================
  def win_confirm_update 
    @windows[Win_Confirm].update
    @windows[Win_Help].hide
    case @windows[Win_Confirm].question
    when Command_Confirm::Move
      show_range_after_move?      
      case confirm_trigger?
      when 0; confirm_move 
      when 1; cancel_move
      end

    when Command_Confirm::Attack      
      case confirm_trigger?
      when 0; confirm_attack
      when 1; cancel_attack
      end
      
    when Command_Confirm::Skill
      update_status_revive(@spell)
      case confirm_trigger?
      when 0; confirm_skill
      when 1; cancel_skill
      end
 
    when Command_Confirm::Wait_Skill_Targeting
      if Input.trigger?(Input::C)
        Sound.play_decision
        case @windows[Win_Confirm].index
        when 0; confirm_skill_panel_targeting
        when 1; confirm_skill
        end
        close_confirm_window 
      elsif Input.trigger?(Input::B) 
        Sound.play_cancel
        close_confirm_window
        cancel_skill
      end
    when Command_Confirm::Item
      update_status_revive(@item)
      case confirm_trigger?
      when 0; confirm_item
      when 1; cancel_item
      end
      
    when Command_Confirm::Wait
      case confirm_trigger?
      when 0
        activate_wait_phase
        @windows[Menu_Actor].active = false
      when 1
        actor_menu_open
      end
    when Command_Confirm::Place
      case confirm_trigger?
      when 0
        close_confirm_window 
        @cursor.active = false 
        @windows[Win_Status].visible = false
        clear_tr_sprites
        #leave the prepare phase
        return true
      when 1
        close_confirm_window
        @cursor.active = true
        return nil
      end
    when Command_Confirm::Revive
      case @cursor.mode
      when TBS_Cursor::Item
        case confirm_trigger?
        when 0; confirm_item
        when 1; cancel_item
        end
      when TBS_Cursor::Skill
        case confirm_trigger?
        when 0; confirm_skill
        when 1; cancel_skill
        end
      end 
    end 
  end 
  #-------------------------------------------------------------------------
  # close_confirm_window
  #-------------------------------------------------------------------------
  def close_confirm_window
    @windows[Win_Confirm].active = false
    @windows[Win_Confirm].visible = false
    @windows[Win_Confirm].reset_commands
  end
  #-------------------------------------------------------------------------
  # Check for confirmation
  #-------------------------------------------------------------------------
  def confirm_trigger?(sound = true)
    if Input.trigger?(Input::C)
      Sound.play_decision if sound
      answer = @windows[Win_Confirm].index
    elsif Input.trigger?(Input::B)
      Sound.play_cancel if sound
      answer = 1
    end
    if answer
      close_confirm_window
      @windows[Win_Confirm].index = -1
    end
    return answer
  end
  #--------------------------------------------------------------------------------
  # press ENTER on the map
  def atb_press_valid
    if @selected == @active_battler
      #open menu actor
      actor_menu_open
      #@windows[Win_Help].show
      disable_cursor
    else
      #move cursor to active battler
      Sound.play_decision
      set_active_cursor
    end
  end
  
  #---------------------------------------------------------
  #active the selected actor or move to the next actor
  def  team_mode_press_valid
    if @selected != nil && @selected.team == Battler_Actor && !$game_system.acted.include?(@selected)
      #@active_battler.blink = false unless @active_battler == nil
      set_active_battler(@selected)
    elsif @selected == nil
      #move to next actor
      for actor in tactics_all
        next if actor.team != Battler_Actor
        next if $game_system.acted.include?(actor) 
        @cursor.moveto( actor)
        return
      end 
    end
  end
  #===========================================================
  # Wait Direction
  #===========================================================
  def actor_wait_phase 
    @wait_pic.update
    if Input.trigger?(Input::B)
      #reset actor direction to original direction
      @active_battler.set_direction(@wait_pic.initial_dir)
      exit_wait_phase
      actor_menu_open
      
    elsif Input.trigger?(Input::C)
      @active_battler.set_wait
      check_batevent_trigger
      deactivate_battler
      exit_wait_phase 
      next_actor      if !@ATB_Active
    end
  end
  #-------------------------------------------------------------------------
  # update_window_detail
  #-------------------------------------------------------------------------
  def update_window_detail
    @windows[Win_Status].hide
    @windows[Win_Detail].update
    if Input.trigger?(Input::B) or Input.trigger?(Input::C)
      Sound.play_cancel
      @windows[Win_Detail].active = false
      @windows[Win_Detail].visible = false
      actor_menu_open unless @cursor.active
      return
    end
  end
  #----------------------------------------------------------------------------
  # Start Wait phase
  #----------------------------------------------------------------------------
  def activate_wait_phase
    @cursor.active = false
    @windows[Menu_Actor].active = false
    @windows[Menu_Actor].visible = false 
    unless @wait_pic
      @wait_pic = Wait_Cursor.new(@spriteset.viewport1, @active_battler)
      @wait_pic.moveto(@active_battler.x, @active_battler.y-1)
      @temp_dir = @active_battler.direction
    end
  end
  #----------------------------------------------------------------------------
  # End Wait phase
  #----------------------------------------------------------------------------
  def exit_wait_phase
    @wait_pic.dispose
    @wait_pic = nil
    @windows[Win_Help].hide
  end
  #--------------------------------------------------------------------------------
  # press ECSAPE on the map
  #----------------------------------------------------------------------------
  # Draws area around selected actor/enemy, showing their move attack and spell ranges.
  #----------------------------------------------------------------------------
  def check_area
    if @selected == nil 
      #if an area is visible
      if @drawn
        clear_tr_sprites
        @drawn = false
      else
        @windows[Win_Option].active = true
        @windows[Win_Option].visible = true
        @windows[Win_Option].index = 0
        @cursor.active = false
      end
    elsif @drawn == @selected
      #clear_tr_sprites
      #@drawn = false
      open_status_window(@selected)
    elsif not @selected.hide_move?
      clear_tr_sprites
      @drawn = @selected
      #choose type of drawing
      if @selected.is_a?(Game_Enemy)
        type = 1
      elsif not (@selected.perfaction? ^ @selected.moved?)# (moved and perfaction) or none
        type = 2
      elsif @selected.perfaction?# and !@selected.moved?
        type = 3
      else# if !@selected.perfaction? and @selected.moved?
        type = 4
      end 
      draw_ranges(@selected, type)
    end
  end
  #-------------------------------------------------------------
  # Draws Ranges - this applies to target tiles as well  
  # type = 
  #  1*: enemy move, attack,and spell field (check_area)
  #  2*: actor all                                                  (check_area)
  #  3*: battler move range only
  #  4*: actor moved, but not acted
  #  5: spell target area only
  #  7*: weapon range only
  #  8*: item range
  #-------------------------------------------------------------
  def draw_ranges(battler, type)
    
    @cursor.target_area.clear
    attack_spell_min   = 0
    help_spell_min     = 0
    #set move_range
    restrict_move = (type > 3)
    move_range = restrict_move ? 0 : battler.base_move_range
    
    case type
    when 1    #enemy move, attack,and spell field
      weapon_range = battler.weapon_range
      attack_range_max = weapon_range[0]
      attack_range_min = weapon_range[1]
      #don't set spell range if enemy haven't 
      attack_spell_range = battler.attack_skill_range[0] 
      
    when 2, 4 #actor all or actor moved, but not acted
      weapon_range = battler.weapon_range
      attack_range_max, attack_range_min = weapon_range[0, 2]
      v_range = weapon_range[5]
      
      #don't set spell range if actor haven't
      attack_spell_range = battler.attack_skill_range[0] 
      help_spell_range = battler.help_skill_range
      help_spell_range += move_range if help_spell_range
      
    when 5 # spell target area only
      ##get field of spell, and draw for cursor
      skill_range = battler.skill_range(@spell.id)
      @cursor.target_area[1] = skill_range[2] #line_skill?
      @cursor.target_area[2] = skill_range[3] #exclude_center?
      @cursor.target_area[3] = skill_range[1] #AoE range 
      if @spell.for_opponent?
        @cursor.target_area[0] = 5
        attack_spell_range = skill_range[0]
        attack_spell_min = skill_range[4]
      else# for_friend
        @cursor.target_area[0] = 6
        help_spell_range = skill_range[0]
        help_spell_min = skill_range[4]
      end
      v_range = skill_range[5] # mod_MGC
      @cursor.target_area[4] = skill_range[6] # mod_MGC (aoe)
            
    when 8 #item range
      #This will be the item range draw tile section
      item_range = battler.item_range( @item.id)
      if @item.for_opponent? 
        @cursor.target_area[0] = 5 #attack_skill
        attack_spell_range = item_range[0]
      else# for_friend
        @cursor.target_area[0] = 6 #heal
        help_spell_range = item_range[0]
      end
      @cursor.target_area[1] = false #line_skill?
      @cursor.target_area[2] = false #exclude_center?
      @cursor.target_area[3] = item_range[1] #AoE range
      v_range = item_range[3] # mod_MGC
      @cursor.target_area[4] = item_range[4] # mod_MGC (aoe)
    when 7 #weapon range only
      weapon_range = battler.weapon_range
      attack_range_max, attack_range_min = weapon_range[0, 2]
      @cursor.target_area[0] = 7
      @cursor.target_area[1] = weapon_range[3] #Affect in line
      @cursor.target_area[2] = false #exclude center (always false for weapons)
      @cursor.target_area[3] = weapon_range[4] #AoE for weapon 
      @cursor.target_area[4] = weapon_range[6] # mod_MGC (aoe)
    end
    
    if [1, 2, 3].include?(type) and battler.can_teleport? #if either teleport state enabled
      @move_positions = battler.set_teleport_positions
      help_range     = []
      attack_spell   = []
      attack_range = []
    else
      @route, @cost = battler.calc_pos_move(move_range)
      @move_positions = @route.keys
      #weapon range
      if weapon_range
        if weapon_range[2] # bow?
          attack_range = battler.calc_pos_bow( attack_range_max, attack_range_min, @move_positions)
        else
          attack_range = battler.calc_pos_attack( attack_range_max, attack_range_min, @move_positions)
        end
      else
        attack_range = []
      end
      #spell/itrem range
      if @cursor.target_area[1]  #line ?
        help_range = battler.calc_pos_attack( help_spell_range, help_spell_min, @move_positions )
        attack_spell = battler.calc_pos_attack( attack_spell_range, attack_spell_min, @move_positions )
      else
        help_range = battler.calc_pos_spell( help_spell_range, help_spell_min, @move_positions, v_range) # mod_MGC
        attack_spell = battler.calc_pos_spell( attack_spell_range, attack_spell_min, @move_positions, v_range) # mod_MGC
      end
      #----------------------------------------------------------------
      # Remove duplicated cells so no overlap occurs.
      #----------------------------------------------------------------
      attack_range -= @move_positions
        
      case type 
      when 1, 2#actor or enemy all
        attack_spell -= @move_positions
        attack_spell -= attack_range
        help_range  -=  @move_positions
        help_range  -= attack_range
        help_range  -= attack_spell
      when 4 #actor moved, but not acted
        attack_spell -= attack_range
      end
    end
    
    @spriteset.draw_range(@move_positions, 2) unless type > 4
    @spriteset.draw_range(attack_range, 1)
    @spriteset.draw_range(attack_spell, 4)
    @spriteset.draw_range(help_range, 3)
    @cursor.target_positions = []

    #return the active range to update @cursor.range = 
    case @cursor.target_area[0] #type of colored range
    when 5
      return attack_spell
    when 6
      return help_range
    when 7
      return attack_range
    else
      return @move_positions
    end
  end
  #--------------------------------------------------------
  # open Status Window for battler
  #------------------------------------------------------
  def open_status_window(battler)
    Sound.play_decision
    @windows[Win_Detail].refresh(battler)
    @windows[Win_Detail].activate
    @windows[Win_Detail].show
    @windows[Menu_Actor].hide
    @windows[Win_Help].hide
    @windows[Win_Status].hide
  end
  #--------------------------------------------------------
  # draw ranges and active move cursor
  #------------------------------------------------------
  def active_cursor_move
    @cursor.range = draw_ranges(@active_battler, 3)
    @windows[Menu_Actor].deactivate
    @windows[Menu_Actor].hide
    @windows[Win_Help].hide
    @drawn = false
    @cursor.mode = TBS_Cursor::Move
  end
  #--------------------------------------------------------
  # open Skill Window
  #------------------------------------------------------
  def open_skill_window
    @windows[Win_Help].move_to(8) 
    @windows[Win_Skill].stype_id =  @windows[Menu_Actor].current_ext
    @windows[Win_Skill].refresh(@active_battler)
    @windows[Win_Skill].show 
    @windows[Win_Skill].activate
    @windows[Win_Skill].index = 0
    @windows[Win_Skill].call_update_help #should be called by index=
  end
  #--------------------------------------------------------
  # open Skill Window
  #------------------------------------------------------
  def open_item_window
    #@windows[Win_Help].show
    @windows[Win_Help].move_to(8)
    @windows[Win_Item].index = 0
    @windows[Win_Item].activate
    @windows[Win_Item].show
    @windows[Win_Item].refresh
  end
  #--------------------------------------------------------
  # open Revive Window
  #------------------------------------------------------
  def open_revive_window
    if GTBS::TARGET_DEAD_UNIT
      range = @cursor.target_positions
    else
      range = @cursor.range
    end
    @windows[Win_Revive].refresh(range)
    @windows[Win_Revive].index = 0
    @windows[Win_Revive].activate
    @windows[Win_Revive].visible = true
    @cursor.active = false
    Sound.play_decision 
  end
  #----------------------------------------------------------------------------
  # Update Window Revive
  #----------------------------------------------------------------------------
  def update_win_revive
    @windows[Win_Revive].update
    if Input.trigger?(Input::C)
      valid_win_revive((@spell or @item))
    elsif Input.trigger?(Input::B)
      cancel_win_revive
    end
  end
  #------------------------------------------------------------
  #* cancel win revive
  #------------------------------------------------------------
  def cancel_win_revive
    @windows[Win_Revive].active = false
    @windows[Win_Revive].visible = false
    @windows[Win_Status].clear_dmg_preview
    @windows[Win_Revive].index = -1
    @cursor.active = true
  end
  #------------------------------------------------------------
  #* valid win revive for skill @item or @spell
  #------------------------------------------------------------
  def valid_win_revive(skill)
    @targets.clear 
    @targets.push(@windows[Win_Revive].chosen_revive)
    return if @targets[0] == nil
    if @targets[0].can_occupy?(@cursor.pos)
      Sound.play_decision
      @windows[Win_Confirm].ask(Command_Confirm::Revive, @targets[0].name)
      @windows[Win_Revive].active = false
      @windows[Win_Revive].visible = false 
      @windows[Win_Status].dmg_preview(3, @active_battler, skill, @targets)
    else
      Sound.play_buzzer
      prev_text = @windows[Win_Help].text
      @windows[Win_Help].set_text(sprintf(Vocab_GTBS::Cannot_Occupy, @targets[0].name))
      count = 20
      while count > 0
        count -= 1
        update_basic
        @windows[Win_Help].update
      end
      @windows[Win_Help].set_text(prev_text)
    end
  end
  #----------------------------------------------------------------------------
  # Cancel Attack - Cancels the user attack session, returns cursor control
  #----------------------------------------------------------------------------
  def cancel_attack
    @windows[Win_Status].clear_dmg_preview
    @cursor.active = true 
  end
  #----------------------------------------------------------------------------
  # Confirm Attack - Sets all applicable variables to set attack in motion for player
  #----------------------------------------------------------------------------
  def confirm_attack
    @active_battler.current_action.set_attack
    process_action
    @windows[Win_Status].clear_dmg_preview
    if (@active_battler != nil)
      @active_battler.perf_action = true
    end
    @windows[Menu_Actor].setup(@active_battler)
    actor_menu_open
    clear_tr_sprites
  end
  #----------------------------------------------------------------------------
  # Update the Status Window with the selected dead target (for item or spell)
  #----------------------------------------------------------------------------
  def update_status_revive(skill)
    return unless skill.for_dead_friend? 
    if @windows[Win_Revive].active
      @targets = [@dead_actors[@windows[Win_Revive].index]]
      @windows[Win_Status].update(@targets[0])
    else
      @windows[Win_Status].update(@selected)
    end
    @windows[Win_Status].visible = true
  end
  #-----------------------------------------------------------------
  #* Win_Confirm is active
  #   and trigger? ECHAP
  #------------------------------------------------------------------
  def cancel_skill 
    @windows[Win_Confirm].reset_commands 
    @cursor.active = true
  end
  #----------------------------------------------------------------------------
  # Active skill on the selected @targets
  #----------------------------------------------------------------------------
  def confirm_skill 
    @windows[Win_Confirm].reset_commands 
    disable_cursor
    if @ATB_Active and GTBS::USE_WAIT_SKILLS and GTBS::skill_wait(@spell.id)[0] > 0
      setup_skill_wait
    else#TEAM Mode or immediat skill
      @active_battler.skill_cast = nil
      @active_battler.count_skill_usage(@spell)
      activate_immediat_skill
      return if @active_battler == nil#if dead during process
    end
    @windows[Menu_Actor].setup(@active_battler) 
    actor_menu_open
    @windows[Win_Status].clear_dmg_preview
    clear_tr_sprites
  end
  
  #----------------------------------------------------------------------------
  # setup skill wait for active_battler
  #----------------------------------------------------------------------------
  def setup_skill_wait
    if !GTBS::ALLOW_SKILL_TARGET
      target = nil
    elsif t = occupied_by?
      target = [t,[0, 0]]
    elsif t = @cursor.targeted_battlers.first
      offset_x = @cursor.x-t.x
      offset_y = @cursor.y-t.y
    else
      target = nil
    end
    @active_battler.skill_cast = [@spell, @cursor.pos, target]
    @active_battler.setup_skill
    @active_battler.count_skill_usage(@spell)
    @spell = nil
  end
  #-----------------------------------------------------------------
  #* process skill now
  #-----------------------------------------------------------------
  def activate_immediat_skill
    @active_battler.use_item(@spell)
    process_action
  end

  #----------------------------------------------------------------------------
  # skill_panel_targeting
  #----------------------------------------------------------------------------
  def confirm_skill_panel_targeting
    pos = [@cursor.x, @cursor.y]
    target = nil
    @active_battler.skill_cast = [@spell, pos, target]
    @active_battler.setup_skill
    disable_cursor
    @active_battler.count_skill_usage(@spell)
    @windows[Menu_Actor].setup(@active_battler) 
    actor_menu_open
    clear_tr_sprites
    @windows[Win_Status].clear_dmg_preview
  end
    
  #---------------------------------------------------------------
  #* Cancel Item Usage
  #-----------------------------------------------------------------
  def cancel_item 
    @windows[Win_Revive].active = false
    @windows[Win_Revive].visible = false
    @windows[Win_Status].clear_dmg_preview
    @cursor.active = true
  end
  
  #---------------------------------------------------------------
  #* Confirm Item Usage
  #-----------------------------------------------------------------
  def confirm_item 
    @windows[Win_Help].move_to(2)
    skill_id = GTBS.item_range(@item.id)[2]
    if skill_id > 0 
      #TODO: Review this area
      @spell = $data_skills[skill_id]
      @active_battler.current_action.set_skill(@spell.id)
    else
      @active_battler.current_action.set_item(@item.id)
    end
    @active_battler.use_item(@item)
    @active_battler.turn_to(@targets[0])
    @windows[Win_Item].refresh
    @active_battler.perf_action = true 
    clear_tr_sprites
    @windows[Win_Status].clear_dmg_preview
    @windows[Menu_Actor].setup(@active_battler)
    actor_menu_open
    process_action
  end

  
  #---------------------------------------------------------------
  #* if confirm_active? in move cursor mode
  #-----------------------------------------------------------------
  def cancel_move
    @cursor.active = true
    @active_battler.moveto(@pre_x, @pre_y)
    clear_tr_sprites
    draw_ranges(@active_battler, 3)
  end
  
  def confirm_move
    if @active_battler.can_teleport?
      @active_battler.animation_id = GTBS::TELEPORT_ANIM 
      #check teleport attempt and move if success
      @active_battler.teleport?(@cursor)
      @wait_count = 10
    end 
    @active_battler.moved = true
    @pre_x = nil; @pre_y = nil
    clear_tr_sprites
    disable_cursor
    
    value = (@active_battler.cost_for_move || 0)
    @active_battler.apply_move_cost(value) #cost for this move
    @windows[Menu_Actor].setup(@active_battler)
  end
  
  #---------------------------------------------------------------
  #* show attack/spell range at the selected position
  #-----------------------------------------------------------------
  def show_range_after_move?
    if GTBS::SHOW_MOVE_ATTACK and @drawn == false and @cursor.at?( @active_battler )
      clear_tr_sprites
      unless @active_battler.perfaction?
        if GTBS::MOVE_INCLUDE_SPELL
          draw_ranges(@active_battler, 4)  
        else
          draw_ranges(@active_battler, 7)
        end
        @drawn = true
      end
    end 
  end
  #-------------------------------------------------------------------------
  # Get Targets - Determines targets in target_cursor area  
  #-------------------------------------------------------------------------
  def get_targets
    targets = @active_battler.get_targets
    @cursor.set_targets(targets)
    return targets
  end
  #--------------------------------------------------------------------------
  # * Show Animation
  #     targets      : Target array
  #     animation_id : Animation ID (-1:  Same as normal attack)
  #--------------------------------------------------------------------------
  def show_animation(targets, animation_id)
    if animation_id < 0
      show_attack_animation(targets)
    else
      show_normal_animation(targets, animation_id)
    end
    @log_window.wait
    wait_for_animation
  end
  #--------------------------------------------------------------------------
  # * Show Attack Animation
  #     targets : Target array
  #    Account for dual wield in the case of an actor (flip left hand weapon
  #    display). If enemy, play the [Enemy Attack] SE and wait briefly.
  #--------------------------------------------------------------------------
  def show_attack_animation(targets)
    if @active_battler.actor?
      show_normal_animation(targets, @active_battler.atk_animation_id1, false)
      show_normal_animation(targets, @active_battler.atk_animation_id2, true)
    else
      Sound.play_enemy_attack
      abs_wait_short
    end
  end
  #--------------------------------------------------------------------------
  # * Show Normal Animation
  #     targets      : Target array
  #     animation_id : Animation ID
  #     mirror       : Flip horizontal
  #--------------------------------------------------------------------------
  def show_normal_animation(targets, animation_id, mirror = false)
    animation = $data_animations[animation_id]
    if animation
      targets.each do |target|
        target.animation_id = animation_id
        target.animation_mirror = mirror
        abs_wait_short unless animation.to_screen?
      end
      abs_wait_short if animation.to_screen?
    end
  end
  #--------------------------------------------------------------------------
  # Abs Wait Short - applies short wait - 15 frames
  #--------------------------------------------------------------------------
  def abs_wait_short
    wait(15)
  end
  #--------------------------------------------------------------------------
  # * Update Frame (for Wait)
  #--------------------------------------------------------------------------
  def update_for_wait
    update_basic
  end
  #--------------------------------------------------------------------------
  # * Wait
  #--------------------------------------------------------------------------
  def wait(duration)
    duration.times {|i| update_for_wait if i < duration / 2 || !show_fast? }
  end
  #----------------------------------------------------------------------------
  # Exit Battle
  # result: 0-win, 1-escape, 2-lose
  #----------------------------------------------------------------------------
  def end_battle(result=0)
    clear_tr_sprites
    @spriteset.update
    RPG::BGM.fade(400) 
    BattleManager.battle_end(result)
    @battle_exiting = result
    @cursor.active = false 
    clean_up_battle
    if result == 2 and BattleManager.can_lose? == true
      SceneManager.return #return to map
    end
  end
  #----------------------------------------------------------------------------
  # Clean up Battle functions
  #----------------------------------------------------------------------------
  def clean_up_battle
    for window in @windows.values
      next if window == nil #skill all already disposed items.
      window.visible = false#hide all windows
      window.active = false #disable all windows
    end
    
    for battler in tactics_all
      battler.clear_tbs_actions #clear actions
      battler.tbs_battler = false #clear in battle flag
      add_remove_invited(battler) #check and add 'invited' actors to the team
      remove_dead_actors if GTBS::Dead_Actors_Leave
    end
  end
  #----------------------------------------------------------------------------
  # Remove Dead Actors from the Party
  #----------------------------------------------------------------------------
  def remove_dead_actors
    for battler in tactics_all
      if (battler.actor? && battler.death_state? &&
          $game_party.all_members.include?(battler) &&
          !GTBS::Prevent_Actor_Leave_List.include?(battler.id))
        $game_party.remove_actor(battler.id) 
      end
    end
  end
  #----------------------------------------------------------------------------
  # Add/Remove invited Battlers
  #----------------------------------------------------------------------------
  def add_remove_invited(battler)
    if (battler.enemy? && !battler.death_state? && battler.team == Battler_Actor && 
                                  !battler.states.include?(GTBS::CHARM_ID))  
        
      id = GTBS.capture_to_actor(battler.enemy_id)
      return if id ==0
      $game_party.add_actor(id)
    elsif (battler.actor? && !battler.death_state? && battler.team != Battler_Actor &&
                                !battler.states.include?(GTBS::CHARM_ID))
      $game_party.remove_actor(battler.id)
    elsif (battler.actor? && !battler.death_state? && battler.team == Battler_Actor && 
        !battler.states.include?(GTBS::CHARM_ID) && !$game_party.all_members.include?(battler) &&
        !$game_party.neutrals.include?(battler) && !battler.is_summoned?)
      $game_party.add_actor(battler.id)
    end
  end
  #----------------------------------------------------------------------------
  #Show Gold/Item gain during battle
  #----------------------------------------------------------------------------
   if GTBS::SHOW_ITEMGOLD_IMMEDIATELY
    def show_item_gold?(targets)
      
      dead_list = []
      for target in targets.uniq
        dead_list.push(target) if target.dead? and target.enemy?
      end
      gold = 0
      treasures = []
      for dead in dead_list
        gold += dead.gold
        treasures += (dead.make_drop_items)
      end 
      return if gold == 0 and treasures.empty?
      
      @windows[Win_Status].hide
      show_gold_gain(gold)
      show_item_gain(treasures)
    end 
    #----------------------------------------------------------------------------
    # Make Result Info - Sets Gold/JP and Items gained variables
    #----------------------------------------------------------------------------
    def make_result_info
    end
  else#Show Gold/Item gain at end battle
    def show_item_gold?(targets)  #don't show item/gold gained during battle
    end
    #----------------------------------------------------------------------------
    # Make Result Info - Sets Gold/JP and Items gained variables
    #----------------------------------------------------------------------------
    def make_result_info
      gold = 0
      treasures = $game_troop.make_drop_items
      for en_dead in tactics_dead
        if en_dead.actor? or en_dead.hidden?
          # Add amount of gold obtained
          gold += en_dead.gold
        end
      end
      show_gold_gain(gold)
      show_item_gain(treasures)
    end
  end
  #----------------------------------------------------------------------------
  # Show Gold Gain - Displays the gold gained at the end of battle
  #----------------------------------------------------------------------------
  def show_gold_gain(gold)
    #no gold to show => abort 
    return if gold == 0 
    show_tbs_info_sprite( TBS_Gold_Sprite.new(gold))
    #do gold gain and reset gold counter
    $game_party.gain_gold(gold)
  end
  #----------------------------------------------------------------------------
  # Show Item Gain - Shows the items gained at the end of battle
  #----------------------------------------------------------------------------
  def show_item_gain(treasures)
    #no item to show => abort
    return if treasures.empty? 
    show_tbs_info_sprite(TBS_Treasure_Sprite.new(treasures))
    #do item gain and reset temp treasures
    #add items even if they are not shown
    for item in treasures
      $game_party.gain_item(item, 1)
    end 
  end
  #----------------------------------------------------------------------------
  # Get Wait Guess For Animation
  #----------------------------------------------------------------------------
  # Used to guess at the wait time required for animation to be completed
  #----------------------------------------------------------------------------
  def get_wait_guess_for_animation(anim)
    wait = $data_animations[anim].frame_max rescue wait = 1
    #if GTBS::ANIMID_CHECK.include?(anim)
    #  
    #end
    return wait
  end
  
  #----------------------------------------------------------------
  # Check Battle Event Triggers
  #----------------------------------------------------------------
  def check_batevent_trigger
    return if @active_battler == nil
    for event in $game_system.battle_events.values
      if [0,1,2].include?(event.trigger) #on player touch or event touch
        if event.at_xy_coord(@active_battler.x, @active_battler.y)
          if event.list.size > 0
            event.start unless event.starting
            return
          end
        end
      end
    end
  end
  #------------------------------------------------------------
  #* Win_Revive is inactive 
  #    and press? ENTER in range
  #------------------------------------------------------------
  def valid_skill
    @windows[Win_Help].move_to(2)
    @active_battler.current_action.set_skill(@spell.id)
    @targets = get_targets
    if @ATB_Active and 
      GTBS::USE_WAIT_SKILLS and GTBS::ALLOW_SKILL_TARGET and 
      GTBS::skill_wait(@spell.id)[0] > 0
      occ = occupied_by?(@cursor.x, @cursor.y)
      if occ and !occ.dead? 
        type = Command_Confirm::Wait_Skill_Targeting
      end
      Sound.play_decision
      @cursor.active = false
      #Do immediat skill if type == nil
      @windows[Win_Confirm].ask(Command_Confirm::Skill, type)
      @windows[Win_Status].dmg_preview(2, @active_battler, @spell, @targets)
      
    elsif @targets.size >0 #unless targets 0 or less for some reason
      #make summons miss when cell is occupied
      if (GTBS::is_summon?(@spell.id, @active_battler.is_a?(Game_Actor))> 0 && occupied_by?(@cursor.x, @cursor.y)!= nil) or 
        (@spell.for_opponent? && (@selected == @active_battler && !GTBS::ATTACK_ALLIES) &&
        !@active_battler.skill_range(@spell.id)[3] )
        Sound.play_buzzer
      else
        Sound.play_decision
        @cursor.active = false 
        @windows[Win_Confirm].ask(Command_Confirm::Skill)
        @windows[Win_Status].dmg_preview(2, @active_battler, @spell, @targets)
      end
      
    elsif GTBS::is_summon?(@spell.id, @active_battler.is_a?(Game_Actor))>0 and $game_map.passable?(@cursor.x, @cursor.y, 0)
      Sound.play_decision
      @cursor.active = false 
      @windows[Win_Confirm].ask(Command_Confirm::Skill)
      @windows[Win_Status].dmg_preview(2, @active_battler, @spell, @targets)
      
    elsif (!$game_system.actors_bodies? || GTBS::REVIVE_ANY_DEAD) and 
            @spell.for_dead_friend? and occupied_by?(@cursor.x, @cursor.y) == nil
      open_revive_window
      
    else
      #Unauthorized validation
      Sound.play_buzzer
    end
  end
  #----------------------------------------------------------
  #* valid item usage on the selected tile
  #----------------------------------------------------------
  def valid_item
    @windows[Win_Help].move_to(2)
    #@windows[Win_Help].show
    @active_battler.current_action.clear
    @active_battler.current_action.set_item(@item.id)
    if @item.for_dead_friend? and !$game_system.actors_bodies? 
      if $game_map.passable?(@cursor.x, @cursor.y, 0) and
        (occupied_by?(@cursor.x, @cursor.y) == nil)
        open_revive_window
      end
    else
      @active_battler.current_action.set_item(@item.id)
      @targets = get_targets
      if @targets.empty?
        Sound.play_buzzer
      else
        Sound.play_decision
        @cursor.active = false 
        @windows[Win_Confirm].ask(Command_Confirm::Item) 
        @windows[Win_Status].dmg_preview(3, @active_battler, @item, @targets)
        @windows[Win_Help].move_to(2)
        #@windows[Win_Help].show
      end
    end
  end
  #----------------------------------------------------------
  # Get Battler Sprite
  #----------------------------------------------------------
  def get_battler_sprite(char)
    sprite = nil
    if @mini_showing == true
      if @left_battler.bat == char
        sprite = @left_battler
      elsif @right_battler.bat == char
        sprite = @right_battler
      end
    end
    return (sprite || @spriteset.get_battler_sprite(char))
  end
  #----------------------------------------------------------
  # Confirm Visible - used to inform sprite to 'blink' actors/enemies
  # for visual notification of team assignments. 
  #----------------------------------------------------------
  def confirm_visible
    return false if @windows.nil?
    return false if @windows[Win_Confirm].nil?
    return (@windows[Win_Confirm].active && @windows[Win_Confirm].visible)
  end
end
