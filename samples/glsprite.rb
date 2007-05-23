#!/usr/bin/env ruby

require 'rubygame'
require 'rubygame/gl/scene'
require 'rubygame/gl/view'
require 'rubygame/gl/sprite'

WIDTH = 640
HEIGHT = 480

def main()
	Rubygame.init()
	scene = Scene.new([WIDTH,HEIGHT])
	view = View.new([WIDTH,HEIGHT])

	queue = Rubygame::EventQueue.new()
	clock = Rubygame::Clock.new { |c| c.target_framerate = 60 }

	panda = GLImageSprite.new {
		@surface = Rubygame::Surface.load_image('big_panda.png')
		@has_alpha = true
		setup_texture()
	}

	class << panda
		def update( time )
			@t += time
			@angle = 20 * Math::sin(@t / 300.0)
			@scale = Ftor.new(1.0 + 0.05*Math::sin(@t/85.0),
												1.0 + 0.05*Math::cos(@t/83.0))
		end
	end

	ruby = GLImageSprite.new {
		@surface = Rubygame::Surface.load_image('ruby.png')
		setup_texture()
		@pos = Ftor.new(300,200)
		@depth = -0.1
	}

	group = GLGroup.new {
		add_children(panda,ruby)
	}

	catch(:rubygame_quit) do
		loop do
			queue.each do |event|
				case event
				when Rubygame::MouseMotionEvent
					panda.pos = Ftor.new(event.pos[0], HEIGHT - event.pos[1])
				when Rubygame::KeyDownEvent
					case event.key
					when Rubygame::K_ESCAPE
						throw :rubygame_quit 
					when Rubygame::K_Q
						throw :rubygame_quit 
					end
				when Rubygame::QuitEvent
					throw :rubygame_quit
				end
			end

			# update everything
			time = clock.tick
			group.update(time)

			# redraw everything
			view.clear()
			group.draw()

			scene.refresh()

		end
	end
ensure
	Rubygame.quit()
end

main()