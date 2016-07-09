module GTBS
  #------------------------------------------------------------------------
  # Extra Troops
  #------------------------------------------------------------------------
  # Add troops using the following method.
  # Extra_Troops[TROOP_ID] = [en_ID, en_ID, en_ID]
  #------------------------------------------------------------------------
  Extra_Troops = {}
  
end
  
class RPG::Troop
  def members 
    if @extra_troops.nil?
      add_new_members
    end
    return @members
  end
  def add_new_members
    data = GTBS::Extra_Troops[@id]
    if data != nil
      for memID in data
        mem = RPG::Troop::Member.new
        mem.enemy_id = memID
        @members << mem
      end
    end
    #Set this flag so that we only add the extra's 1 time
    @extra_troops = true 
  end
  #--------------------------------------------------------------------------
  # * New method: note
  #--------------------------------------------------------------------------
  # Reads all "pages" for comments and returns as 'notes'
  #--------------------------------------------------------------------------
  def note
    comment_list = []
    return @notes if !@notes.nil?
    for page in @pages
      next if !page || !page.list || page.list.size <= 0
      note_page = page.list.dup
      
      note_page.each do |item|
        next unless item && (item.code == 108 || item.code == 408)
        comment_list.push(item.parameters[0])
      end
    end
    @notes = comment_list.join("\r\n")
    return @notes
  end  
end

  