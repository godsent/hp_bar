#gems/hp_bar/lib/hp_bar.rb
#Author: Iren_Rin
#Use restricions: none
#How to use: read through HPBar constants, change if needed

class HPBar < Sprite_Base
  VERSION = '0.1'
  #USE SETTINGS
  USE = {
    battle: true,         #show hp bar in battle?
    map: true             #show hp bar on map
  }
  USE_RESOURCE = {
    battle: true,
    map: false
  }
  MAX_TP = 100
  MAX_EN = 100
  FREQ = {
    character: 1,
    battler: 5
  }
  RESOURCE_COLORS = {
    en: [200, 200, 30],
    tp: [230, 29, 29],
    mp: [30, 30, 190]
  }
  #SIZES SETTINGS
  WIDTH = {               #width of hp bar
    character: 30,        #for character
    battler: 38           #for battler
  }
  HEIGHT = {              #height of hp bar
    character: 5,         #for charcter
    battler: 5            #for battler
  }
  #POSITION SETTINGS
  #if target (Game_Enemy, Game_Actor, Game_Player, Game_Follower) responds to
  #hp_bar_offset_x and \ or hp_bar_offset_y,
  #the methods will be taken for offsets
  X_OFFSET = {            #x offset from target screen_x
    battler: -19,         #when target is battler
    character: -15        #when target is character
  }
  Y_OFFSET = {            #y offset from target screen y
    battler: -60,          #when target is battler
    character: -45        #when target is character
  }
  #DISAPEARING SETTINGS
  TIMER = {               #how much frames will be displayed the bar?
    character: {          #on map
      max: 300,           #timer in frames
      disapearing: 60     #how much frames from the timer the bar will be
                          #disapearing? Set equal to 0 to disapear instantly
    },
    battler: {}           #if you do not want to hide the bar after timeout -
                          #set key to empty hash, or nil
  }

  def initialize(viewport, target)
    @target = target
    set_variables
    super viewport
    create_bitmap
    update
  end

  def update
    super
    return unless use?

    if @updated % FREQ[target_key] == 0
      update_all
      set_was_counter
    end

    @updated += 1
  end

  def dispose
    self.bitmap.dispose
    super
  end

  private

  def set_variables
    @y_offset = setting(:hp_bar_offset_x, Y_OFFSET[target_key])
    @y_offset -= HEIGHT[target_key] if use_resource?
    @x_offset = setting(:hp_bar_offset_y, X_OFFSET[target_key])
    set_was_counter
    @updated = 0
  end

  def set_was_counter
    @hp_was = @target.hp
  end

  def update_all
    update_bitmap
    update_position
    update_visibility
    update_opacity
  end

  def setting(key, default)
    @target.respond_to?(key) ? @target.send(key) : default
  end

  def target_key
    @target.is_a?(Game_Battler) ? :battler : :character
  end

  def update_visibility
    self.visible = @target.alive? if @target.is_a?(Game_Battler)
  end

  def use?
    @use ||= USE[use_key] && target_on_screen?
  end

  def use_resource?
    @user_resource ||= USE_RESOURCE[use_key] && target_on_screen?
  end

  def use_key
    SceneManager.scene.is_a?(Scene_Map) ? :map : :battle
  end

  def target_on_screen?
    %w(screen_x screen_y).all? { |name| @target.respond_to? name }
  end

  def timer_options
    TIMER[target_key] || {}
  end

  def max_timer
    timer_options[:max]
  end

  def disapearing_timer
    timer = timer_options[:disapearing]
    timer < max_timer ? timer : max_timer
  end

  def update_opacity
    return unless max_timer

    if start_disappearing?
      update_disappearing_opacity
    else
      self.opacity = 255
      @frames_to_disappear = max_timer
    end
  end

  def update_disappearing_opacity
    if @frames_to_disappear.nil?
      self.opacity = 0
    elsif @frames_to_disappear >= 0
      @frames_to_disappear -= 1

      if @frames_to_disappear < disapearing_timer
        self.opacity = 255 * @frames_to_disappear / disapearing_timer
      end
    end
  end

  def start_disappearing?
    @hp_was == @target.hp
  end

  def update_bitmap
    return unless update_bitmap?
    self.bitmap.clear

    if height > 4
      self.bitmap.fill_rect 0, 0, current_width, 1, darker(color)
      self.bitmap.fill_rect 0, 1, current_width, height - 4, color
      self.bitmap.fill_rect 0, height - 3, current_width, 1, darker(color)
      self.bitmap.fill_rect 0, height - 2, current_width, 1, darker(darker color)
      self.bitmap.fill_rect 0, height - 1, current_width, 1, deep_dark_color
    else
      self.bitmap.fill_rect 0, 0, current_width, height, color
    end
  end

  def update_bitmap?
    @hp_was != @target.hp || @updated == 0
  end

  def height
    HEIGHT[target_key]
  end

  def deep_dark_color
    (0..3).to_a.inject(color) do |memo, i|
      darker memo
    end
  end

  def color
    Color.new red, green, 0
  end

  def brighter(color)
    color.green = [color.green + 40, 255].min
    color.blue  = [color.blue + 40, 255].min
    color.red   = [color.red + 40, 255].min
    color
  end

  def darker(color)
    color.green = [color.green - 40, 0].max
    color.blue  = [color.blue - 40, 0].max
    color.red   = [color.red - 40, 0].max
    color
  end

  def current_width
    WIDTH[target_key] * ratio
  end

  def red
    ratio > 0.5 ? 255 * (1 - ratio) * 3 : 255
  end

  def green
    ratio > 0.5 ? 200 : 200 * ratio * 2
  end

  def ratio
    @target.hp.to_f / @target.mhp
  end

  def create_bitmap
    self.bitmap = Bitmap.new WIDTH[target_key], HEIGHT[target_key]
  end

  def update_position
    self.x, self.y = @target.screen_x + @x_offset, @target.screen_y + @y_offset
    self.z = 50
  end
end

#gems/hp_bar/lib/hp_bar/resource_bar.rb
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
#gems/hp_bar/lib/hp_bar/concerns.rb
module HPBar::Concerns
end

#gems/hp_bar/lib/hp_bar/concerns/spritesetable.rb
module HPBar::Concerns::Spritesetable
  def self.included(klass)
    klass.class_eval do
      alias original_hp_bar_initialize initialize
      def initialize
        create_hp_bars
        create_resource_bars
        original_hp_bar_initialize
      end

      alias original_hp_bar_dispose dispose
      def dispose
        dispose_hp_bars
        dispose_resource_bars
        original_hp_bar_dispose
      end

      alias original_hp_bar_update update
      def update
        update_hp_bars
        update_resource_bars
        original_hp_bar_update
      end

      private

      def create_hp_bars
        @hp_bars = hp_bar_targets.map { |target| HPBar.new @viewport2, target }
      end

      def create_resource_bars
        @resource_bars = hp_bar_targets.map { |target| HPBar::ResourceBar.new @viewport2, target }
      end

      def update_hp_bars
        @hp_bars.each(&:update)
      end

      def update_resource_bars
        @resource_bars.each(&:update)
      end

      def dispose_hp_bars
        @hp_bars.each(&:dispose)
      end

      def dispose_resource_bars
        @resource_bars.each(&:dispose)
      end
    end
  end
end
#gems/hp_bar/lib/hp_bar/concerns/hpable.rb
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
#gems/hp_bar/lib/hp_bar/patch.rb
module HPBar::Patch
end

#gems/hp_bar/lib/hp_bar/patch/game_battler_base_patch.rb
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
#gems/hp_bar/lib/hp_bar/patch/spriteset_map_patch.rb
class Spriteset_Map
  include HPBar::Concerns::Spritesetable

  def hp_bar_targets
    [$game_player] + $game_player.followers.visible_folloers
  end
end
#gems/hp_bar/lib/hp_bar/patch/spriteset_battle_patch.rb
class Spriteset_Battle
  include HPBar::Concerns::Spritesetable

  def hp_bar_targets
    $game_troop.members + $game_party.members
  end
end
#gems/hp_bar/lib/hp_bar/patch/game_follower_patch.rb
class Game_Follower
  include HPBar::Concerns::HPable
end
#gems/hp_bar/lib/hp_bar/patch/game_player_patch.rb
class Game_Player
  include HPBar::Concerns::HPable
end
