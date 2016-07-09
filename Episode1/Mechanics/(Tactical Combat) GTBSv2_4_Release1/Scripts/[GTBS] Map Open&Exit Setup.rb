module GTBS
  #=============================================================#
  #                  Open and Exit Info Settings                #
  #=============================================================# 
  
  #-------------------------------------------------------------
  # Call Alternate Map
  #-------------------------------------------------------------
  # Sets battle_scene to change if called from specified map, otherwise it is self
  # Map note easy config:
  #  battle_on=ID  
  # where ID is where you want to battle instead of using the current map
  #-------------------------------------------------------------
  # CALL_ALTERNATE_MAP = {}
  # CALL_ALTERNATE_MAP[CALLING_MAPID] = DESIRED_BATTLE_MAPID
  # etc...
  #-------------------------------------------------------------
  CALL_ALTERNATE_MAP = {}
  
  #-----------------------------------------------------------
  # Exit Battle Information
  #-----------------------------------------------------------
  # This section tells the battle interpreter how and where to return from battle 
  # map. 
  # Use ID of 0 for current map
  #-----------------------------------------------------------
  # Map Note Easy Config
  #   exit_to=[ID, X, Y, DIR]
  #-----------------------------------------------------------
  MAP_EXIT_INFO = {}  
  
  #-------------------------------------------------------------
  # Transfer Map by Region
  # Notes need to be updated
  # MapID => {RegionID=>TransferToMAPID...}
  # Easy Config:
  #  bat_region4=3
  # Where 4 is the REGION ID and 3 is the MAPID to fight on
  #-------------------------------------------------------------
  MAP_Region_Transfer = {}
  
  #-------------------------------------------------------------
  # Battle back by region.  Battle Back is used only when Mini Battle = true
  #-------------------------------------------------------------
  # Easy Config:
  # backdrop4=BattleBackImg
  # where 4 is the REGION ID
  #-------------------------------------------------------------
  Battleback_Region = {}
  
  #-------------------------------------------------------------
  # Backdrop Default
  # Use this to define the default backdrop to be used for MAPID
  # Add additional lines as needed:
  #-------------------------------------------------------------
  # Easy Config:
  #  default_back=BackDropName
  #-------------------------------------------------------------
  # BackDrop_Default[MAPID] = BACKDROPNAME
  #-------------------------------------------------------------
  BackDrop_MAP_Default = {}
  
  #-------------------------------------------------------------
  # Default Backdrop
  #-------------------------------------------------------------
  # If a map default is not defined and no other background located.  
  #-------------------------------------------------------------
  Default_Backdrop = "TestBack"
  
  #-------------------------------------------------------------
  # Do not touch this part
  #-------------------------------------------------------------
  def self.battle_map(map_id)
    (CALL_ALTERNATE_MAP[map_id] || map_id)
  end
  def self.battle_exit_info(map_id)
    (MAP_EXIT_INFO[map_id] || false)
  end
end
  