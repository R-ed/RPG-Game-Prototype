#============================================================================
# POS
#----------------------------------------------------------------------------
# This class simply stores x,y info for faster reading than from arrays
#============================================================================
class POS
  attr_accessor :x
  attr_accessor :y  
  def initialize(x = 0, y = 0)
    @x = x
    @y = y
  end
  
  def moveto(x,y)
    @x = x
    @y = y
  end
  
  def pos
    return [@x, @y]
  end
  
  def [](key)
    if key == 0
      return @x
    else
      return @y
    end
  end
  
  def positions
    return [[@x, @y]]
  end
  
  def unit_size
    return 1
  end
  
  def pos
    return [x,y]
  end
end