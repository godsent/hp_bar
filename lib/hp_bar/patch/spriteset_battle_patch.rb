class Spriteset_Battle
  include HPBar::Concerns::Spritesetable

  def hp_bar_targets
    $game_troop.members + $game_party.members
  end
end
