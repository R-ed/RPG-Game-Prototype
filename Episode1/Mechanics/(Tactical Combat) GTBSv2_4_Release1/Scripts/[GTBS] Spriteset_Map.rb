class Spriteset_Map
  attr_accessor :viewport1
  attr_reader   :viewport2
  attr_reader   :cursor_range
  attr_reader   :cursor
  attr_reader   :map
  attr_reader   :tile_sprites
  attr_reader   :actor_sprites
  attr_reader   :enemy_sprites
  attr_reader   :event_sprites
  alias init_spr_map_gtbs initialize
  def initialize(*args)
    init_spr_map_gtbs(*args)
    if $game_party.in_battle
      create_cursor
      create_tile_sprites
      create_projectiles
      create_events
      create_actors
      create_enemies
      create_image_queues
    end
  end
  def create_image_queues
    @image_containers = {}
    @global_images = {}
    @image_instructions = []
  end
  def add_image_instruction(img_move_params)
    @image_instructions << img_move_params
  end
    
  alias spr_map_gtbs_cr_characters create_characters
  def create_characters
    if !$game_party.in_battle
      spr_map_gtbs_cr_characters
    else
      @character_sprites = [] # return no characters
      @map_id = $game_map.map_id
    end
  end
  def create_cursor
    @cursor = Battle_Cursor.new(@viewport1)
    @cursor.visible = false
  end
  def create_tile_sprites
    @tile_sprites = []
  end
  def create_projectiles
    @projectiles = []
  end
  def create_events
    @event_sprites = {}
    for event in $game_map.gtbs_events
      @event_sprites[event] = Sprite_Character_GTBS.new(@viewport1, event)
    end
  end
  def create_actors
    @actor_sprites = {} 
    for actor in $game_party.existing_members + $game_party.neutrals
      @actor_sprites[actor] = Sprite_Battler_GTBS.new(@viewport1,actor)
    end
  end
  def create_enemies
    @enemy_sprites = {}
    for enemy in $game_troop.existing_members
      #next if enemy.hidden?
      @enemy_sprites[enemy] = Sprite_Battler_GTBS.new(@viewport1, enemy)
    end
  end
  alias upd_spr_map_gtbs update
  def update
    upd_spr_map_gtbs
    if $game_party.in_battle
      if !in_mini?
        update_actors_sprites 
        update_enemy_sprites
      end
      update_event_sprites
      update_cursor
      update_tile_sprites
      update_projectiles
      update_image_queues
    end
  end
  def update_tile_sprites
    return if @tile_sprites.nil?
    for sprite in @tile_sprites
      sprite.update
    end
  end
  def update_actors_sprites
    return if @actor_sprites.nil?
    for sprite in @actor_sprites.values
      sprite.update
    end
  end
  def update_enemy_sprites
    return if @enemy_sprites.nil?
    for sprite in @enemy_sprites.values
      sprite.update
    end
  end
  #--------------------------------------------------------------------
  def update_event_sprites
    return if @event_sprites.nil?
    needs_delete = []
    for sprite in @event_sprites.values
      sprite.update 
    end
  end
  #--------------------------------------------------------------------
  def update_cursor
    return if @cursor.nil?
    @cursor.update
  end
  #--------------------------------------------------------------------
  def update_projectiles
    return if @projectiles.nil?
    for projectile in @projectiles.clone
      projectile.update
      @projectiles.delete projectile    if projectile.disposed?
    end
  end
  #--------------------------------------------------------------------
  def update_image_queues
    return if @image_instructions.nil?
    for ins in @image_instructions
      process_ins(ins) #add all instructions to objects
    end
    #Clear instructions as objects will dispose when ready
    @image_instructions.clear 
    
    #Update object containers
    for cnt in @image_containers.values
      del_cnt_keys = []
      #read the key objects within and update the corresponding object
      for key in cnt.keys
        cnt[key].update
        #flagged for delete?
        del_cnt_keys << key if (cnt[key].can_delete?)
      end
      #delete items that were flagged
      for key in del_cnt_keys
        cnt.delete(key)
      end
    end
    del_global_keys = []
    for key in @global_images.keys
      @global_images[key].update
      del_global_keys << key if @global_images[key].can_delete?
    end
    for key in del_global_keys
      @global_images.delete(key)
    end
  end
  #--------------------------------------------------------------------
  def process_ins(instruction)
    img = get_object_for_manipulation(instruction)
    if (img != nil)
      img.add_action(instruction)
    end
  end
  
  def get_object_for_manipulation(instruction)
    img = nil
    #If there is a container object
    if (instruction[:container] != nil)
      #Read the key
      cnt_key = instruction[:container]
      #Is there an existing container reference for the given key
      if (@image_containers.keys.include?(cnt_key))
        #If there is container, save it for inspection
        cnt = @image_containers[cnt_key]
        
        #does the container hold a image for the given KEY
        if (cnt.keys.include?(instruction[:key]))
          #if yes, return that image sof manipulation
          img = cnt[instruction[:key]];
        else
          #if no, only create new one if flagged to do so.
          if (instruction[:create])
            img = Sprite_ActionImage.new
            cnt[instruction[:key]] = img
          end
        end
      else #no existing container object found, create one, if create is flagged
        if (instruction[:create])
          @image_containers[cnt_key] = {}
          img = Sprite_ActionImage.new
          @image_containers[cnt_key][instruction[:key]] = img
        end
      end
    else
      #If no container checking, check global container
      if (@global_images.keys.include?(instruction[:key]))
        img = @global_images[instruction[:key]]
      else
        #Since nothing was found for the given key, return unless create
        if (instruction[:create])
          img = Sprite_ActionImage.new
          @global_images[instruction[:key]] = img
        end
      end
    end
    return img
  end
  
  def waiting_on_effect?
    return false if @image_instructions.size == 0
    for inst in @image_instructions
      return true
    end
    return false
  end
  #--------------------------------------------------------------------
  # * Draw range
  #--------------------------------------------------------------------
  def draw_range(range, type)
    for x, y in range
      @tile_sprites.push(Sprite_Range.new(@viewport1, type, x, y))
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if animation is being displayed
  #--------------------------------------------------------------------------
  def animation?
    return true if projectiles_in_motion?
    for sprite in all_sprites
      return true if sprite.animation? #or sprite.effect?
    end
    return false
  end
  #----------------------------------------------------------------------------
  # Projectiles
  #----------------------------------------------------------------------------
  # create
  def add_projectile(attacker, data, type, target, viewport = @viewport1)
    target = @cursor unless target
    projectile = Projectile.new(viewport, attacker, target, data, type)
    @projectiles.push projectile
  end
  #----------------------------------------------------------------------------
  #* active projectiles ?
  def projectiles_in_motion?
    return @projectiles.any?
  end
  alias dis_spr_map dispose
  def dispose
    dis_spr_map
    dispose_cursor
    dispose_tile_sprites
    dispose_projectiles
    dispose_events
    dispose_actors
    dispose_enemies
  end
  #----------------------------------------------------------------------------
  # Dispose Cursor
  #----------------------------------------------------------------------------
  def dispose_cursor
    if !@cursor.nil?
      @cursor.dispose
    end
  end
  #----------------------------------------------------------------------------
  # Dispose Tile Sprites
  #----------------------------------------------------------------------------
  def dispose_tile_sprites
    if !@tile_sprites.nil?
      for sprite in @tile_sprites
        sprite.dispose
      end
      @tile_sprites.clear
    end
  end
  #----------------------------------------------------------------------------
  # Dispose Tile Sprites
  #----------------------------------------------------------------------------
  def dispose_projectiles
    if !@projectiles.nil?
      for sprite in @projectiles
        sprite.dispose
      end
      @projectiles.clear
    end
  end
  #----------------------------------------------------------------------------
  # Dispose Cursor
  #----------------------------------------------------------------------------
  def dispose_events
    if !@event_sprites.nil?
      for sprite in @event_sprites.values
        sprite.dispose
      end
      @event_sprites = {}
    end
  end
  #----------------------------------------------------------------------------
  # Dispose Cursor
  #----------------------------------------------------------------------------
  def dispose_actors
    if !@actor_sprites.nil?
      for sprite in @actor_sprites.values
        sprite.dispose
      end
      @actor_sprites = {}
    end
  end
  #----------------------------------------------------------------------------
  # Dispose Cursor
  #----------------------------------------------------------------------------
  def dispose_enemies
    if !@enemy_sprites.nil?
      for sprite in @enemy_sprites.values
        sprite.dispose
      end
      @enemy_sprites = {}
    end
  end
  #----------------------------------------------------------------------------
  # Battler Sprites
  #----------------------------------------------------------------------------
  def battler_sprites
    @actor_sprites.values + @enemy_sprites.values
  end
  #----------------------------------------------------------------------------
  # All Sprites - returns battle sprites and event sprites
  #----------------------------------------------------------------------------
  def all_sprites
    battler_sprites + @event_sprites.values
  end
  #----------------------------------------------------------------------------
  # Effect
  #----------------------------------------------------------------------------
  def effect?
    battler_sprites.any? {|sprite| sprite.effect? }
  end
  #----------------------------------------------------------------------------
  # Movement - defines if a sprite is in movement (general or weapon)
  #----------------------------------------------------------------------------
  def movement?
    battler_sprites.any? {|sprite| sprite.moving? }
  end
  #----------------------------------------------------------------------------
  # refresh battlers - forces battler refresh
  #----------------------------------------------------------------------------
  def refresh_battlers
    for sprite in all_sprites
      sprite.refresh rescue nil
    end
  end
  #----------------------------------------------------------------------------
  # Get_Battler_Sprite
  #----------------------------------------------------------------------------
  def get_battler_sprite(char)
    return @cursor if char.is_a?(TBS_Cursor)
    return (@actor_sprites[char] or @enemy_sprites[char] or @event_sprites[char])
  end
  def in_mini=(val)
    @in_mini = val
  end
  def in_mini?
    return @in_mini |= false
  end
  def hide_viewports
    @viewport1.visible = false
    @viewport2.visible = false
    @viewport3.visible = false
  end
  def show_viewports
    @viewport1.visible = true
    @viewport2.visible = true
    @viewport3.visible = true
  end
end