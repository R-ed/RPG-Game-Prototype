msg = "Missing Resource Logger Enabled...\nIf a resource is missing it will be " +
"logged and replaced with an empty bitmap so that you may proceed.  " + 
"After you have finished, check the 'Missing_Graphics.txt' and 'Missing_Sounds.txt' "+ 
"in your project to see what is missing that was expected."+"\n"+
"This type of script will simply prevent un-needed crashes and put the exact " + 
"name of files that need to be present when you release.\n"
print msg

#--------------------------------------------------------------------------
# This script allows you to catch errors due to missing graphics/sounds, and log 
# them to the specified filename inside of the project folder.  You can later
# review that and determine what resources are still missing from your project.  
#--------------------------------------------------------------------------
# There is also the function to list all the Graphics/Sounds used.  This allows
# you to track what graphics are being used in your game so that you can optimize
# the resources for the project by letting you know which resources are not used. 
#--------------------------------------------------------------------------
module Logger
  Sound_Log_Filename = "Missing_Sounds.txt"
  Graphic_Log_Filename = "Missing_Graphics.txt"
  
  Log_All_Used = false
    Sound_Log_Used_File = "Used_Sounds.txt"
    Graphic_Log_Used_File = "Used_Graphics.txt"
  
  $entries_logged = {}
  def self.log_used_sound(filename)
    self.log(Sound_Log_Filename, filename)
  end
  def self.log_used_graphic(filename)
    self.log(Graphic_Log_Used_File, filename)
  end
  def self.log_missing_graphic(filename)
    self.log(Graphic_Log_Filename, filename)
  end
  def self.log_missing_sound(filename)
    self.log(Sound_Log_Filename, filename)
  end
  def self.log(filename, entry)
    entries = $entries_logged[filename]
    entries = [] if entries.nil?
    if !entries.include?(entry)
      entries << entry
      File.open(filename, 'a') {|f| f.write(entry + "\n") }
      print ("The following file is missing and cannot be loaded: " + entry + "\n")
    end
    $entries_logged[filename] = entries
  end
end

module Cache
  #--------------------------------------------------------------------------
  # * Create/Get Normal Bitmap
  #--------------------------------------------------------------------------
  def self.normal_bitmap(path)
    @cache[path] = Bitmap.new(path) unless include?(path) rescue @cache[path] = log_missing_graphic(path)
    Logger.log_used_graphic(path) if (Logger::Log_All_Used)
    @cache[path]
  end
  def self.log_missing_graphic(path)
    Logger.log_missing_graphic(path)
    Bitmap.new(32,32)
  end
end

module RPG
  class SE < AudioFile
    def play
      unless @name.empty?
        Audio.se_play('Audio/SE/' + @name, @volume, @pitch) rescue Logger.log_missing_sound("Audio/SE/" + @name)
        Logger.log_used_sound("Audio/SE/" + @name) if (Logger::Log_All_Used)
      end
    end
  end
  class ME < AudioFile
    def play
      if @name.empty?
        Audio.me_stop
      else
        Audio.me_play('Audio/ME/' + @name, @volume, @pitch) rescue Logger.log_missing_sound("Audio/ME/" + @name)
        Logger.log_used_sound("Audio/ME/" + @name) if (Logger::Log_All_Used)
      end
    end
  end
  class BGS < AudioFile
    @@last = BGS.new
    def play(pos = 0)
      if @name.empty?
        Audio.bgs_stop
        @@last = RPG::BGS.new
      else
        Audio.bgs_play('Audio/BGS/' + @name, @volume, @pitch, pos) rescue Logger.log_missing_sound("Audio/BGS/" + @name)
        Logger.log_used_sound("Audio/BGS/" + @name) if (Logger::Log_All_Used)
        @@last = self.clone
      end
    end
  end
  class BGM < AudioFile
    @@last = BGM.new
    def play(pos = 0)
      if @name.empty?
        Audio.bgm_stop
        @@last = RPG::BGM.new
      else
        Audio.bgm_play('Audio/BGM/' + @name, @volume, @pitch, pos) rescue Logger.log_missing_sound("Audio/BGM/" + @name)
        Logger.log_used_sound("Audio/BGM/" + @name) if (Logger::Log_All_Used)
        @@last = self.clone
      end
    end
  end
end
