require 'rubygems'
require 'rubygame'

TICK = 1
LENGTH = 600
WIDTH = 300
BALL_RADIUS = 5.0
MAX_TIME = 100000
VELOCITY = 10.0
NUM_BALLS = 20
#PI = Math::PI
color_array = ["red","blue","cyan","pink","Silver","Gray","Crimson","Navy","Azure","Lime","Gold","Brown","Teal","Purple","YeLlow"]
class Ball
  attr_accessor :colour,:x_pos,:y_pos,:velocity,:angle

  def initialize(colour,x_pos,y_pos,velocity,angle=0)
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
    @velocity = @velocity * ((@velocity *  -1/250.0 ) + 1)    
    if @velocity <= 0.5
      @velocity = 0
    end
    #set new postions and prevent the ball from travelling of screen so they can be handled by collision detection
    @x_pos -= Math.sin(@angle)  * (@velocity/TICK) #unless (@x_pos ) <= 0 || (@x_pos ) >= WIDTH
    @y_pos += Math.cos(@angle)  * (@velocity/TICK) #unless (@y_pos ) <= 0 || (@y_pos ) >= LENGTH
  end

  def abs_dis(ball)
    (((@x_pos - ball.x_pos )** 2)  + ((@y_pos - ball.y_pos )** 2))** 0.5
  end
    
  def to_s
      "#{@colour} = #{@x_pos},#{@y_pos} at #{@velocity},#{@angle} rads"
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
  
     
    # Show the color depth of the screen
    puts "The screen has a color depth of %i bits" % @screen.depth
     
    # Hide the mouse cursor
       
  end

  def draw(balls)
    @screen.fill(Rubygame::Color[:green])
    balls.each do |ball|
      center = [ball.x_pos,ball.y_pos]
      radius = BALL_RADIUS
      color = eval "Rubygame::Color[:#{ball.colour}]" #[ 0xc0, 0x80, 0x40]      
      @screen.draw_circle_s  center, radius, color
    end
    sleep(0.025)
    @screen.flip
  end
end
#################################################
#################FUNCTIONS################################
def detect_wall_collision(ball)
  if (ball.x_pos - BALL_RADIUS) <= 0 || (ball.x_pos + BALL_RADIUS) >= WIDTH
    ball.angle = -1 * ball.angle
  end
  if (ball.y_pos - BALL_RADIUS) <= 0 || (ball.y_pos + BALL_RADIUS) >= LENGTH
    ball.angle = Math::PI -  ball.angle
  end
end
def detect_ball_collision(target_ball,ball_array,collision_array)
  ball_array.each do |ball|
    if (ball != target_ball) #make sure we are not checking collision with ourself
      if (target_ball.abs_dis(ball) <= 2 * BALL_RADIUS )
        immeadiate_collision = false
        collision_array.each do |collision|
          if collision.index(ball) && collision.index(target_ball)
            immeadiate_collision = true
          end
        end
        if not immeadiate_collision
          collision_array << [target_ball,ball]
          temp = target_ball.velocity
          tempanggle = target_ball.angle
          target_ball.velocity = ball.velocity
          target_ball.angle = ball.angle
          ball.velocity = temp
          ball.angle = tempanggle
        end
      else
        #when the balls aren't touching after colliding , remove them from the array
        collision_array.reject!{|collision| collision.index(ball) && collision.index(target_ball)}
      end
    end
  end
end
#################################################
#Setup ball array
balls = []
collision_array = []
#balls << Ball.new("Violet" , 250, 250  , VELOCITY    ,3) 
#balls << Ball.new("red"   , 100, 300  , VELOCITY    ,0)
#balls << Ball.new("blue"  , 150, 170  , VELOCITY/7  ,0)
#balls << Ball.new("pink"  , 75,  200  , VELOCITY/2  ,3) 
#balls << Ball.new("yellow", 150, 550  , VELOCITY/4  ,0)
#balls << Ball.new("black" , 200, 150  , 0           ,0)

NUM_BALLS.times do |x|
  color_num = rand(color_array.length - 1)
  balls << Ball.new(color_array[color_num],rand(WIDTH),rand(LENGTH),VELOCITY * rand ,rand * Math::PI)  
  #color_array.slice!(color_num)
end


drawer = Drawer.new


#Main Loop
MAX_TIME.times do |time|
  balls.each do |ball|
    detect_wall_collision(ball)
    detect_ball_collision(ball,balls,collision_array)    
    ball.move
    #puts ball
  end
  
  drawer.draw(balls)
  
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


 



