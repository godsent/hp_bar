class Game_BattlerBase
  def max_resource
    if is_energy_user?
      HPBar::MAX_EN
    elsif is_tp_user?
      HPBar::MAX_TP
    else
      mmp
    end
  end

  def resource
    if is_energy_user?
      energy 
    elsif is_tp_user?
      tp 
    else 
      mp 
    end
  end

  def resource_color
    key = if is_energy_user?
      :en
    elsif is_tp_user?
      :tp
    else 
      :mp
    end
    Color.new(*HPBar::RESOURCE_COLORS[key])
  end

  private

  def is_energy_user?
    respond_to?(:energy_user?) && energy_user?
  end

  def is_tp_user?
    respond_to?(:tp_user?) && tp_user?
  end
end