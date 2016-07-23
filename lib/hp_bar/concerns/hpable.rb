module HPBar::Concerns::HPable
  def hp
    actor.hp
  end

  def hp=(val)
    actor.hp = val
  end

  def mhp
    actor.mhp
  end

  def max_resource
    actor.max_resource
  end

  def resource
    actor.resource
  end

  def resource_color
    actor.resource_color
  end
end