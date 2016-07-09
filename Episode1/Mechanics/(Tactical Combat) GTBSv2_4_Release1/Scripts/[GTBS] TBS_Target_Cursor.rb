class TBS_Target_Cursor < Battle_Cursor
  Target_Anim = []
  for dy in [0, 1, 1, 0, 1, 0, 1, 0, 0, 0]
    Target_Anim.push(dy)
    Target_Anim.unshift(-dy)
  end
  def create_bitmap
    self.bitmap = Cache.picture('GTBS/Target')
  end
  def update
    super
    @phase ||= rand(Target_Anim.size-1)
    @phase += 1
    @phase %= Target_Anim.size
    self.y += Target_Anim[@phase] 
  end
end