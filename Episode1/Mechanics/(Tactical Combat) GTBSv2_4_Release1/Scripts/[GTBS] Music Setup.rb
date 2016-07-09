module GTBS
  #-------------------------------------------------------------
  # Use Phase Music?  Only used if in TEAM mode
  #-------------------------------------------------------------
  PHASE_MUSIC = false
  #-------------------------------------------------------------
  # Actor Music Setup
  #-------------------------------------------------------------
  # DEF_ACTOR_MUSIC if the Default music to be played when one is not specified 
  # for the ACTOR_TURN_MUSIC[ MAP_ID ]
  #-------------------------------------------------------------
  # Easy Config:
  #  act_music=BLAH
  #-------------------------------------------------------------
  version_base = "Battle4"
  DEF_ACTOR_MUSIC = version_base
  ACTOR_TURN_MUSIC = {} #this is to initialize the music hash * DO NOT REMOVE *
  ACTOR_TURN_MUSIC[1] = version_base
  
  #-------------------------------------------------------------
  # Enemy Music Setup
  #-------------------------------------------------------------
  # DEF_ENEMY_MUSIC if the Default music to be played when one is not specified 
  # for the ENEMY_TURN_MUSIC[ MAP_ID ]
  #-------------------------------------------------------------
  # Easy Config
  #  en_music=BLAH
  #-------------------------------------------------------------
  version_base = "Battle7"
  DEF_ENEMY_MUSIC = version_base
  ENEMY_TURN_MUSIC = {} #this is to initialize the music hash * DO NOT REMOVE *
  ENEMY_TURN_MUSIC[1] = version_base

  #-------------------------------------------------------------
  # Map Side View Music
  #-------------------------------------------------------------
  # This is used to cause X music to start playing when the side battle is shown
  # music MUST be ME type as anything else will change the overall BGM.  
  #-------------------------------------------------------------
  # Map_SideView_Music = {}
  # Map_SideView_Music[MAP_ID] = "ME_FileName"
  #-------------------------------------------------------------
  # Easy Config for the MAP properties
  #   side_music=ME_FILENAME
  #-------------------------------------------------------------
  Map_SideView_Music = {}
  #Map_SideView_Music[1] = "Mystery"
  
  #-------------------------------------------------------------
  # Side View Music Volume
  #-------------------------------------------------------------
  # If not supplied it is assumed 100 percent volume
  #-------------------------------------------------------------
  # Map_SideView_Music_Vol = {}
  # Map_SideView_Music_Vol[MAPID] = 50
  #-------------------------------------------------------------
  # Easy Config for MAP properties
  #    side_volume=50
  #-------------------------------------------------------------
  Map_SideView_Music_Vol = {}
  #Map_SideView_Music_Vol[1] = 30
  
  #-------------------------------------------------------------
  # Side Music FadeOut Time
  #-------------------------------------------------------------
  # Time required for the ME to fade out when side view mode is closed
  #-------------------------------------------------------------
  Side_Music_FadeOut_Time = 10
  
  #-------------------------------------------------------------
  # **** Do not modify contents below here ****
  #-------------------------------------------------------------
  
  #-------------------------------------------------------------
  # Side Music - The music to be played when side view is opened
  #-------------------------------------------------------------
  def self.side_music(map_id)
    me = RPG::ME.new((GTBS::Map_SideView_Music[map_id] || ""))
    me.volume = Map_SideView_Music_Vol[map_id] || 100
    me
  end
  
  #-------------------------------------------------------------
  # Actor Phase Music - reads the music name for the battle map
  #-------------------------------------------------------------
  def self.actor_phase_music
    ACTOR_TURN_MUSIC[$game_map.map_id] || DEF_ACTOR_MUSIC
  end
  
  #-------------------------------------------------------------
  # Enemy Phase Music - reads the music name for the battle map
  #-------------------------------------------------------------
  def self.enemy_phase_music
    ENEMY_TURN_MUSIC[$game_map.map_id] || DEF_ENEMY_MUSIC
  end
end