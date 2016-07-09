module GTBS
  def self.check_death_action(map_id, type)
    case type
    when 0 #actors
      case map_id
      when 0; return nil
      else; return nil
      end
    when 1 #enemies
      case map_id
      when 0; return nil
      else; return nil
      end
    end
  end
end
