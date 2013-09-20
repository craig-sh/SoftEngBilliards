TICK = 1
LENGTH = 200
WIDTH = 100
BALL_RADIUS = 1.0
MAX_TIME = 50

class Ball
	attr_accessor :colour,:x_pos,:y_pos,:velocity,:angle

	def initialize(colour,x_pos,y_pos,velocity,angle)
		@colour = colour
		@x_pos = x_pos
		@y_pos = y_pos
		@velocity = velocity
		@angle = angle
	end
	def deg(num)
		(num/Math::PI) * 180
	end

	def rad(num)
		(num * Math::PI)/ 180
	end
	def move
		@x_pos += Math.sin(@angle)  * (@velocity/TICK)
		@y_pos += Math.cos(@angle)  * (@velocity/TICK)
	end

	def abs_dis(ball)
		(((@x_pos - ball.x_pos )** 2)  + ((@y_pos - ball.y_pos )** 2))** 0.5
	end
		
	def to_s
    	"#{@colour} = #{@x_pos},#{@y_pos} at #{@velocity},#{@angle} rads"
  	end
end


def detect_collision(target_ball,ball_array)
	ball_array.each do |ball|
		if (ball != target_ball)
			if (target_ball.abs_dis(ball) <= 2 * BALL_RADIUS)
				puts "COLLLLISION"
			end
		end
	end
end

#Setup ball array
balls = []
balls << Ball.new("white", 50, 50, 3, 0) 
balls << Ball.new("red", 50, 100, 0, 0)
balls << Ball.new("green", 50, 150, 0,0)

#Main Loop
MAX_TIME.times do |time|
	balls.each do |ball|
		detect_collision(ball,balls)
		ball.move
		puts ball
	end
	puts
end