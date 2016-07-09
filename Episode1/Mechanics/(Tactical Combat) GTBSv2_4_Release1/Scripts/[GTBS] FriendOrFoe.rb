class Game_Interpreter
  def foe_team(team1, team2)
    team1.downcase!
    team2.downcase!
    if ($game_temp.foe_data.nil?)
      $game_temp.foe_data = {}
    end
    if $game_temp.foe_data[team1].nil?
      $game_temp.foe_data[team1] = []
    end
    unless $game_temp.foe_data[team1].include?(team2)
      $game_temp.foe_data[team1] << team2 
    end
  end
end

class Game_Temp
  attr_accessor :foe_data
end

class Scene_Battle_TBS
  def opponents_of(obj, debug=false)
    opponents = []
    if obj.is_a?(Game_Battler)
      key = obj.team
    else
      key = obj
    end
    foe_teams = BattleManager.foe_data[key];
    if foe_teams == nil
      return opponents
    end    
    opponents += tactics_all.select {|mem| foe_teams.include?(mem.team)}
    if debug
      msg = "Getting Opponents of: #{key} #{obj.is_a?(Game_Battler) ? obj.name : nil}\n" 
      msg += construct_name_list(opponents) + "\n"
      print msg
    end
    return opponents
  end
  def friends_of(obj, debug=false)    
    friends = []
    if obj.is_a?(Game_Battler)
      key = obj.team
    else
      key = obj
    end
    if key == nil
      return friends
    end
    friends += tactics_all.select {|mem| mem.team == key}
    if debug
      msg = "Getting friends of: #{key}\n" 
      msg += construct_name_list(friends) + "\n"
      print msg
    end
    return friends
  end
  def dead_friends_of(battler)
    return tactics_dead.select {|mem| mem.team == battler.team}
  end
  def construct_name_list(list)
    result = ""
    for mem in list
      result += "#{mem.name}[#{mem.team}]\n"
    end
    return result
  end
end