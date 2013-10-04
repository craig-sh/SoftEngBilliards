require 'rubygems'
require 'rubygame'

#STEP = 0.4
STEP = 0.05
LENGTH = 600
WIDTH = 300
BALL_RADIUS = 20
VELOCITY = 5.0
NUM_BALLS = 20
SLOWDOWN = 0.999
full = true 
#SLOWDOWN = 1
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
    #Apply decrease in speed due to friction    
    @x_speed *= SLOWDOWN
    @y_speed *= SLOWDOWN

    #move the ball into its new postion
    @x_pos += @x_speed * STEP 
    @y_pos += @y_speed * STEP

    #if the speed of the ball is close to 0, set it to 0
    if @x_speed.abs <= 0.05 and @y_speed.abs <= 0.05
      @x_speed = 0
      @y_speed = 0
    end
  end

  def abs_dis(ball)
    (((@x_pos - ball.x_pos )** 2)  + ((@y_pos - ball.y_pos )** 2))** 0.5
  end

  def to_s
      "#{@colour} = #{@x_pos},#{@y_pos} at #{@x_speed},#{@y_speed}"
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
  remove_collision1(ball1)
  remove_collision1(ball2)
  ball1.collision = ball2
  ball2.collision = ball1
end
def remove_collision(ball1,ball2)
  ball1.collision = nil
  ball2.collision = nil
end
def remove_collision1(ball)
  if ball != nil &&  ball.collision != nil
    ball.collision.collision = nil
  end
  ball.collision = nil
end
def sim_collision_with(ball1,ball2)
    #calculat the normal unit vectors
    magnitude_normal = ball1.abs_dis(ball2)
    x_normal = (ball1.x_pos - ball2.x_pos)/(magnitude_normal)
    y_normal = (ball1.y_pos - ball2.y_pos)/(magnitude_normal)

    #calculate the tangent unit vector, which is done by
    #flipping the x,y coords and negating one of them 
    x_tangent =  -1 * y_normal
    y_tangent =  x_normal

    #calculate the speed in the direction of the normal for each ball
    #Ball1 uses ball2's initial speeds and vice versa because
    #we assume perfectly elastic collisions
    ball1_normal =  x_normal * ball2.x_speed + y_normal * ball2.y_speed
    ball2_normal =  x_normal * ball1.x_speed +  y_normal * ball1.y_speed

    #calculate the speed in the direction of the tangent for each ball
    ball1_tangent =  x_tangent * ball1.x_speed + y_tangent * ball1.y_speed
    ball2_tangent =  x_tangent * ball2.x_speed + y_tangent * ball2.y_speed

    #decompose the normal and tangential speeds into x,y speeds
    #and set them to be the speeds of the new balls
    ball1.x_speed = ball1_normal * x_normal + ball1_tangent * x_tangent
    ball1.y_speed = ball1_normal * y_normal + ball1_tangent * y_tangent

    ball2.x_speed = ball2_normal * x_normal + ball2_tangent * x_tangent
    ball2.y_speed = ball2_normal * y_normal + ball2_tangent * y_tangent
end
def detect_wall_collision(ball)
  #check if the ball is outside the bounds of any wall and also that it
  #is travelling in the direction that will take it futher out of bounds.
  #The latter is checked so that only one wall collision is detected for 
  #a slow moving ball

  if ((ball.x_pos - BALL_RADIUS) <= 0  && ball.x_speed < 0 ) || 
     ((ball.x_pos + BALL_RADIUS) >= WIDTH && ball.x_speed > 0)
     ball.x_speed = ball.x_speed * -1
     remove_collision1(ball)
  end
  if ((ball.y_pos - BALL_RADIUS) <= 0 && ball.y_speed < 0) || 
    ((ball.y_pos + BALL_RADIUS) >= LENGTH && ball.y_speed > 0)
    ball.y_speed = ball.y_speed * -1
    remove_collision1(ball)
  end
end

def detect_ball_collision(ball1,ball2)
  #check if ball 1 is overlapping with ball2
  if (ball1.abs_dis(ball2) <= 2 * BALL_RADIUS )
    #make sure that we are not double counting a collision
    #puts ball1.collision
    #puts ball2.collision      
    if(ball1.collision != ball2 || ball2.collision != ball1)

      add_collision(ball1,ball2)
      sim_collision_with(ball1,ball2)
    end
    #if the recently came out of a collision and are no longer
    #overlapping, remove their refrence to the collsion
  elsif ball1.collision == ball2 || ball2.collision == ball1
    remove_collision(ball1,ball2)
  end
end
#################################################
#Setup ball array
balls = []
File.open(ARGV[0],"r").each do |line|
  args = line.split(" ")
  balls << Ball.new(args[0],args[1].to_f,args[2].to_f,args[3].to_f,args[4].to_f)
end
#balls << Ball.new("Violet" , 250, 0 , 0 ,5) 
#balls << Ball.new("blue"  , 5, 10  , VELOCITY/7  ,-2)

#balls << Ball.new("red"   , 250, 400 , 0  , 0)
#balls << Ball.new("pink"  , 75,  200  , VELOCITY/2  ,-3) 
#balls << Ball.new("yellow", 150, 550  , VELOCITY/4  ,-2)
#balls << Ball.new("black" , 200, 150  , 0           ,5)

#balls << Ball.new("pink",100,280,-2.5,3)
#balls << Ball.new("yellow",100,329,-1.16,-3.8)

# one ball in middle, two balls hit it from wither side
#balls << Ball.new("red",225,50,-2,0)
#balls << Ball.new("blue",25,50,2,0)
#balls << Ball.new("black",125,50,0,0)




#one white ball hitting 3 balls in triagle formation
#balls << Ball.new("red",WIDTH/2,LENGTH/2,0,0)
#balls << Ball.new("blue",WIDTH/2 + BALL_RADIUS*2 -0.1,LENGTH/2 - BALL_RADIUS*2 ,0,0)
#balls << Ball.new("black",WIDTH/2 - BALL_RADIUS*2 +0.1,LENGTH/2 - BALL_RADIUS*2,0,0)
#balls << Ball.new("white",WIDTH/2, LENGTH - BALL_RADIUS,0,-3)

#NUM_BALLS.times do |x|
#  color_num = rand(color_array.length - 1)
#  balls << Ball.new("red",rand(WIDTH),rand(LENGTH),VELOCITY * rand ,rand * Math::PI)  
#  color_array.slice!(color_num)
#end

#Create the object that draws balls to screen
drawer = Drawer.new


#Main Loop
initial = true
run = true
while(run)
  #set run to false as it it will become true if any ball is still moving
  run = false
  # the outer loop iterates through all balls,checks for wall collisions
  #and moves them
  for i in 0...balls.length 
    for j in i...balls.length #the inner loop checks if the current ball has collided with any other balls
        detect_ball_collision(balls[i],balls[j]) if i != j
    end
    detect_wall_collision(balls[i])
    balls[i].move
    #continue to run simulation  if the ball is still moving
    run = true if balls[i].x_speed != 0 || balls[i].y_speed !=0
  end
  #draw the balls to the screen to help with debug
  drawer.draw(balls) if initial||full
  initial = false
end
#Once all balls have ceased to move, print them out and exit
balls.each do |ball|
  puts ball
end
###################################################################
#puts "DONEEE"
@event_queue = Rubygame::EventQueue.new
# Use new style events so that this software will work with Rubygame 3.0
@event_queue.enable_new_style_events
while event = @event_queue.wait
  # Stop this program if the user closes the window
  break if event.is_a? Rubygame::Events::QuitRequested
end


 



