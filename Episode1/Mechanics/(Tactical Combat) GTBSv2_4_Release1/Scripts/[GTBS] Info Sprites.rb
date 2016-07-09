#========================================================================
#  TBS_Sprite_Info : this Metaclass handles Battle_Start, Gold, Items, TBS__Phase Sprites
#========================================================================
# Usage in Scene_Battle_TBS:
# info_sprite = TBS_Sprite_Info.new
# while not info_sprite.disposed?
#   update_basic
#   info_sprite.update
# end

class TBS_Sprite_Info < Sprite
  #-----------------------------------------------------------
  #* Initialize
  #-----------------------------------------------------------
  def initialize
    super
    create_bitmap
    @wait = 0
  end
  #-------------------------------------------------------------
  #  create_bitmap for main sprite
  #-------------------------------------------------------------
  def create_bitmap
  end
  #-------------------------------------------------------------
  #* Update
  #------------------------------------------------------------
  def update
    super
    return if starting?
    return if exiting?
    main_update
  end
  #-------------------------------------------------------------
  #* Opening (usually, fade out the sprite)
  #------------------------------------------------------------
  def starting?
  end
    #-----------------------------------------------------------
  #* main update
  #-----------------------------------------------------------
  def main_update
    @wait += 1
  end
  #-------------------------------------------------------------
  #* Exiting (usually fade in, and dispose if opacity == 0)
  #------------------------------------------------------------
  def exiting?
  end
  #-------------------------------------------------------------
  #* Dispose
  #------------------------------------------------------------
  def dispose
    self.bitmap.dispose
    super
  end
end
class Sprite
  #-------------------------------------------------------------
  #* Center in the screen
  #------------------------------------------------------------
  def center_screen
    self.x = (Graphics.width - self.width) / 2
    self.y = (Graphics.height - self.height) / 2
  end
end

#========================================================================
#  TBS_Battle_Start_Sprite : Draws the victory conditions
#========================================================================
class TBS_Battle_Start_Sprite < TBS_Sprite_Info
  
  #-----------------------------------------------------------
  #* Initialize
  #-----------------------------------------------------------
  def initialize(vic_condition, fail_condition, vic_val, fail_val, during_battle, preemptive = "")
    
    @vic_condition = vic_condition
    @vic_val = vic_val
    
    @fail_condition = fail_condition
    @fail_val = fail_val
    
    @add_text = preemptive
    @pause = during_battle
    super()
    create_battle_start unless during_battle 
  end
  #-------------------------------------------------------------
  #  create_battle_start
  #-------------------------------------------------------------
  def create_bitmap 
    
    #set victory text
    case @vic_condition 
    when GTBS::Vic_Boss
      boss = $data_enemies[@vic_val].name
      victory_text =  sprintf(Vocab_GTBS::Boss_Condition, boss )
    when GTBS::Vic_Reach
      victory_text = sprintf(Vocab_GTBS::Reach_Condition, @vic_val[0], @vic_val[1]) 
    when GTBS::Vic_Holdout
      victory_text = sprintf(Vocab_GTBS::Holdout_Condition, @vic_val.to_s)
    when nil
      if @fail_condition == GTBS::Fail_Death
        victory_text = sprintf(Vocab_GTBS::Protect_Condition, $game_actors[@fail_val].name.to_s) 
      else
        victory_text = Vocab_GTBS::Defeat_All 
      end
    end
    
    bitmap = Bitmap.new(220, 48) 
    bitmap.font.name = GTBS::font
    bitmap.font.size = 35
    #draw text 
    bitmap.draw_shadow_text(0, 12-1, 220, 36, victory_text, 1)
    self.bitmap = bitmap
    self.x = Graphics.width/2
    self.y = Graphics.height/2
    self.opacity = 0
  end 
  #-------------------------------------------------------------
  #  create_battle_start (not called during battle
  #-------------------------------------------------------------
  def create_battle_start 
    count = 0
    @battle_start = Sprite.new
    if FileTest.exist?('Graphics/Pictures/Battle_Start.png')
      bmp = Cache.picture('Battle_Start')
    else
      bmp = Bitmap.new(300,180)
      bmp.font.name = GTBS::font
      bmp.font.size = 80
      bmp.font.bold = true 
      bmp.draw_shadow_text(0,0,300,180,GTBS::BATTLE_START+@add_text,1)
    end
    @battle_start.bitmap = bmp
    @battle_start.center_screen
    @battle_start.opacity = 0
  end
  
  #-------------------------------------------------------------
  #* Opening
  #------------------------------------------------------------
  def starting?
    super
    return false if @started
    @battle_start.opacity += 15 if @battle_start
    self.opacity += 10
    if self.opacity < 255
      return true
    else
      @started = true
      return false
    end
  end  
  #---------------------------------------------------------------
  #* wait 30 frames after a key is triggered
  #---------------------------------------------------------------
  def main_update
    @wait += 1    if not @pause
    @pause = false if Input.trigger?(Input::C) or Input.trigger?(Input::B)
  end

  #-------------------------------------------------------------
  #* Exiting
  #------------------------------------------------------------
  def exiting?
    super
    return false if @wait < 30
    if self.opacity > 0
      @battle_start.opacity -= 15  if @battle_start
      self.opacity -= 20
    else
      dispose
    end
    return true
  end
    
  #-------------------------------------------------------------
  #* Dispose
  #------------------------------------------------------------
  def dispose
    super
    if @battle_start
      @battle_start.bitmap.dispose
      @battle_start.dispose
    end
  end
end
#========================================================================
#  TBS_Gold_Sprite : Draw the gold gain during or at the end of the battle
#========================================================================
class TBS_Gold_Sprite < TBS_Sprite_Info
  #-----------------------------------------------------------
  #* Initialize
  #-----------------------------------------------------------
  def initialize(gold)
    super()
    @start_gold = $game_party.gold
    @gold_to_add = gold
    @step = 0
    self.opacity = 0
    self.center_screen
  end
  #-----------------------------------------------------------
  #* Create Bitmap
  #-----------------------------------------------------------
  def create_bitmap
    self.bitmap = Bitmap.new(544,180)
    self.bitmap.font.name = GTBS::font
    self.bitmap.font.size = 70
  end
    
  #-------------------------------------------------------------
  #* Opening
  #------------------------------------------------------------
  def starting?
    super
    if @gold == 0 and self.opacity < 255
      self.opacity += 10
      return true
    end
    return false
  end 
  #-------------------------------------------------------------
  #* Main_Update
  #------------------------------------------------------------
  def main_update  
    if @wait < 20
      @wait += 1
    else
      @step += 1
      set_gold
    end
  end
  #-------------------------------------------------------------
  #* Exiting
  #------------------------------------------------------------
  def exiting?
    super
    if @gold == @gold_to_add
      if self.opacity == 0
        dispose
      else
        self.opacity -= 15
      end
      return true 
    end
    return false 
  end

  #-------------------------------------------------------------
  #* Draw Actual Gold on Sprite
  #------------------------------------------------------------
  def set_gold
    gold = (@gold_to_add * @step) / 30
    if @gold != gold
      @gold = gold
      self.bitmap.clear
      self.bitmap.draw_shadow_text(0,0,524,180, (@start_gold+@gold).to_s + " " + Vocab::currency_unit, 2)
    end
  end
end
#========================================================================
#  TBS_Treasure_Sprite : Draw the items gained during or at the end of the battle
#========================================================================
class TBS_Treasure_Sprite < TBS_Sprite_Info
  #-----------------------------------------------------------
  #* Initialize
  #-----------------------------------------------------------
  def initialize(treasure)
    super()
    create_title
    @treasures = treasure[0, 6]# show only 6 items max
    @step = 0
    self.center_screen
  end
  #-----------------------------------------------------------
  #* Create Bitmap
  #-----------------------------------------------------------
  def create_bitmap
    self.bitmap = Bitmap.new(Graphics.width, Graphics.height) 
    self.bitmap.font.name = GTBS::font
  end
  #-----------------------------------------------------------
  #* Create Title Sprite
  #-----------------------------------------------------------
  def create_title
    @title = Sprite.new
    ##draw items gained##
    bmp = Bitmap.new(Graphics.width,180)
    bmp.font.name = GTBS::font
    bmp.font.size = 70
    bmp.draw_shadow_text(0,0,Graphics.width,180,GTBS::ITEM_GAIN_TEXT, 1)
    @title.bitmap = bmp
    @title.opacity = 0
  end
  
  #-------------------------------------------------------------
  #* main_Update
  #------------------------------------------------------------
  def main_update
    @force_quit = true if Input.trigger?(Input::C) or Input.trigger?(Input::B)
     if @wait < 20
      @wait += 1 
    else
      draw_treasure(@step)
      @step += 1
      @wait  = 0
    end
    @wait = 20 if @force_quit
  end
  
  #-------------------------------------------------------------
  #* Opening
  #------------------------------------------------------------
  def starting?
    super
    if @title.opacity < 255
      @title.opacity += 10
      return true
    end
    return false
  end
  #-------------------------------------------------------------
  #* Exiting
  #------------------------------------------------------------
  def exiting?
    super
    return false  if @step < @treasures.size
    return false if @wait < 20
    if self.opacity == 0
      dispose
    else
      self.opacity -= 15
      @title.opacity -= 15
    end
    return true 
  end
  
  #-------------------------------------------------------------
  #* Dispose
  #------------------------------------------------------------
  def dispose
    @title.bitmap.dispose
    @title.dispose
    self.bitmap.dispose
    super
  end
  #----------------------------------------------------------------------------
  # Draw Treasure
  #----------------------------------------------------------------------------
  def draw_treasure(index)
    item = @treasures[index]
    case item
    when RPG::Item
      item = $data_items[item.id]
    when RPG::Weapon
      item = $data_weapons[item.id]
    when RPG::Armor
      item = $data_armors[item.id]
    end
    bmp = self.bitmap
    bmp.font.color = Color.new(255, 255, 255)
    x = 300
    y = (index * 32) + 200
    rect = Rect.new(x, y, bmp.width - 32, 32)
    bmp.fill_rect(rect, Color.new(0, 0, 0, 0))
    
    bitmap = Cache.system('Iconset')
    rect = Rect.new(item.icon_index % 16 * 24, item.icon_index / 16 * 24, 24, 24)

    bmp.blt(x, y, bitmap, rect, 255)
    bmp.draw_text(x + 28, y, 212, 32, item.name, 0)
  end
end
#========================================================================
#  Congrat_Sprite : Draw Congratulations at the end of a victorious battle
#========================================================================
class Congrat_Sprite < TBS_Sprite_Info
  #-----------------------------------------------------------
  # Initialization
  #-----------------------------------------------------------
  def initialize(result)
    @result = result
    super()
  end
  #-----------------------------------------------------------
  #* draw congrats##
  #-----------------------------------------------------------
  def create_bitmap
    ##
    bmp = Bitmap.new(544,180)
    bmp.font.name = GTBS::font
    bmp.font.size = 70
    case @result
    when 0#victory
      congrat_text = GTBS::VICTORY_MESSAGE
    when 2#lose
      congrat_text = GTBS::DEFEAT_MESSAGE
    when 1#escape
      congrat_text = GTBS::ESCAPE_MESSAGE
    end
    bmp.draw_shadow_text(0,0,544,180,congrat_text, 1)
    self.bitmap = bmp
    self.opacity = 0
    self.center_screen
    #-----------------------------------------------------------
    #* draw battle_completed 
    @bat = Sprite.new
    ##draw bat complete##
    bmp = Bitmap.new(544,180)
    bmp.font.name = GTBS::font
    bmp.font.size = 55
    bmp.draw_shadow_text(0,0,544,180,GTBS::BATTLE_COMPLETE, 1)
    @bat.bitmap = bmp
    @bat.opacity = 0
    @bat.center_screen
    @bat.y += 60
  end
  #-------------------------------------------------------------
  #* Opening
  #------------------------------------------------------------
 def starting?
   if @wait == 0 and self.opacity < 255
      self.opacity += 10
      @bat.opacity += 10
      return true
    end
    return false
  end 
  #-------------------------------------------------------------
  #* Exiting
  #------------------------------------------------------------
  def exiting?
    return false if @wait < 25
    self.opacity -= 10
    @bat.opacity -= 10 if @wait > 45
    dispose if @bat.opacity == 0
  end
  #-----------------------------------------------------------
  #* draw battle_completed
  #-----------------------------------------------------------
  def dispose 
    super
    @bat.bitmap.dispose
    @bat.dispose
  end
end

#========================================================================
#  Congrat_Sprite : Draw Congratulations at the end of a victorious battle
#========================================================================
class TBS_Phase_Sprite < TBS_Sprite_Info
  #-----------------------------------------------------------
  #* Initialize
  #-----------------------------------------------------------
  def initialize(turn)
    @turn = turn 
    super()
    self.opacity = 0
    self.center_screen
    @wait = 0
  end
  #-----------------------------------------------------------
  #* draw congrats##
  #-----------------------------------------------------------
  def create_bitmap
    if FileTest.exist?(sprintf("Graphics/Pictures/GTBS/%s_Turn.png", @turn))
      bmp = Cache.picture(sprintf("GTBS/%s_Turn.png", @turn))
    else
      if @turn == Scene_Battle_TBS::Turn_Player
        team = Vocab_GTBS::Players
      elsif @turn == Scene_Battle_TBS::Turn_Enemy
        team = Vocab_GTBS::Enemies
      end 
      bmp = Bitmap.new(300,180)
      bmp.font.name = GTBS::font
      bmp.font.size = 60
      bmp.font.color = Color.new(30,30,30,255)
      bmp.draw_text(2,2,300,180,sprintf("%s Turn", team),1)
      bmp.font.color = Color.new(255,255,255,255)
      bmp.draw_text(0,0,300,180,sprintf("%s Turn", team),1)
    end
    self.bitmap = bmp
  end 
  #-------------------------------------------------------------
  #* Opening
  #------------------------------------------------------------
 def starting?
   if @wait == 0 and self.opacity < 255
      self.opacity += 10 
      return true
    end
    return false
  end
  #-------------------------------------------------------------
  #* Exiting
  #------------------------------------------------------------
  def exiting?
    return false if @wait < 30
    self.opacity -= 10
    dispose if self.opacity == 0
    return true
  end
end