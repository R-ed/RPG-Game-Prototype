#----------------------------------------------------------------------------
# Create Confirm command window 
#----------------------------------------------------------------------------
class Command_Confirm < TBS_Window_Selectable
  attr_reader :question
  #============================================================================
  # CONSTANTS
  #============================================================================
  Place = 'place'                   #end of prepare place
  Wait = 'wait'
  Item = 'item'
  Revive = 'revive'
  Skill = 'skill'
  Attack = 'attack'
  Move = 'move'
  Wait_Skill_Targeting = 'wait_target'  
  #----------------------------------------------------------------------------
  # * Object Initialization
  #----------------------------------------------------------------------------
  def initialize(text = "")
    super(0, 0, 240, 96)
    self.contents = Bitmap.new(width-32, height-32)
    self.x = 320 - (width/2)
    self.y = 240 - (height/2)
    self.index = -1
    reset_commands
    refresh(text)
  end
  #--------------------------------------------------------------------------
  # Item Max
  #--------------------------------------------------------------------------
  def item_max
    return 2
  end
  #--------------------------------------------------------------------------
  # * Get Digit Count
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #----------------------------------------------------------------------------
  # Reset default commands
  #----------------------------------------------------------------------------
  def reset_commands
    @list = [ Vocab_GTBS::Yes, Vocab_GTBS::No]
  end
  #----------------------------------------------------------------------------
  # Refresh - draws text
  #----------------------------------------------------------------------------
  def refresh(text)
    rect = get_window_size(text)
    recenter_x
    create_contents
    super() #draws yes/no or whatever.
    self.index = 0
    rect.width = self.contents.width
    self.contents.draw_text(rect,text,1) 
    #self.contents.fill_rect(rect, Color.new(0,0,0,255))
  end
  #----------------------------------------------------------------------------
  # Get Window Size - Updates the dialog size to fit the text exactly
  #----------------------------------------------------------------------------
  def get_window_size(text)
    rect = self.contents.text_size(text)
    self.width = [240, rect.width].max #min of 240
    return rect
  end
  #----------------------------------------------------------------------------
  # Re-Center X
  #----------------------------------------------------------------------------
  def recenter_x
    self.x = (Graphics.width - width)/2
  end
  #----------------------------------------------------------------------------
  # Draw Item - Will draw items on the window
  #----------------------------------------------------------------------------
  def draw_item(index)
    rect = self.contents.rect
    rect.x += rect.width/2 if index == 1
    rect.width = rect.width/2
    rect.height = 28
    rect.y = 32
    self.contents.draw_text(rect, @list[index], 1)
  end
  #----------------------------------------------------------------------------
  # Update - Updates back image if it exist
  #----------------------------------------------------------------------------
  def update
    super
    update_cursor_rect
  end
  
  #----------------------------------------------------------------------------
  # Force Yes when not show confirm
  #----------------------------------------------------------------------------
  def index
    if self.visible
      return @index
    else
      return 0
    end
  end
  #----------------------------------------------------------------------------
  # Update cursor size/position
  #----------------------------------------------------------------------------
  def update_cursor_rect
    rect = self.contents.rect
    rect.x += rect.width/2 if index == 1
    rect.width = rect.width/2
    rect.height = 28
    rect.y = 32
    self.cursor_rect.set(rect)
  end
  #----------------------------------------------------------------------------
  # ask the confirmation of type
  #----------------------------------------------------------------------------
  def ask(*args)
    type = args[0]
    case type
    when Move
      if args[1] != nil and args[1] > 0  #args[1] is move_cost
        text = sprintf(Vocab_GTBS::Move_Here_with_Cost, args[1].to_s, args[2])
      else
        text = Vocab_GTBS::Move_Here
      end
      self.visible = GTBS::MOVE_CONFIRM 
    when Attack
      text = Vocab_GTBS::Attack_Here
      self.visible = GTBS::ATTACK_CONFIRM
    when Skill
      case args[1]
      when Wait_Skill_Targeting
        type = Wait_Skill_Targeting
        text = Vocab_GTBS::Use_On_Target_Or_Tile
        @commands = [Vocab_GTBS::Target, Vocab_GTBS::Panel]
        self.visible = true
      else
        text = Vocab_GTBS::Use_Here
        self.visible = GTBS::ATTACK_CONFIRM
      end
    when Item
      text = Vocab_GTBS::Use_Item_Here
      self.visible = GTBS::ATTACK_CONFIRM
    when Revive
      text = sprintf(Vocab_GTBS::Revive_Target , args[1])
      self.visible = GTBS::ATTACK_CONFIRM
    when Place
      text = Vocab_GTBS::Place_Here
      self.visible = true
    when Wait
      text =  args[1]
      self.visible = true
    end
    refresh(text)
    @question = type 
    self.active = true
  end 
end

