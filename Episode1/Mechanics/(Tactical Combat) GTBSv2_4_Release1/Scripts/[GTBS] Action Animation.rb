class Move_Action
  attr_accessor :xy
  attr_accessor :targets
  attr_accessor :position
  attr_accessor :time
  attr_accessor :offset_list
  attr_accessor :reset
  attr_accessor :jump_peak
  attr_accessor :jump_count
  def initialize
    @xy = nil #will be replaced with absolute value xy coordinates in POS class
    @targets = nil #will be replaced with array of targets (even if only 1)
    @position = :body #valid (:body, :head, :feet)
    @time = 10 #default time in which this action will take to be carried out
    @offset_list = [] #Offset list, will be used to comprise x,y relative offeset
    @reset = false #user should return to location
    @jump_peak = 0;
  end
  def jump(height)
    @jump_peak = 10 + height
  end
end

class Scene_Battle_TBS
  #-------------------------------------------------------------------------
  # Should Wait - returns if the action system should wait before calling the
  # next command or not.
  #-------------------------------------------------------------------------
  def should_wait?
    return true if ((@wait_count-=1) > 0)
    return true if @movement_wait
    return true if @animation_wait
    return true if @effect_wait
    return false
  end
  #-------------------------------------------------------------------------
  def action_movement(act)
    params = act[2]
    case act[1]
    #when /^icon/i
    #  setup_icon_movement(params)
    when /^(user|self)/
      setup_user_movement(params)
    when /^(target|enemy)/
      setup_target_movement(params)
    when /^(picture|pic|image|img|icon|ico)/
      img_params = setup_image_movement(params)
      process_image_move_params(img_params)
    end
  end
  #-------------------------------------------------------------------------
  def update_movement_optional_params(ma, optional)
    case optional
    when /^(feet|base)/i
      ma.position = :feet
    when /^(head|top)/i
      ma.position = :head
    when /^(middle|body)/i
      ma.position = :body
    end    
  end
  #-------------------------------------------------------------------------
  def setup_user_movement(params)
    @active_battler.move_actions << create_movement_action(params, "user")
  end
  #-------------------------------------------------------------------------
  def setup_target_movement(params)
    ma = create_movement_action(params, "target")
    for target in @action_targets
      target.move_actions << ma.clone
    end
  end
  #-------------------------------------------------------------------------
  def create_movement_action(params, type)
    ma = Move_Action.new
    for param in params
      case (param)
      when /^(target|enemy)\s*(.+)*+/i
        if type == "target"
          ma.targets = [@active_battler]
        else
          ma.targets = [@action_targets[0]]
        end
        
        optional = $2.clone #clone so it is not destroyed
        update_movement_optional_params(ma, optional)
        
      when /^(absolute|abs|xy)\s*(\d+)\s*(\d+)/i
        ma.xy = POS.new($1.to_i,$2.to_i)
        
      when /^(t|time|duration|dur)\s*(\d+)/i
        ma.time = $2.to_i
        
      when /^(right|left|up|down)\s*(\d+)/i
        ma.offset_list << [$1.downcase.to_sym, $2.to_i]
        
      when /^(return)/i
        ma.reset = true
        
      when /^(wait|halt|complete)/i
        action_wait( [nil, nil, ["movement"]] )
      
      when /^(away|back|backword[s]*)\s*(\d+)/i
        who = type == "target" ? @action_targets[0] : @active_battler
        sprite = get_battler_sprite(who)
        #reverse direction from sprite
        sym = get_sym_from_dir( who.reverse_dir(sprite.get_direction) )
        ma.offset_list << [sym, $2.to_i]
        
      when /^(forward|approach|toward[s]*)\s*(\d+)/i
        who = type == "target" ? @action_targets[0] : @active_battler
        sprite = get_battler_sprite(who)
        sym = get_sym_from_dir(sprite.get_direction)
        ma.offset_list << [sym, $2.to_i]
        
      when /^(jump)\s*(\d+)/i
        ma.jump($2.to_i)
      end
    end
    return ma
  end
  #-------------------------------------------------------------------------
  def get_sym_from_dir(dir)
    if [1,2,3].include?(dir)
      return :down
    elsif dir == 4
      return :left
    elsif dir == 6
      return :right
    else 
      return :up
    end
  end
  #-------------------------------------------------------------------------
  def get_direction_sym(user, target, reverse = false)
    sx, sy = user.x - target.x, user.y-target.y
    dir = 4
    if sx.abs > sy.abs
      dir = sx > 0 ? 4 : 6
    elsif sy != 0
      dir = (sy > 0 ? 8 : 2)
    end
    if reverse
      user.reverse_dir(sym)
    end
    sym = get_sym_from_dir(dir)
    return sym
  end
  #-------------------------------------------------------------------------
  def setup_image_movement(params)
    img_params = get_default_image_paramters()
    for param in params
      img_params = build_image_movement_params(param, img_params) 
    end
    return img_params
  end
  #-------------------------------------------------------------------------
  def build_image_movement_params(param, img_params)
    case param
    when /^(index|idx)\s*(\d+)/i
      img_params[:filename] = $2.to_i
    when /^(file|filename|src|source)\s*(.+)/i
      img_params[:filename] = $2
    when /^(abs|absolute|xy|pos)\s*(\d+)\s*(\d+)/i
      img_params[:pos] = POS.new($2.to_i, $3.to_i)
    when /^(z)\s*(\d+)/i
      img_params[:z] = $2.to_i
    when /^(angle)\s*(\d+)/i
      img_params[:angle] = $2.to_i
      case param #inner casing to determine if mirror is needed
      when /(<>)/ 
        img_params[:mirror_a] = true
      end
    when /^(zoom|scale)\s*(x|y)\s*(\d+)/i
      key = ("zoom_" + $2.to_s).to_sym
      img_params[key] = $3.to_i/100.to_f
    when /^(rotate)\s*([-]*\d+)/i
      img_params[:rotate] = $2.to_i
    when/^(mirror|flip)\s*(true|false)/i
      img_params[:mirror] = eval($2)
    when /^(origin|center|cnt)( at)?\s*(\d+)\s*(\d+)/i
      img_params[:center] = POS.new($2.to_i, $3.to_i)
    when /^(origin|center|cnt)\s*(\d)/i
      img_params[:center] = $2.to_i #if only 1 supplied, use value as direction
    when /^(origin|center|cnt)\s*(LR|LL|UR|UL)/i
      img_params[:center] = $2.to_sym
    when /^(key|tag)\s*(.+)/i
      img_params[:key] = $2.to_sym
    when /^(user|self)/i
      img_params[:container] = @active_battler
      case param
      when /(hand1|arm1|right)$/i
        img_params[:key] = :right
        img_params[:filename] = :weapon1
        img_params[:center] = :weapon1
      when /(hand2|arm2|left)$/i
        img_params[:key] = :left
        img_params[:filename] = :weapon2
        img_params[:center] = :weapon2
      when /(head|top)$/i
        img_params[:key] = :top
      when /(feet|bottom)$/i
        img_params[:key] = :bottom
      end
    when /^(target|enemy)/i
      img_params[:container] = @action_targets[0]
      case param
      when /(hand1|arm1|right)$/i
        img_params[:key] = :right
        img_params[:filename] = :weapon1
        img_params[:center] = :weapon1
      when /(hand2|arm2|left)$/i
        img_params[:key] = :left
        img_params[:filename] = :weapon2
        img_params[:center] = :weapon2
      when /(head|top)$/i
        img_params[:key] = :top
      when /(feet|bottom)$/i
        img_params[:key] = :bottom
      end
    when /^(t|time|duration|dur)\s*(\d+)/i
      img_params[:time] = $2.to_i
      if (img_params[:time] < 1)
        msgbox "An action time must be 1 or greater\n"
        exit_battle
      end
    when /^(wep|weapon) (\d)/i
      sym = ("weapon"+$2.to_s).to_sym
      img_params[:filename] = sym
      img_params[:center] = sym
    when /^(opacity|op)\*(\d+)/i
      img_params[:opacity] = $2.to_i
    when /^(attack|strike|hit|fire)/i
      img_params[:weapon_action] = :strike
    when /^(forward|approach|toward[s]*)\s*(\d+)/i
      if (img_params[:container] != nil)
        who = img_params[:container]
        sprite = get_battler_sprite(who)
        sym = get_sym_from_dir(sprite.get_direction)
        img_params[:offset_list] << [sym, $2.to_i]
      end
    when /^(away|back|backword[s]*)\s*(\d+)/i
      if (img_params[:container] != nil)
        who = img_params[:container]
        sprite = get_battler_sprite(who)
        #reverse direction from sprite
        sym = get_sym_from_dir( who.reverse_dir(sprite.get_direction) )
        img_params[:offset_list] << [sym, $2.to_i]
      end
    end 
    return img_params
  end
  #-------------------------------------------------------------------------
  def get_default_image_paramters
    img_move_params = {}
    img_move_params[:create] = false
    img_move_params[:pos] = nil
    img_move_params[:filename] = nil
    img_move_params[:offset_list] = []
    img_move_params[:mirror] = false
    img_move_params[:key] = nil
    img_move_params[:container] = nil
    img_move_params[:col_count] = 1
    img_move_params[:row_count] = 1
    img_move_params[:row] = 0
    img_move_params[:col] = 0
    img_move_params[:time] = 10
    img_move_params[:repeat] = 0
    img_move_params[:angle] = nil
    img_move_params[:rotate] = nil
    img_move_params[:mirror_a] = false
    img_move_params[:mirrored] = false
    img_move_params[:opacity] = nil
    img_move_params[:zoom_x] = nil
    img_move_params[:zoom_y] = nil
    img_move_params[:is_icon] = false
    img_move_params[:center] = nil
    img_move_params[:weapon_action] = nil
    img_move_params[:z] = 2000
    return img_move_params
  end
  #-------------------------------------------------------------------------
  def process_image_move_params(imp)
    @spriteset.add_image_instruction(imp)
  end
  #-------------------------------------------------------------------------
  #def setup_icon_movement(params)
  #  imp = setup_image_movement(act[2])
  #  imp[:is_icon] = true
  #  process_image_move_params(imp)
  #end
  #-------------------------------------------------------------------------
  def action_create(act)
    imp = setup_image_movement(act[2])
    imp[:create] = true
    case act[1]
    when /^(icon|ico)/i
      imp[:is_icon] = true
    #else is assumed image
    end
    process_image_move_params(imp)
  end
  
  #-------------------------------------------------------------------------
  def action_damage(act, spell)
    case act[1]
    when /^(target|enemy)/i
      for target in @action_targets
        deal_dmg(target, @active_battler, spell)
      end
    when /^(user|self)/i
      deal_dmg(@active_battler, @action_targets[0], spell)
    end
  end
  #-------------------------------------------------------------------------
  def action_screen(act)
    return if act[1] == nil
    params = process_screen_params(act[2])
    case act[1]
    when /^(shake)/i      
      $game_map.screen.start_shake(params[:power], params[:speed], params[:duration])
    when /^(flash)/i
      $game_map.screen.start_flash(params[:rgb], params[:duration])
    when /^(tint)/i
      $game_map.screen.start_tone_change(params[:tone], params[:duration])
    when /^(zoom)\s*([-]?\d+)/i
      #Sets the zoom level (when in layy meta)
    when /^(angle)\s*([-]?\d+)/i
      #Sets the angle data (when in layy meta)
    when /^(save)/i 
      #saves the angle zoom data (when in layy meta)
    when /^(restore)/i
      #restores the angle zoom data (when in layy meta)
      #BLARG!
    end
  end
  #-------------------------------------------------------------------------
  def process_screen_params(params)
    retVal = {}
    retVal[:power] = 1
    retVal[:duration] = 1
    retVal[:speed] = 1
    retVal[:rgb] = Color.new(0,0,0,255)
    retVal[:tone] = nil
    for param in params
      case param
      when /^(power|pwr)\s*(\d+)/i
        retVal[:power] = $2.to_i
      when /^(duration|dur|time)\s*(\d+)/i
        retVal[:duration] = $2.to_i
      when /^(speed|spd)\s*(\d+)/i
        retVal[:speed] = $2.to_i
      when /^(rgb|color)\s*(\d+)\s*(\d+)\s*(\d+)/i
        retVal[:rgb] = Color.new($2.to_i, $3.to_i, $4.to_i, retVal[:rgb].opacity)
      when /^(opacity|opaque)\s*(\d+)/i
        retVal[:rgb].opacity = $2.to_i
      when /^(tone)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)/i
        retVal[:tone] = Tone.new($2.to_i, $3.to_i, $4.to_i, $5.to_i)
      end
    end
    retVal
  end
  #-------------------------------------------------------------------------
  def action_delete(act)
    imp = setup_image_movement(act[2])
    imp[:delete] = true
    case act[1]
    when /^(icon|ico)/i #it is assumed an image unless icon is specified
      imp[:is_icon] = true
    end
    process_image_move_params(imp)
  end
  #-------------------------------------------------------------------------
  def action_animation(act, skill)
    anims = []
    for param in act[2]
      case param
      when /^([-]?\d+)/
        anims = [$1.to_i]
      when /^(skill)/i
        anims = skill.animation_id
      when /^(wait|halt|complete)/i
        action_wait( [nil, nil, ["animation"]] )
        next
      when /^(pose)\s*(\d)/i #pose by id
        pose_id = $2.to_i - 1 #minus one to be the actual index of the pose
        battler = nil
        case act[1]
        when /^(target|enemy)/i
          battler = @action_targets[0]
        when /^(self|user)/i
          battler = @active_battler
        end
        if battler != nil
          battler.set_pose(pose_id)
        end
      when /^(pose)\s*(.+)/i #pose by name
        pose_name = $2
        battler = nil
        case act[1]
        when /^(target|enemy)/i
          battler = @action_targets[0]
        when /^(self|user)/i
          battler = @active_battler
        end
        if battler != nil
          battler.set_pose(pose_name)
        end
      when /^(weapon|wep)(\d) (\d+)/i
        wep_index = $2.to_i - 1
        anim_id = $3.to_i
        battler = nil
        case act[1]
        when /^(target|enemy)/i
          battler = @action_targets[0]
        when /^(self|user)/i
          battler = @active_battler
        end
        action_weapon_animation(battler, wep_index, anim_id) if battler != nil
        return 
      when /^(weapon|wep)(\d)/i
        wep_index = $2.to_i - 1
        battler = nil
        case act[1]
        when /^(target|enemy)/i
          battler = @action_targets[0]
        when /^(self|user)/i
          battler = @active_battler
        end
        if (battler != nil)
          anim_id = battler.instance_eval("self.atk_animation_id#{wep_index + 1}")
          action_weapon_animation(battler, wep_index, anim_id)
        end
        return 
      end

      case act[1]
      when /^(target|enemy)/i
        if (anims == -1)
          anims = []
          anims << @active_battler.atk_animation_id1
          anims << @active_battler.atk_animation_id2
        end
        
        for target in @action_targets #this should probably be changed to singular
          sprite = get_battler_sprite(target)
          sprite.append_anim_queue(anims)
        end
      when /^(self|user)/i
        if (anims == -1)
          anims = []
          anims << @action_targets[0].atk_animation_id1
          anims << @action_targets[0].atk_animation_id2
        end
        
        sprite = get_battler_sprite(@active_battler)
        sprite.append_anim_queue(anims)
      end
    end
  end
  #-------------------------------------------------------------------------
  def action_message(act, spell)
    case (act[2])
    when /^(show|appear)\s*(.+)/i
      $game_message.add($2.to_s)
    when /^(show|appear)/i
      @windows[Win_Help].set_text(spell.name) if spell != nil
    when /^(hide|destroy)/i
      @windows[Win_Help].hide
    end
  end 
  def action_movie(act)
    Graphics.play_movie("Movies/"+act[2].to_s) if act[2] != nil
  end
  #-------------------------------------------------------------------------
  def action_wait(act)
    case act[2][0]
    when /^(animation|anim)/i
      @animation_wait = true
    when /^(movement|move)/i
      @movement_wait = true
    when /^(effect)/i
      @effect_wait = true
    when /^(\d+)/i #appears to be a number
      @wait_count = $1.to_i
    end
  end
      
  #-------------------------------------------------------------------------
  # Get Action Anime Data
  #-------------------------------------------------------------------------
  def get_action_anime_data(spell, battler)
    data = GTBS.get_anime_animation_data(spell.id).clone
    
    #get primary animations
    anim = []
    id = spell.animation_id
    if id == -1
      anim << battler.atk_animation_id1
      anim << battler.atk_animation_id2
    else
      anim << id
    end
    # Replaces regular animation data if special is assigned. 
    #anim = anim_dat if anim_dat != nil 
    return data, anim
  end
  
  def action_weapon_animation(battler, wep_index, animation_id)
    battler.make_weapon_animation(wep_index)
  end
end