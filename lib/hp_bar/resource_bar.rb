class HPBar::ResourceBar < HPBar
  private

  def set_variables
    super
    @y_offset = @y_offset + HEIGHT[target_key]
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
end
