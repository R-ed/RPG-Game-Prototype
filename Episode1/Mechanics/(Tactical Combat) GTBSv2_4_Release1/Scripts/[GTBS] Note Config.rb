
module GTBS
#==============================================================
# Easy Config by Clarabel
# Load the settings done in the note place in the editor
# All note entries must be on separate line
#==============================================================
# case ConfigType
# when nil
#   eval data
# when 0
#   set true
# when 1
#   save string
# when 2
#   add id to array
# when 5
#   add string to hash using mapid and subkey region id
# when 6
#   add int to hash using mapid and subkey region id
# when 7
#   Add string to array within hash.  
# when 8
#   Add int to array within hash.  
#            
#==============================================================

  # a parameter is set wirh an array [ Hash_To_Store, reg_exp, is_bool?, protect_string?]
  #DATA_SKILLS Config
  SKILLS_EASY_CONFIG = [
    [ SKILL_RANGE, /^range\s*=(\[\s*\d+\s*,\s*\d+\s*,\s*(true|false)\s*,\s*(true|false)\s*,\s*\d+\s*(,\s*\d+\s*,\s*\d+)?\s*\])/i],
    [ SKILL_AI_RATING, /^ai_rating\s*=\s*(\d+)/i ],
    [ SKILL_USE_ACTION, /^use_action\s*=\s*(true|false)/i ],
    [ SKILL_WAIT_TIME, /^skill_wait\s*=\s*(\[\s*\d+\s*,\s*\d+\s*,\s*(true|false)\s*\])/i],
    [ SKILL_TO_ACTOR_SUMMON, /^actor\s*=\s*(\d+)/i ],  
    [ SKILL_TO_ENEMY_SUMMON, /^enemy\s*=\s*(\d+)/i ],
    [ Secret_Hunt_Skill_List, /(^secret_hunt)/i, 2],
    [ Capture_Skill_List, /(^capture)/i, 2],
    [ Charm_Skill_List, /^charm_turns\s*=\s*(\d+)/i],
    [ Invite_Skill_List, /(^invite)/i,2],
    [ CHAIN_LIGHTNING_SKILLS, /(^chain_lighting)/i, 2],
    [ SKILL_PROJECTILE, /^projectile\s*=\s*(.+)/i,1],
    #[ ACTION_ANIME, /^anime\s*=\s*(.+)/i,1],
    [ PREVENT_SKILL_FRIENDLY_DMG, /(^prevent_friendly_dmg)/i, 2],
    [ TARGET_FIENDLY_ONLY_SKILLS, /(^friendly_only)/i, 2],
    [ Prevent_Skill_Range_Mod, /(^prevent_range_mod)/i, 2],
    [ Skill_Ignore_DirectionalDmg, /(^ignore_dir)/i, 2],
    [ Reset_Action_Flag_Skills, /(^reset_action)/i,2],
    [ Reset_Move_Flag_Skills, /(^reset_move)/i, 2]
  ]

  #DATA_ITEMS Config
  ITEMS_EASY_CONFIG=[
    [ITEM_RANGE, /^range\s*=\s*(\[\s*\d+\s*,\s*\d+\s*,\s*\d+\s*(,\s*\d+\s*,\s*\d+\s*)?\])/i]
  ]

  #DATA_WEAPONS Cconfig
  WEAPONS_EASY_CONFIG = [
    [WEAPON_RANGE, /^range\s*=\s*(\[\s*\d+\s*,\s*\d+\s*,\s*(true|false)\s*,\s*(true|false)\s*,\s*\d+\s*(,\s*\d+\s*,\s*\d+\s*)?\])/i], 
    [WEAPON_Move_Info, /^move\s*=\s*([\s*-*\d\s*]+)/i],
    [Weapon_Skill_Range, /^skill_range\s*=\s*(\[\s*\d+\s*,\s*\d+\s*,\s*\d+\s*(,\s*\d+\s*,\s*\d+\s*)?\])/i],
    [CHAIN_LIGHTNING_WEAPONS, /(^chain_lighting)/i,2],
    [WEAPON_PROJECTILE, /^projectile\s*=\s*(.+)/i,1],

    [WeaponCausesFlight, /^fly\s*=\s*(true)/i, 2],
    [WalkOnWater_Weapons, /(^walk_on_water)/i, 2],
    [WEAPON_ANCHOR_DIR,  /^(anchor|origin)\s*=\s*(\d)/i]
  ]
  
#DATA_ARMORS Config
  ARMORS_EASY_CONFIG =[
    [EQUIP_Move_Info, /^move\s*=\s*(\-*\d+)/i],
    [Equip_Skill_Range, /^skill_range\s*=\s*(\[\s*\d+\s*,\s*\d+v,\s*\d+\s*(,\s*\d+\s*,\s*\d+\s*)?\])/i],
    [EquipCausesFlight, /^fly\s*=\s*(true)/i, 2],
    [WalkOnWater_Armors, /(^walk_on_water)/i, 2]
  ]
  
  #DATA_ENEMIES Config
   ENEMIES_EASY_CONFIG =[
     [Enemy_Move, /^move\s*=\s*(\d+)/i],
     [Game_Enemy::Enemy_Classes, /^class*\s*=\s*(.+)/i, 1],
     [Game_Enemy::Enemy_Levels, /^le*ve*l\s*=\s*(\d+)/i],
     [Game_Enemy::Enemy_State_Add, /^state_add\s*=\s*(\[\s*[\s*\d\s*,\s*]\s*\])/i],
     [En_large_units, /^large\s*=\s*(\d+)/i],     
     [Enemy_Weapon_Range, /^range\s*=\s*(\[\s*\d+\s*,\s*\d+\s*,\s*(true|false)\s*,\s*(true|false)\s*,\s*\d+\s*(,\s*\d+\s*,\s*\d+\s*)?\])/i],
     [Game_Enemy::Unknown_HP_MP, /(^unknown_hp)/i, 2],
     [Game_Enemy::Enemy_Face, /^face_name\s*=\s*(.+)/i, 1], 
     [Game_Enemy::Enemy_Face_Index,  /^face_index=(\d)/i],
     [Game_Enemy::EN_Descriptions, /^description\s*=\s*(.+)/i,1],
     [Game_Enemy::AI_Tactic, /^tactic\s*=\s*(.+)/i, 1],
     [Secret_Hunt_Results, /^hunt_results\s*=\s*(\[\s*(\[\s*\d+\s*,\s*\d+\s*,\s*\d+\s*],?)+\])/i ],
     [SUMMON_ENID, /(^summon)/i, 2],
     [CAPTURE_TO_ACTOR, /^actor\s*=\s*(\d+)/i],
     [DEATH_ANIMATION_ENEMY, /^death_anim\s*=\s*(\d+)/i ],
     [ENEMY_VIEW_RANGE, /^view\s*=\s*(\d+)/i],
     [En_Atk_Projectile, /^projectile\s*=\s*(.+)/i, 1],
     [PREVENT_EN_WANDER, /(^prevent_wander)/i, 2],
     [Enemy_Weapon, /^weapons\s*=\s*((\d+,?)+)/i,8],
     [EnemyTraverseType, /^traverse\s*=\s*(\d+)/i],
     [Cannot_Invite_Enemies, /(^no_invite)/i, 2],
     [EnemiesWhoFly, /^fly\s*=\s*(true)/i, 2],
     [EnemiesWithWalkOnWater, /(^walk_on_water)/i, 2],
     [Prevent_Enemy_Mini, /(^no_mini)/i, 2]
   ]
 
 #DATA_STATES Config  
  STATES_EASY_CONFIG = [
    [STATE_Move_Info, /^move\s*=\s*(\-*\d+)/i],
    [STATE_SKILL_RANGE, /^skill_range\s*=\s*(\[\s*\d+\s*,\s*\d+\s*,\s*\d+\s*(,\s*\d+\s*,\s*\d+\s*)?\])/i],
    [STATE_RATE_EFFECT={}, /^effect\s*=\s*(\-*\d+)/i],
    [KNOCK_BACK_STATES, /(^knockback)/i, 2],   #add to array for knock back skills  
    [STATE_PUSH_INFO, /^knock_move\s*=\s*(\-*\d+)/i],
    [STATE_VIEW_INFO, /^view\s*=\s*(\-*\d+)/i],
    [State_Modify_Tactic, /^tactic\s*=\s*(.+)/i,1],
    [StateCausesFlight, /^fly\s*=\s*(true)/i, 2],
    [WalkOnWater_States, /(^walk_on_water)/i, 2]
  ]
  
  ACTOR_EASY_CONFIG = [
    [CONTROLABLE_SUMMONS, /(^controllable)/i, 2],
    [ACTOR_SUMMONS, /(^summon)/i, 2 ],
    [SUMMON_INSTANCES_ALLOWED, /^allowed\s*=\s*(\d+)/i],
    [Act_large_units, /^large\s*=\s*(\d+)/i],
    [DOOM_SUMMON_TURN, /^doom_turn\s*=\s*(\d+)/i],
    [DEATH_ANIMATION_ACTOR, /^death_anim\s*=\s*(\d+)/i],
    [Actor_AI, /^tactic\s*=\s*(.+)/i,1],
    [PREVENT_ACT_WANDER, /(^prevent_wander)/i, 2],
    [ActorTraverseType, /^traverse\s*=\s*(\d+)/i],
    [Cannot_Invite_Actors, /(^no_invite)/i, 2],
    [Prevent_Actor_Leave_List ,/(^prevent_leave)/i,2],
    [Prevent_Actor_Mini, /(^no_mini)/i, 2]
  ]
  
  CLASS_EASY_CONFIG = [
    [CLASS_MOVE_RANGE, /^move\s*=\s*(\d+)/i],
    [CLASS_VIEW_RANGE, /^view\s*=\s*(\d+)/i]
  ]
  
  MAP_EASY_CONFIG = [
    [CALL_ALTERNATE_MAP, /^battle_on\s*=\s*(\d+)/i],
    [MAP_EXIT_INFO, /^exit_info\s*=\s*(\[\s*\d+\s*,\s*\d+\s*,\s*\d+\s*,\s*\d+\s*\])/i] ,
    [MAP_Region_Transfer, /^bat_region\s*(\d+)\s*=\s*(\d+)/i, 6],
    [Battleback_Region, /^backdrop\[\s*(\d+)\s*\]\s*=\s*(.+)/i,5],
    [BackDrop_MAP_Default, /^default_back\s*=\s*(.+)/i, 1],
    [Map_SideView_Music ,/^side_music\s*=\s*(.+)/i,1],
    [Map_SideView_Music_Vol,/^side_vol\s*=\s*(\d+)/i],
    [ACTOR_TURN_MUSIC,/^act_music\s*=\s*(.+)/i,1],
    [ENEMY_TURN_MUSIC,/^en_music\s*=\s*(.+)/i,1]
  ]
  
  TROOP_EASY_CONFIG = [
    [Extra_Troops, /^extra_enemies\s*=\s*(\[((\s*\d+\s*),?)+\])/i]
  ]
  
#============================================================================
#  You don't have to modify this
#============================================================================
#  End of Easy Config script
#  This will effectively load the settings for the game
#============================================================================
# the database parser
# type = name of the file
# all_config = one of the array define above
  def self.easy_config(type, all_config)
    data = load_data('Data/'+type+'.rvdata2')    
    max = data.size
    if type == 'MapInfos'
      max += 1
    end
    for i in 1...max
      if type == 'MapInfos'
        filename = sprintf("Data/Map%03d.rvdata2", i)
        if (File.exist?(filename) == false)
          next
        end
        note = load_data(filename).note
      else
        note = data[i].note
      end
      note.gsub!(/[ \t\r\f]/,"") 
      for line in note.split("\n")
        for config in all_config
          line_note = line.clone
          #unless config[3]
          #  
          #end
          line_note.scan(config[1])
          if $1
            case config[2]
            when 8 # hash int array push
              #config[0][i] = [] if (config[0][i]).nil?
              config[0][i] = eval("[" + $1 + "]") #push eval data
            when 7 # hash string array push (as array)
              #Start new array at hash key
              config[0][i] = [] if (config[0][i]).nil?
              config[0][i] << $1
            when 6 # Custom for Map battle transfers based off area
              temp = eval($1)
              config[0][i] ||= {}
              config[0][i][temp] = eval($2)
            when 5 # Custom for battlebacks
              temp = eval($1)
              config[0][i] ||= {}
              config[0][i][temp] = $2
            when 2 # add to array
              if !config[0].include?(i)
                config[0] << i
                config[0].sort!
              end
            when 1 # is a string
              config[0][i] = $1
            when 0 #is a switch parameters
              config[0][i] =  true 
            else#value parameter
              config[0][i] =  eval($1)
            end
            break
          end
        end
      end
    end
  end
  
  START_ACTION_TAG   = /^<ACTION_LIST>/i
  END_ACTION_TAG     = /^<\/ACTION_LIST>/i
  
  SCAN_ACTION_TAG    = /^\s*([A-Z]*)\s*([A-Z]*):\s*(.+)/i
  SCAN_ACTION_FOLLOW = /[^, ]+[^,]*/i
  SCAN_ACTION_SMALL  = /^\s([A-Z]*)\s*:\s*(.+)/i
  
  def self.action_config(type)
    data = load_data('Data/'+type+'.rvdata2')    
    max = data.size
    @defining_action_tag = false
    
    #this = eval("GTBS::ACTION_#{type.upcase}")
    
    for i in 1...max
      note = data[i].note
      note.gsub!(/[\t\r\f]/,"") 
      eval("GTBS::ACTION_#{type.upcase}")[i] = []
      for line in note.split("\n")
        case line
        when START_ACTION_TAG
          @defining_action_tag = true
        when END_ACTION_TAG
          @defining_action_tag = false
        else
          next unless @defining_action_tag
          case line
          when SCAN_ACTION_TAG
            action = $1
            source = $2
            params = $3.scan(SCAN_ACTION_FOLLOW)
            eval("GTBS::ACTION_#{type.upcase}")[i] << [action, source, params]
          when SCAN_ACTION_SMALL
            action = $1
            type = $2
            eval("GTBS::ACTION_#{type.upcase}")[i] << [action, type, []]
          end
        end
      end
      
      #if this[i] != []
      #  for entry in this[i]
      #    p entry
      #  end      
      #end
    end
  end
  
  self.action_config("Skills")
  self.action_config("Items")
  self.action_config("Weapons")
  
  self.easy_config('Skills', SKILLS_EASY_CONFIG)
  self.easy_config('Items', ITEMS_EASY_CONFIG)
  self.easy_config('Weapons', WEAPONS_EASY_CONFIG)
  self.easy_config('Armors', ARMORS_EASY_CONFIG)
  self.easy_config('Enemies', ENEMIES_EASY_CONFIG)
  self.easy_config('States', STATES_EASY_CONFIG)
  self.easy_config('Actors', ACTOR_EASY_CONFIG)
  self.easy_config('Classes', CLASS_EASY_CONFIG)
  self.easy_config('MapInfos', MAP_EASY_CONFIG)
  self.easy_config('Troops', TROOP_EASY_CONFIG)
  
  def self.text_reg_exp(exp)
    
    note = "move user: target feet, time 10"##"w_range=[2, 0, true, false, 0]"#
    note.match(exp)
    #p mtc.size
    #p "Match#0 #{mtc[0]}, Match #1 (#{mtc[1]}), Match #2 (#{mtc[2]}), Match #3 (#{mtc[3]})"
    if $1
      p $1, $2, $3
      p $3.scan(SCAN_ACTION_FOLLOW)
    else
      p "no match"
    end
  end
  exp = SCAN_ACTION_TAG#/^w_range[ ]*=[ ]*(\[[ ]*[\d+,]{3}(true|false)\s*,\s*(true|false)\s*,\s*\d+\s*(,\s*\d+\s*,\s*\d+\s*)?\])/
  #new_exp = /[ ]*(.*):[ ]*(.*)/i
  #text_reg_exp(exp)
  
  #print the desired variable here to validate what was read from the db notes
  #in regards to it
  #p BackDrop_MAP_Default
  #p Enemy_Weapon_Range
end


#move user: target
#move: source, abs X Y,
#move:
#  source - whom to move
#  target *- optional relative target
#    feet/base - base of the target
#    mid - middle of the target
#    head/top - top of the target
#  abs X Y - absolute value x,y location (if !target)
#  dir *
#   numpad_direction(1-9)

#create: user hand, icon weapon
#
#create:
#  source * -optional relative target
#    hand
#    hand2
#    center - default
#    left/right/up/down value (offset from CENTER of source)
#
#  abs X Y
#    
#  icon *
#    weapon1
#    weapon2 (if not available weapon1 will be used)
#    item ID
#    skill ID
#    weapon ID - Weapon not attached to the user
#    filename.ext
#
#  angle 45 *
#    <> - Mirror when facing right
#    Directional parameters only applicable to target source of battler type
#
#  origin *
#    numpad direction (1-9)
#    Origin will be reversed at the time of mirror if using <> on an angle. 
#    Any angle not specified with a <> when facing other than LEFT will result in 
#    the angle being modified to that given direction.
#
#  image filename
#    filename should be relative to project root: ./graphics/pictures/filename.png
#
#    
#
#delete: user, key KEYNAME
#  key KEYNAME - required for all transactions
#  user (not required unless icon/picture was delcared with relative source target
#
#screen: flash R G B, time 5
#screen: *
#  flash R G B - R G B are interger values betwee 0 and 255
#  shake intensity
#  time VALUE
#
#animation: id, wait
