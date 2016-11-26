class HPBar::ResourceBar < HPBar
  private

  def set_variables
    super
    @y_offset = @y_offset + Y_RESOURCE_OFFSET[target_key]
  end

  def set_was_counter
    @resource_was = @target.resource
  end

  def start_disappearing?
    @resource_was == @target.resource
  end

  def use?
    use_resource?
  end

  def foreground_settings
    RESOURCE_FOREGROUNDS
  end

  def background_settings
    RESOURCE_BACKGROUNDS
  end

  def update_bitmap?
    @resource_was != @target.resource || @updated == 0
  end

  def color
    @target.resource_color
  end

  def ratio
    return 0 if @target.max_resource == 0
    @target.resource.to_f / @target.max_resource
  end

  def sprite_key
    if @target.energy_user?
      :en
    elsif @target.tp_user?
      :tp
    else
      :mp
    end
  end
end
