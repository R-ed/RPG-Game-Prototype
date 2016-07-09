class Game_Map
  #--------------------------------------------------------------------------
  # * Aliased methods
  #--------------------------------------------------------------------------
  unless @already_aliased_mgc_lm_gtbs
    alias add_cost_move_mgc_lm add_cost_move
    @already_aliased_mgc_lm_gtbs = true
  end
  #---------------------------------------------------------------
  #* [R4] Get cost of the move from x, y to nu_x, nu_y for actor
  #--------------------------------------------------------------
  def add_cost_move(bat, x, y, dir, nu_x, nu_y, flying_unit = false, adtnlParam = true)
    cost = add_cost_move_mgc_lm(bat, x, y, dir, nu_x, nu_y, flying_unit, adtnlParam)
    unless adtnlParam # not normally passable
      if Layy_Meta::GTBS_JUMP_COST
        cost += 1 # add jump cost because that is the only way to get to this point
      end
    end
    return cost
  end
end