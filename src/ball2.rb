require 'rubygems'
require 'rubygame'

STEP = 0.01
LENGTH = 600
WIDTH = 300
BALL_RADIUS = 20
MAX_TIME = 20000
VELOCITY = 5.0
NUM_BALLS = 20
WAIT = STEP/1000
#PI = Math::PI
color_array = ["red","blue","cyan","pink","Silver","Gray","Crimson","Navy","Azure","Lime","Gold","Brown","Teal","Purple","YeLlow"]
class Ball
  attr_accessor :colour,:x_pos,:y_pos,:x_speed,:y_speed,:collision

  def initialize(colour,x_pos,y_pos,x_speed,y_speed)
    @colour = colour
    @x_pos = x_pos
    @y_pos = y_pos
    @x_speed = x_speed
    @y_speed = y_speed
  end

  def move    
    #@x_speed = @x_speed * 0.00001
    #@y_speed = @y_speed * 0.00001
    #set new postions and prevent the ball from travelling of screen so they can be handled by collision detection
    @x_pos += @x_speed *  STEP #unless (@x_pos ) <= 0 || (@x_pos ) >= WIDTH
    @y_pos += @y_speed  * STEP#unless (@y_pos ) <= 0 || (@y_pos ) >= LENGTH

    if @x_speed.abs <= 0.05 and @y_speed.abs <= 0.05
      @x_speed = 0
      @y_speed = 0
    end
   
  end

  def abs_dis(ball)
    (((@x_pos - ball.x_pos )** 2)  + ((@y_pos - ball.y_pos )** 2))** 0.5
  end    
  def to_s
      color = nil
      color = @collision.colour unless collision == nil
      "#{@colour} = #{@x_pos},#{@y_pos} at #{@x_speed},#{@y_speed}\t\t#{color}"
  end
end
#################DRAWING###################
class Drawer
  attr_accessor :screen
  def initialize()
      # Open a double-buffered, video-RAM-based window in full-screen mode at the
    # maximum resolution
    @screen = Rubygame::Screen.open [ WIDTH, LENGTH], 0, Rubygame::DOUBLEBUF
    default_depth = 0
  end
  def draw(balls)
    @screen.fill(Rubygame::Color[:green])
    balls.each do |ball|
      center = [ball.x_pos,ball.y_pos]
      radius = BALL_RADIUS
      color = eval "Rubygame::Color[:#{ball.colour}]" #[ 0xc0, 0x80, 0x40]      
      @screen.draw_circle_s  center, radius, color
    end
    #sleep(WAIT)
    @screen.flip
  end
end
#################################################
#################FUNCTIONS################################
def add_collision(ball1,ball2)
  ball1.collision = ball2
  ball2.collision = ball1
end
def remove_collision(ball1,ball2)
  ball1.collision = nil
  ball2.collision = nil
end
def sim_collision_with(ball1,ball2)
    
    #calculate
    magnitude_normal = ball1.abs_dis(ball2)
    x_normal = (ball1.x_pos - ball2.x_pos)/(magnitude_normal)
    y_normal = (ball1.y_pos - ball2.y_pos)/(magnitude_normal)

    #if ball1.x_pos> ball2.x_pos && ball1.y_pos > ball2.y_pos
     # puts "#{ball1.colour} hitting #{ball2.colour} in 1"
      x_tangent =  -1 * y_normal
      y_tangent =  x_normal
    #else
    #  puts "#{ball1.colour} hitting #{ball2.colour} in 2"
     # x_tangent =  y_normal
     # y_tangent =  -1 * x_normal
    #end
    puts ball1
    puts ball2

    ball1_normal_x_speed = x_normal * ball1.x_speed
    ball1_normal_y_speed = y_normal * ball1.y_speed

    ball2_normal_x_speed = x_normal * ball2.x_speed
    ball2_normal_y_speed = y_normal * ball2.y_speed

    ball1_tangent_x_speed = x_tangent * ball1.x_speed
    ball1_tangent_y_speed = y_tangent * ball1.y_speed

    ball2_tangent_x_speed = x_tangent * ball2.x_speed
    ball2_tangent_y_speed = y_tangent * ball2.y_speed

    ball1.x_speed = ball2_normal_x_speed + ball1_tangent_x_speed
    ball1.y_speed = ball2_normal_y_speed + ball1_tangent_y_speed

    ball2.x_speed = ball1_normal_x_speed + ball2_tangent_x_speed
    ball2.y_speed = ball1_normal_y_speed + ball2_tangent_y_speed
end
def detect_wall_collision(ball)
  if ((ball.x_pos - BALL_RADIUS) <= 0  && ball.x_speed < 0 ) || 
     ((ball.x_pos + BALL_RADIUS) >= WIDTH && ball.x_speed > 0)
     ball.x_speed = ball.x_speed * -1
     if ball.collision != nil && ball.collision.collision == ball
      ball.collision.collision = nil
    end
    ball.collision = nil
  end
  if ((ball.y_pos - BALL_RADIUS) <= 0 && ball.y_speed < 0) || 
    ((ball.y_pos + BALL_RADIUS) >= LENGTH && ball.y_speed > 0)
    ball.y_speed = ball.y_speed * -1
    if ball.collision != nil && ball.collision.collision == ball
      ball.collision.collision = nil
    end
    ball.collision = nil
  end
end

def detect_ball_collision(ball1,ball2,collision_array)
  if (ball1.abs_dis(ball2) <= 2 * BALL_RADIUS )
    if(ball1.collision != ball2 and ball2.collision != ball1)
      sim_collision_with(ball1,ball2)
      add_collision(ball1,ball2)
    end
  elsif ball1.collision == ball2 || ball2.collision == ball1
    remove_collision(ball1,ball2)
  end
end
#################################################
#Setup ball array
balls = []
collision_array = []
#balls << Ball.new("Violet" , 250, 0 , 0 ,5) 
#balls << Ball.new("blue"  , 5, 10  , VELOCITY/7  ,-2)

#balls << Ball.new("red"   , 250, 400 , 0  , 0)
#balls << Ball.new("pink"  , 75,  200  , VELOCITY/2  ,-3) 
#balls << Ball.new("yellow", 150, 550  , VELOCITY/4  ,-2)
#balls << Ball.new("black" , 200, 150  , 0           ,5)

balls << Ball.new("pink",100,280,-2.5,3)
balls << Ball.new("yellow",100,329,-1.16,-3.8)

#NUM_BALLS.times do |x|
#  color_num = rand(color_array.length - 1)
#  balls << Ball.new("red",rand(WIDTH),rand(LENGTH),VELOCITY * rand ,rand * Math::PI)  
#  color_array.slice!(color_num)
#end


drawer = Drawer.new


#Main Loop
MAX_TIME.times do |time|
  finish = true
  for i in 0...balls.length
    for j in i...balls.length
        detect_ball_collision(balls[i],balls[j],collision_array) if i != j
    end
    detect_wall_collision(balls[i])
    balls[i].move
    finish = false if balls[i].x_speed != 0 || balls[i].y_speed !=0
  end

  #balls.each do |ball|
  #  detect_wall_collision(ball)
  #  detect_ball_collision(ball,balls,collision_array)    
  #  ball.move
    #puts ball
  #end
  
  drawer.draw(balls)
break if finish == true
end
balls.each do |ball|
  puts ball
end





###################################################################
puts "DONEEE"
@event_queue = Rubygame::EventQueue.new
# Use new style events so that this software will work with Rubygame 3.0
@event_queue.enable_new_style_events
while event = @event_queue.wait
  # Stop this program if the user closes the window
  break if event.is_a? Rubygame::Events::QuitRequested
end


 



