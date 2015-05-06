#lib/hp_bar.rb
#Author: Iren_Rin
#Use restricions: none
#How to use: read through HPBar constants, change if needed
class HPBar < Sprite_Base
  #USE SETTINGS
  USE = {
    battle: true,         #show hp bar in battle?
    map: true             #show hp bar on map
  }
  #SIZES SETTINGS
  WIDTH = {               #width of hp bar
    character: 30,        #for character
    battler: 80           #for battler
  }                       
  HEIGHT = {              #height of hp bar
    character: 5,         #for charcter
    battler: 8            #for battler
  }             
  #POSITION SETTINGS
  #if target (Game_Enemy, Game_Actor, Game_Player, Game_Follower) responds to
  #hp_bar_offset_x and \ or hp_bar_offset_y, the methods will be taken for offsets
  X_OFFSET = {            #x offset from target screen_x
    battler: -40,         #when target is battler
    character: -15        #when target is character
  } 
  Y_OFFSET = {            #y offset from target screen y
    battler: 10,         #when target is battler
    character: -45        #when target is character
  }
  #DISAPEARING SETTINGS
  TIMER = {               #how much frames will be displayed the bar?
    character: {          #on map
      max: 300,           #timer in frames
      disapearing: 60     #how much frames from the timer the bar will be disapearing?
                          #set equal to 0 to disapear instantly
    }, 
    battler: {}           #if you do not want to hide the bar after timeout -
                          #set key to empty hash, or nil
  }

  def initialize(viewport, target)
  	@target = target
    @y_offset = setting :hp_bar_offset_x, Y_OFFSET[target_key]
    @x_offset = setting :hp_bar_offset_y, X_OFFSET[target_key]
  	super viewport
  	create_bitmap
    self.opacity = 0 unless use?
  	update
  end

  def update
  	super
    if use?
      update_bitmap
      update_position
      update_opacity
      @hp_was = @target.hp
    end
  end

  def dispose
  	self.bitmap.dispose
  	super
  end

  private

  def setting(key, default)
    @target.respond_to?(key) ? @target.send(key) : default
  end

  def target_key
    @target.is_a?(Game_Battler) ? :battler : :character
  end

  def use?
    key = SceneManager.scene.is_a?(Scene_Map) ? :map : :battle
    USE[key] && %w(screen_x screen_y).all? do |name|
      @target.respond_to? name
    end
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
    if @hp_was == @target.hp 
      if @frames_to_dismiss >= 0
        @frames_to_dismiss -= 1
        if @frames_to_dismiss < disapearing_timer
          self.opacity = 255 * @frames_to_dismiss / disapearing_timer
        end
      end
    else
      self.opacity = 255
      @frames_to_dismiss = max_timer
    end
  end

  def update_bitmap
  	self.bitmap.clear
  	self.bitmap.fill_rect 0, 0, current_width, HEIGHT[target_key], color
  end

  def color
  	Color.new red, green, 0
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

#lib/hp_bar/concerns.rb
module HPBar::Concerns
end

#lib/hp_bar/concerns/spritesetable.rb
module HPBar::Concerns::Spritesetable
  def self.included(klass)
    klass.class_eval do
      alias original_hp_bar_initialize initialize
      def initialize
        create_hp_bars
        original_hp_bar_initialize
      end

      alias original_hp_bar_dispose dispose
      def dispose
        dispose_hp_bars
        original_hp_bar_dispose
      end

      alias original_hp_bar_update update
      def update
        update_hp_bars
        original_hp_bar_update
      end

      private

      def create_hp_bars
        @hp_bars = hp_bar_targets.map { |target| HPBar.new @viewport2, target }
      end

      def update_hp_bars
        @hp_bars.each(&:update)
      end

      def dispose_hp_bars
        @hp_bars.each(&:dispose)
      end
    end
  end
end
#lib/hp_bar/concerns/hpable.rb
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
end
#lib/hp_bar/patch.rb
module HPBar::Patch
end

#lib/hp_bar/patch/spriteset_map_patch.rb
class Spriteset_Map
  include HPBar::Concerns::Spritesetable

  def hp_bar_targets
    [$game_player] + $game_player.followers.visible_folloers
  end
end
#lib/hp_bar/patch/spriteset_battle_patch.rb
class Spriteset_Battle
  include HPBar::Concerns::Spritesetable

  def hp_bar_targets
    $game_troop.members + $game_party.members
  end
end
#lib/hp_bar/patch/game_follower_patch.rb
class Game_Follower
  include HPBar::Concerns::HPable
end
#lib/hp_bar/patch/game_player_patch.rb
class Game_Player
  include HPBar::Concerns::HPable
end
