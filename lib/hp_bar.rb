#Author: Iren_Rin
#Use restricions: none
#How to use: read through HPBar constants, change if needed
class HPBar < Sprite_Base
  VERSION = '0.0.1'
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

require 'hp_bar/concerns'
require 'hp_bar/patch'
