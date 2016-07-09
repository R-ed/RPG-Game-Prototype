module GTBS
  #------------------------------------------------------------
  # CHEMIST_CLASS_ITEM Actor/Enemy - Is used by Item Range to determine if the item
  # can be 'thrown' to increase range based on the class_id of the actor or
  # enemy_id of the enemy.
  #------------------------------------------------------------
  # Use Class_Id => {Item_ID =>Range Addition}
  #------------------------------------------------------------
  CHEMIST_CLASS_ITEM_ACTOR = {}
  CHEMIST_CLASS_ITEM_ENEMY = {}
  #------------------------------------------------------------
  #Item Range
  # If item is actually a spell (spell scroll) then assign a spell id with it.
  # When the item is used if a spell_id is present, then the skill will be cast
  # instead of the item.
  # [range, Field, Skill_ID, vertical_range, vertical_range_aoe] 
  #------------------------------------------------------------
  #easy config:
  # range = [0, 0, 0] or range = [0, 0, 0, 24,24]
  # is default
  DEFAULT_Item_Range = [1, 0, 0, 24, 24] 
  ITEM_RANGE = {}
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  #------------------------------------------------------------
  # DO NOT CHANGE ANYTHING BELOW HERE!
  #------------------------------------------------------------
  
  #------------------------------------------------------------
  #Item Range
  # If item is actually a spell (spell scroll) then assign a spell id with it.
  # When the item is used if a spell_id is present, then the skill will be cast
  # instead of the item.
  # [range, Field, Skill_ID] 
  #------------------------------------------------------------
  def self.item_range( item_id)
    if ITEM_RANGE[item_id]
      range = ITEM_RANGE[item_id]
      (range.size...DEFAULT_Item_Range.size).each {|i|
        range << DEFAULT_Item_Range[i]
      }
    else
      range = DEFAULT_Item_Range
    end
    return range
  end 
end