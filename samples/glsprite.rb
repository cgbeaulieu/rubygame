#!/usr/bin/env ruby

require 'rubygame'
require 'rubygame/gl/scene'
require 'rubygame/gl/sprite'
require 'rubygame/gl/event_hook'

include Rubygame

WIDTH = 640
HEIGHT = 480

def main()
	Rubygame.init()
	scene = Scene.new([WIDTH,HEIGHT])
	scene.make_default_camera

	pic_in_pic = Camera.new {
		bound = scene.cameras.first.screen_region
		@screen_region = bound.scale(0.25,0.25)
		@screen_region = \
			@screen_region.move(Vector2[WIDTH-@screen_region.right - 20,
			                            HEIGHT-@screen_region.top - 20])
		@world_region = bound.scale(1,1)
		@clear_screen = true
		@background_color = [0.3, 0.3, 0.3, 0.5]
	}

	scene.add_camera pic_in_pic 

	queue = Rubygame::EventQueue.new()

	panda = GLImageSprite.new {
		@surface = Rubygame::Surface.load_image('big_panda.png')
		@has_alpha = true
		@pos = Point[WIDTH/2, HEIGHT/2]
		@angle = 0.4
		setup_texture()
	}

	class << panda
		def update( tick )
			time = tick.seconds
			@t += time
			@angle = 0.4 * Math::sin(@t / 0.3)
			@scale = Vector2[1.0 + 0.05*Math::sin(@t/0.085),
			                 1.0 + 0.05*Math::cos(@t/0.083)]
			super
		end
	end

	ruby = GLImageSprite.new {
		@surface = Rubygame::Surface.load_image('ruby.png')
		setup_texture()
		@pos = Vector2[100,300]
		@depth = -0.1
		@angle = -0.2
	}
	
	scene.objects.add_children(panda,ruby)

	handler = scene.event_handler

	set_pos_action = BlockAction.new do |owner, event|
		owner.pos = event.world_pos
	end
	
	handler.append_hook do
		@owner = panda
		@trigger = MouseHoverTrigger.new
		@action = set_pos_action
	end
	
	handler.append_hook do
		@owner = ruby
		@trigger = MouseClickTrigger.new
		@action = set_pos_action
	end

	handler.append_hook do
		@owner = scene
		@trigger = AnyTrigger.new(KeyPressTrigger.new( :q ),
															KeyPressTrigger.new( :escape ),
															InstanceTrigger.new( QuitEvent ))
		@action = BlockAction.new { |owner, event| throw :quit }
	end
	
	handler.append_hook do
		@owner = scene.cameras[0]
		@trigger = InstanceTrigger.new( Rubygame::MouseDownEvent )
		@action = BlockAction.new do |owner, event|
			scene.event_handler.handle( owner.make_mouseclick(event) )
		end
	end
	
	handler.append_hook do
		@owner = scene.cameras[0]
		@trigger = InstanceTrigger.new( Rubygame::MouseMotionEvent )
		@action = BlockAction.new do |owner, event|
			scene.event_handler.handle( owner.make_mousehover(event) )
		end
	end
	
	catch(:quit) do
		loop do
			queue.each do |event|
				scene.event_handler.handle(event)
			end

			# update everything
			scene.update()

			# redraw everything

			if panda.collides_with? ruby
				glColor([255,0,0])
			else
				glColor([255,255,255])
			end

			scene.draw()
			scene.refresh()

		end
	end
ensure
	Rubygame.quit()
end

main()