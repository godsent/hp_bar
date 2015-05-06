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
