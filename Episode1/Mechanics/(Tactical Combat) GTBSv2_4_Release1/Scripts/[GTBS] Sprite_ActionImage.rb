class Sprite_ActionImage < Sprite
  attr_accessor :actual_x, :actual_y, :offset_x, :offset_y
  def initialize
    @instruction_queue = []
    @repeats = {}
    @cur_inst = nil
    @actual_x = 0;
    @actual_y = 0;
    @offset_x = 0;
    @offset_y = 0;
    @ready_delete = false
    super()
  end

  def [](key)
    return @cur_inst[key] if @cur_inst != nil
    return nil
  end
  
  def []=(key, value)
    if @cur_inst != nil
      @cur_inst[key] = value
    end
  end
  
  def can_delete?
    if (in_action? == false && @ready_delete)
      self.dispose
      return true
    end
    return false
  end
  
  def add_action(inst)
    if (inst[:create] && inst[:time] > 1)
      inst[:time] = 1
    end
    if (inst[:delete])
      @ready_delete = true
      return
    end
    @instruction_queue << inst
    if (inst[:repeat] > 0)
      @repeats[inst] = @repeats[:time] #save time for restore after completion
    end
  end
  
  def in_action?
    for inst in @instruction_queue
      next if (inst[:repeat] > 0)
      return true
    end
    return false
  end
  
  def update
    rem_instructions = []
    for inst in @instruction_queue
      if (execute(inst))
        rem_instructions << inst
      end
    end
    @instruction_queue -= rem_instructions
    super
  end

  def execute(instruction)
    @cur_inst = instruction
    
    off_x, off_y      = get_offset_data
    ico_idx, filename = get_filename_data 
    rot_amt           = get_rotation_amount
    opa_value         = get_opacity_data
    
    #Now lets process the gathered filename data
    if (ico_idx != nil)
      self.bitmap = Cache.system("Iconset")
      self.src_rect.set(ico_idx % 16 * 24, ico_idx / 16 * 24, 24, 24)
    elsif (filename != nil)
      self.bitmap = Cache.picture(filename)
      self.mirror = self[:mirror]
      
      #If image, then apply col/row data supplied
      col_size = self.bitmap.width/self[:col_count]
      row_size = self.bitmap.height/self[:row_count]
      img_x = self[:col] % self[:col_count] * col_size
      img_y = self[:row] / self[:row_count] * row_size
      self.src_rect.set(img_x, img_y, col_size, row_size)
    end
    
    # OX, OY/Step data is gathered after the bitmap usage since we need to know the 
    # dimensions of the bitmap before this can be applied (in most cases)
    apply_oxoy_data
    img_angle         = get_angle_data
    x_step, y_step    = get_position_step_data
    
    #Now lets apply the remaining gathered data
    apply_position_data(x_step, y_step, off_x, off_y)
    apply_angle_data(img_angle, rot_amt)
    apply_opacity_data(opa_value)
    apply_zoom_data
    
    self.z = self[:z] #apply Z value of params (Defaults to 2000)
    
    self[:time] -= 1
    if (self[:time] == 0)
      if (self[:repeat] > 0)
        self[:repeat] -= 1
        self[:time] = @repeats[@cur_inst]
        @cur_inst = nil
        return false
      end
      @cur_inst = nil
      return true #this instruction is complete and should be deleted
    else
      @cur_inst = nil
      return false
    end
  end
  
  def apply_opacity_data(opa_value)
    self.opacity += opa_value if (opa_value != nil)
  end
  
  def apply_angle_data(ang, rot)
    self.angle += ang if (ang != nil)
    self.angle += rot if (rot != nil)
  end
  
  def apply_position_data(xstep, ystep, offx, offy)
    if (xstep != nil)
      self.actual_x += xstep
      self.actual_y += ystep
    end
    if (offx != nil)
      self.offset_x += offx
      self.offset_y += offy
    end
    self.x = self.actual_x + self.offset_x
    self.y = self.actual_y + self.offset_y
  end
  
  def apply_oxoy_data
    o_x, o_y = nil, nil
    if (self[:center] != nil)
      o_x, o_y = 0, 0
      if (self[:center].is_a?(Symbol)) #is hard coded symbol (LL, UL, UR, LR)
        #get y  offset
        if ([:LL, :LR].include?(self[:center]))
          o_y = self.src_rect.height
        end
        #get x offset
        if ([:UR, :LR].include?(self[:center]))
          o_x = self.src_rect.width
        end
        
        ind = weapon_index(self[:center])
        if ind != nil && self[:container] != nil
          if (self[:container].actor?) 
            weps = self[:container].weapons
            if (weps.size > ind)
              self[:center] = GTBS::AnchorDirForWep(weps[ind].id)
            end
          else #enemy
            if (GTBS::Enemy_Weapon.keys.include?(self[:container].enemy_id))
              wepArray = GTBS::Enemy_Weapon[self[:container].enemy_id]
              if (wepArray != nil && wepArray.size > index)
                self[:center] = GTBS::AnchorDirForWep($data_weapons[wepArray[index]].id)
              end
            end
          end
        end
      elsif (self[:center].is_a?(POS))
        #simply report coords if supplied
        o_x, o_y = self[:center].x, self[:center].y
      end
      if (self[:center].is_a?(Numeric)) #is keypad direction (this will likely be the most common)
        #mirror if haven't already done so...
        
        #get y offset coords
        if ([1,2,3].include?(self[:center]))
          o_y = self.src_rect.height
        elsif ([4,5,6].include?(self[:center]))
          o_y = self.src_rect.height/2
        end
        #get x offset coords
        if ([8,5,2].include?(self[:center]))
          o_x = self.src_rect.width/2
        elsif ([9,6,3].include?(self[:center]))
          o_x = self.src_rect.width
        end
      end
      
    end
    if (o_x != nil &&  o_y != nil)
      self.ox = o_x
      self.oy = o_y
    end
  end

  def get_offset_data
    off_x, off_y = nil,nil
    if self[:offset_list].size > 0
      off_x, off_y = 0, 0
      for offset in self[:offset_list]
        case offset[0]
        when :left
          off_x = 0 if off_x.nil? 
          off_x -= offset[1]
        when :right
          off_x = 0 if off_x.nil? 
          off_x += offset[1]
        when :up
          off_y = 0 if off_y.nil? 
          off_y -= offset[1]
        when :down
          off_y = 0 if off_y.nil? 
          off_y += offset[1]
        end
      end
      
      #Now get taget position offset and deduct current to calculate distance
      x_dist = off_x - self.offset_x 
      y_dist = off_y - self.offset_y
      #convert to fraction so smaller portions are not lost
      return x_dist/self[:time].to_f, y_dist/self[:time].to_f
    end
    return off_x, off_y
  end
  
  def get_opacity_data
    opa_value = nil
    if (self[:opacity] != nil)
      if (self.opacity != self[:opacity])
        opa_value = (self[:opacity].to_f - self.opacity)/self[:time]
      end
    end
    return opa_value
  end
  
  def apply_zoom_data
    z_x, z_y = nil, nil
    if self[:zoom_x] != nil
      if (self.zoom_x != self[:zoom_x])
        self.zoom_x += (self[:zoom_x]-self.zoom_x)/self[:time]
      end
    end
    if self[:zoom_y] != nil
      if (self.zoom_y != self[:zoom_y])
        self.zoom_y += (self[:zoom_y]-self.zoom_y)/self[:time]
      end
    end
  end
  
  def get_angle_data
    angle = nil;
    if (self[:angle] != nil)
      #Only report if angle is different than current
      if (self.angle != self[:angle] || self[:angle_adjusted].nil? || self[:mirror_a])
        
        #Get angle difference and divide by time for angle change amount for this frame
        sprite = SceneManager.scene.get_battler_sprite(self[:container])
        
        #Perform mirroring of the image as neccessary
        if self.mirror != self[:mirror_a] && sprite.get_direction == 6
          self.mirror = self[:mirror_a]
          self.ox = self.src_rect.width - self.ox
          #Only X axis is ever mirrored.  No need to modify OY value
        end
        
        if (self[:mirror_a] && sprite.get_direction == 6) #reverse angle
          angle = (-self[:angle] - self.angle)/self[:time] #for now lets just return regular
        else
          #rotate angle normally based on given direction
          if self[:angle_adjusted].nil?
            case sprite.get_direction
            when 2 #looking down
              self[:angle] += 90
            #when 4 #looking left  #no need to fall through the case statement when it doesnt do anything
            #  self[:angle] += 0
            when 6 #looking right
              self[:angle] += 180
            when 8 #looking up
              self[:angle] += 270
            end
            self[:angle_adjusted] = true;
          end
          angle = (self[:angle] - self.angle)/self[:time]
        end
      end
    end
    return angle
  end
  
  def weapon_index(sym)
    case sym
    when :weapon1
      return 0
    when :weapon2
      return 1
    when :weapon3
      return 2
    when :weapon4
      return 3
    end
    return nil
  end
  
  def get_filename_data
    if (self[:filename] != nil)
      if (weapon_index(self[:filename]) != nil && self[:container] != nil)
        index = weapon_index(self[:filename])
        
        if self[:container].actor? 
          if (self[:container].weapons.size > index)
            weapon = self[:container].weapons[index]
            ico_idx = weapon.icon_index
            if (self[:weapon_action] != nil)
              weapon.deliver_action(make_sub_instruction(@cur_inst))
            end
          end
          
        #determine weapon being used by enemy
        else 
          if (GTBS::Enemy_Weapon.keys.include?(self[:container].enemy_id))
            wepArray = GTBS::Enemy_Weapon[self[:container].enemy_id]
            if (wepArray != nil && wepArray.size > index)
              weapon = $data_weapons[wepArray[index]]
              ico_idx = weapon.icon_index
              if (self[:weapon_action] != nil)
                weapon.deliver_action(make_sub_instruction(@cur_inst))
              end
            end
          end
        end
      else
        #If is icon and filename is numeric, use it as index.  Otherwise, fetch 
        #icon/image file to be used.
        if (self[:filename].is_a?(Numeric) && self[:is_icon])
          ico_idx = self[:filename]
        else
          filename = self[:filename].to_s #Ensure object is string for comparison
        end
      end
    end
    return ico_idx, filename
  end
  
  def make_sub_instruction(parent_instruction)
    imp = SceneManager.scene.get_default_image_paramters
    imp[:container] = parent_instruction[:container]
    imp[:key] = parent_instruction[:key]
    return imp
  end

  def get_position_step_data
    if (self[:pos] != nil)
      x_dist = self[:pos].x - self.actual_x
      y_dist = self[:pos].y - self.actual_y
    
    #else proceed with checking container queues
    elsif (self[:container] != nil)
      
      sprite = SceneManager.scene.get_battler_sprite(self[:container])
      if (sprite != nil)
        tx = sprite.x 
        ty = sprite.y - self.src_rect.height/2
        
        
        case sprite.get_direction
        when 6
          tx -= self.src_rect.width/2
        when 4 
          tx += self.src_rect.width/2
        when 2
          ty -= self.src_rect.height/2
        end
      end
      if (tx != nil or ty != nil)
        x_dist = tx-self.actual_x
        y_dist = ty-self.actual_y
      end
    end
    
    if (x_dist != 0 || y_dist != 0)
      #A move is required.  Using time to calculate the step size
      x_step = x_dist / self[:time]
      y_step = y_dist / self[:time]
    end
    
    if x_step != nil || y_step != nil
      return x_step, y_step
    end
  end
  
  def get_rotation_amount
    rot_amt = nil
    if(self[:rotate] != nil)
      if (self[:rotate] != 0)
        #Get rotational amount for this update and
        #convert to fraction since every little bit counts here
        rot_amt = self[:rotate].to_f / self[:time]        
      end
    end
    return rot_amt
  end

end

module RPG
  class Weapon
    def deliver_action(base_instructions)
      #Time to read the instructions from the weapon object and apply those to 
      #the handed in instruction object. 
      
      #Since all this will be read by the GTBS module during startup.  We will 
      #simply rely on that to provide the data needed for these 'sub actions'
      
      #This needs to be cloned as edits would affect future calls
      #p "all actions", GTBS::ACTION_WEAPONS
      a_list = GTBS::ACTION_WEAPONS[self.id].clone 
      if (a_list == nil || a_list == [])
        a_list = [
        ["create", "icon", ["angle 0<>", "center 3"]], 
        ["wait", "", ["16"]],
        ["move", "icon", ["angle 90<>", "time 16"]], 
        ["move", "icon", ["user", "forward 16", "time 6"]], 
        ["wait", "", ["32"]], ["delete", "icon", ["."]]
        ]
      end
      ins_processed = 1
      
      while a_list != []
        act = a_list.shift
        imp = SceneManager.scene.setup_image_movement(act[2])
        
        case act[0]
        when /^(create)/i
          imp[:create] = true
          
        when /^(delete)/i
          imp[:delete] = true
          
        # Forward MOVE | WAIT | SCREEN commands to the scene to handle
        when /^(move)/i
          case act[1]
          when /^(user|self|target|enemy)/i
            SceneManager.scene.action_movement(act)
            next #skip 'image movement insert'
          end
        when /^(wait)/i
          SceneManager.scene.action_wait(act)
        when /^(screen)/i
          SceneManager.scene.action_screen(act)
        when /^(damage|dmg)/i
          #ignore dmg for now
          #SceneManager.scene.action_damage(
        when /^cleanup/i
          SceneManager.scene.action_cleanup
        end
        
        ins_processed += 1
        if (imp[:filename] == nil && imp[:key] == nil)
          imp[:key] = base_instructions[:key]
          imp[:filename] = base_instructions[:filename]
          imp[:is_icon] = true
          imp[:container] = base_instructions[:container]
        end
        SceneManager.scene.process_image_move_params(imp)
      end
    end
  end
end
