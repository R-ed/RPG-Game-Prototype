class Game_Event < Game_Character
  def name
    @event.name
  end
  def at_xy_coord(x,y)
    returnValue = false
    for position in positions
      if ( position[0] == x && position[1] == y )
        returnValue = true
      end
    end
    return returnValue
  end
  def positions(x=@x, y=@y)
    return [[x,y]] if size == 1
  end
  def size
    return 1
  end
  #--------------------------------------------------------------------------
  # * New method: note
  #--------------------------------------------------------------------------
  def notes
    return ""     if !@page || !@page.list || @page.list.size <= 0
    return @notes if @notes && @page.list == @note_page
    @note_page = @page.list.dup
    comment_list = []
    @page.list.each do |item|
      next unless item && (item.code == 108 || item.code == 408)
      comment_list.push(item.parameters[0])
    end
    @notes = comment_list.join("\r\n")
    @notes
  end  
end
