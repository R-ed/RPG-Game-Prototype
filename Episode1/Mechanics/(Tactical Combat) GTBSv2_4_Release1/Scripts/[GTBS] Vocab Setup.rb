module Vocab_GTBS
  #Information when placing batlers
    Place_Message = "Place your characters for battle"
    Place_Here = "Are you done placing characters?"
    No_Enemy_Placed = "There are no enemies on this map, ensure you have placed your events correctly.  Exiting to title"
    No_Actors_Placed="Please place some actor/placement events on your battle map! Exiting to title"
    #Victory/Defeat Conditions shown at the beginning
    Reach_Condition = "Reach %d, %d"
    Holdout_Condition = "Holdout %d turns"
    Protect_Condition="Protect %s"
    Boss_Condition = "Defeat %s"
    Defeat_All =  'Defeat all enemies'
    Escape_Cooldown = "You cannot escape right now"
  
  #Gained experience
  # %1$s is new level, and %2$s is previous level eg. you can do
    #Level_Up = "%2$s -> %1$s" to pop up "5 -> 6" when level increases from 5 to 6
    #Level_Up = "Lvl Up to %1$s" to pop up ""Lvl Up to 6" when level increases from 5 to 6
    #Level_Up = "Level Up!" to pop up "Level Up!" when level increases from 5 to 6
    Level_Up = "Lvl %1$s"
    POP_Gain_Exp = "%d exp"   # %d is the experience gained
    LOG_Gain_Exp = "%s has gained %d exp"

  #Text that show the team turn
    Team_Turn="%s Turn" # %s is Team's name defined below
    Players = 'Players'
    Enemies='Enemies'
    
  #Confirm actions?
    Do_Not_Move = 'Do not move this turn?'
    Do_Not_Attack =  'Do no attack this turn?'
    Do_Not_Move_Or_Attack = 'Do not move or attack this turn?'
    Revive_Target = "Revive %s?"   #%s is battler name
    Use_Here = "Use here?"
    Use_Item_Here='Use item here?'
    Revive_Who="Revive Who?"
    
  #Alert  in revive skill phase
    Cannot_Occupy = "%s cannot occupy that tile"     #%s is battler name
    
  #skill target 
    Use_On_Target_Or_Tile= 'Use on Target or Tile?'
    Target = 'Target'
    Panel = 'Panel'
  
  #Confirmation window
    Attack_Here = "Attack here?"
    Move_Here='Move here?'
    Move_Here_with_Cost = "Moving here will cost %s %s.  Are you sure?"
    Yes, No = "Yes", "No"  
  
  #Help in actor menu
    Help_Move='Move to an available location'
    Help_Attack='Attack a reachable square'
    Help_Class_Ability='Performs class ability'
    Help_Item='Use an item'
    Help_Wait='Wait this turn'
    Help_Status='Get detailed status information'
    Help_Defend='Defend this turn'
    Help_Escape='Attempt to leave the battlefield'
    
  #Text shown in Battle_Option menu
    Battle_Option_End_Turn = "End Turn"
    Battle_Option_Act_List = "Act List"
    Battle_Option_Conditions =  "Conditions"
    Battle_Option_Config = "Config"
    Battle_Option_Cancel = "Cancel"
  
  #Window Config Label
    Config_ATB_Mode = "Active Time Based" 
    Config_TEAM_Mode = "Team Based"
    Config_Scroll_On = "On"
    Config_Scroll_Off = "Off"
    Config_Reset_Default = "Reset Defaults"
    Config_Battle_System_Type = "Battle System Type"
    Config_Scroll_During_Battle = "Scroll Map During Battle?"
    Config_Done = "Done"
    Config_Attack_Skill_Color = "Attack Skill Color"
    Config_Help_Skill_Color = "Help Skill Color"
    Config_Move_Color = "Move Color"
    Config_Attack_Color = "Attack Color"

    
  #Other Config
    DOOM = "Doom!"
end