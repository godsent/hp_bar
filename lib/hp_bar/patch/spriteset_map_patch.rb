class Spriteset_Map
  include HPBar::Concerns::Spritesetable

  def hp_bar_targets
    [$game_player] + $game_player.followers.visible_folloers
  end
end
