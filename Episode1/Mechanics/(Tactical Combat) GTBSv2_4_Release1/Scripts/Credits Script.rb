=begin
module SceneManager
  def self.first_scene_class
    $BTEST ? Scene_Battle : Scene_Credit
  end
end
class CreditTransitionInfo
  attr_reader :back_sx, :back_sy, :back_tx, :back_ty
  attr_reader :title_sx, :title_sy, :title_tx, :title_ty
  attr_reader :name_sx, :name_sy, :name_tx, :name_ty
  attr_accessor :title_text, :name_text
  attr_accessor :time, :wait
  def initialize
    @back_sx = 0
    @back_sy = 0
    @back_tx = 40
    @back_ty = 60
    
    @title_sx = Graphics.width
    @title_sy = Graphics.height
    @title_tx = 300
    @title_ty = 300
    
    @name_sx = Graphics.width
    @name_sy = Graphics.height
    @name_tx = 100
    @name_ty = 320
    
    @title_text = ""
    @name_text = ""
    
    @time = 60
    @wait = 60
  end
  def set_back_info(sx,sy,tx,ty)
    @back_sx = sx
    @back_sy = sy
    @back_tx = tx
    @back_ty = ty
  end
  def set_title_info(sx,sy,tx,ty)
    @title_sx = sx
    @title_sy = sy
    @title_tx = tx
    @title_ty = ty
  end
  def set_name_info(sx,sy,tx,ty)
    @name_sx = sx
    @name_sy = sy
    @name_tx = tx
    @name_ty = ty
  end
  def back_trans_x
    (@back_tx - @back_sx)/@time.to_f
  end
  def back_trans_y
    (@back_ty - @back_sy)/@time.to_f
  end
  def title_trans_x
    (@title_tx - @title_sx)/@time.to_f
  end
  def title_trans_y
    (@title_ty - @title_sy)/@time.to_f
  end
  def name_trans_x
    (@name_tx - @name_sx)/@time.to_f
  end
  def name_trans_y
    (@name_ty - @name_sy)/@time.to_f
  end
end

module CreditScript
  def self.transition_info(index)
    info = CreditTransitionInfo.new
    case index
    when 0
      info.title_text = "Director"
      info.name_text = "GubiD"
    when 1
      info.title_text = "QA"
      info.name_text = "Bobs Bugs"
      info.time = 80
    when 2
      info.title_text = "Blarg"
      info.name_text = "GubiD"
      info.time = 300
      info.wait = 240
    when 3
      info.title_text = "Developer"
      info.name_text = "GubiD"
      info.set_name_info(60,85,200,51)
    end
    return info
  end
end

class Scene_Credit < Scene_Base
  def start
    super
    setup_variables
    get_picture_list
    start_music
  end
  def start_music
    audioFile = RPG::AudioFile.new("Battle1")
    #audioFile.play
  end
  def setup_variables
    @viewport_background = Viewport.new(0,0,Graphics.width, Graphics.height)
    @viewport_foreground = Viewport.new(0,0,Graphics.width, Graphics.height)
    @viewport_background.z = 0;
    @viewport_foreground.z = 100;
    @picture = Sprite.new(@viewport_background)
    @title = Sprite.new(@viewport_foreground)
    @name = Sprite.new(@viewport_foreground)
    @temp_bitmap = Bitmap.new(1,1)
    
    @current_index = -1
    @timer = 0
    @wait = 0
  end
  def get_picture_list
    @picture_list = []
  end
  def pre_terminate
    super
  end
  def terminate
    super
  end
  def update
    super
    update_pictures_info
    if Input.trigger?(Input::C)
      SceneManager.goto(Scene_Title)
    end
  end
  def update_pictures_info
    if @timer == 0 and @wait == 0
      @current_index += 1
      if @current_index == @picture_list.size - 1
        SceneManager.goto(Scene_Title)
      end
      @info = CreditScript.transition_info(@current_index)
      @picture.bitmap = Cache.picture("Credit\\" + @picture_list[@current_index])
      @picture.x = @info.back_sx
      @picture.y = @info.back_sy
      
      rect = @temp_bitmap.text_size(@info.title_text)
      @title.bitmap = Bitmap.new(rect.width, rect.height)
      @title.bitmap.draw_text(0,0,rect.width, rect.height, @info.title_text)
      @title.x = @info.title_sx
      @title.y = @info.title_sy

      rect = @temp_bitmap.text_size(@info.name_text)
      @name.bitmap = Bitmap.new(rect.width, rect.height)
      @name.bitmap.draw_text(0,0,rect.width, rect.height, @info.name_text)
      @name.x = @info.name_sx
      @name.y = @info.name_sy
      
      @timer = 60
      @wait = 60
    end
    if @timer > 0
      @picture.x += @info.back_trans_x
      @picture.y += @info.back_trans_y
      @title.x += @info.title_trans_x
      @title.y += @info.title_trans_y
      @name.x += @info.name_trans_x
      @name.y += @info.name_trans_y
      @timer -= 1
      return
    end
    if @wait > 0
      @wait -= 1
    end
  end
end
=end