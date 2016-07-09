=begin
Array Helps

+= Append array
-= Subtract array result is LEFT minus RIGHT nodes.  
&= is 'contained in both array'
|= is not contained in 'right' array
||= if LEFT is nil, then RIGHT
&&= if LEFT and RIGHT == true, then RIGHT

--------------------------------------------------------------------------------
Option: set_place_max
  Usage: Event | Call Script | $game_party.set_place_max=NUMBER
  Description: Sets the Maximum number of party that can be "placed" for a battle. 
--------------------------------------------------------------------------------
 
--------------------------------------------------------------------------------
Option: clear_place_max
  Usage: Event | Call Script | $game_party.clear_place_max
  Description: Clear any previous max provided.  Defaults back to all non-dead 
  members.
-------------------------------------------------------------------------------- 
 
--------------------------------------------------------------------------------
Option: tbs_override_map
  Usage: Event | Call Script | tbs_override_map(MAP_ID)
  Description: Sets the next GTBS to use the defined MAP_ID
-------------------------------------------------------------------------------- 
  
  
  
=end

