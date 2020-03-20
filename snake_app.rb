require 'io/console'
require_relative 'snake'
class SnakeApp
  attr_accessor :input_character
  attr_accessor :input_thread
  attr_accessor :width
  attr_accessor :height
  attr_accessor :render_field
  def initialize
    @width = 20
    @height = 20
    @render_field = []
    @delay = 0.2
    @snake = Snake.new(self)
    @cur_step = 0
    generate_food
    clear_render_field
  end

  def clear_render_field
    @render_field = []
    width.times do |w|
      @render_field[w] = []
      height.times do |h|
        @render_field[w][h] = '  '
      end
    end
  end

  def render_game_over
    line = height / 2
    x = width / 2 - 2
    set_char(x: x, y: line, str: 'GA')
    set_char(x: x + 1, y: line, str: 'ME')
    set_char(x: x + 2, y: line, str: ' O')
    set_char(x: x + 3, y: line, str: 'VE')
    set_char(x: x + 4, y: line, str: 'R ')
  end

  def game_over
    @game_over = true
  end

  def game_over?
    @game_over
  end

  def set_char(x:, y:, str:)
    render_field[x][y] = str
  end

  def generate_food
    @food = { x: rand(width), y: rand(height) }
  end

  def render_food
    set_char(x: @food[:x], y: @food[:y], str: '██')
  end

  def dispatch_input
    exit if input_character == 'q'
    @snake.up! if input_character == "\e[A"
    @snake.down! if input_character == "\e[B"
    @snake.left! if input_character == "\e[D"
    @snake.right! if input_character == "\e[C"
  end

  def refresh
    if input_character
      dispatch_input
      self.input_character = nil
    end
    clear_render_field
    @snake.step
    game_over if @snake.collide?
    if @snake.head[:x] == @food[:x] && @snake.head[:y] == @food[:y]
      @snake.eat!
      generate_food
    end

    @snake.render
    render_food
    render_game_over if game_over?
    render
    exit if game_over?
  end

  def render_stat
    print("Current step: #{@cur_step}\n\r")
    print("Score: #{@snake.length}\n\r")
  end

  def render
    clear
    render_stat
    print('╔═')
    width.times do |w|
      print('══')
    end
    print("═╗\n\r")

    height.times do |h|
      print('║ ')
      width.times do |w|
        print(render_field[w][h])
      end
      print(" ║\r\n")
    end

    print('╚═')
    width.times do |w|
      print('══')
    end
    print("═╝\n\r")
  end

  def clear
    print("\e[2J")
  end

  def exit
    Thread.kill(input_thread)
    show_cursor
    super.exit
  end

  def hide_cursor
    print("\e[?25l")
  end

  def clear_line
    print("\e[2K")
  end

  def show_cursor
    print("\e[?25h")
  end

  def run
    clear
    hide_cursor
    self.input_thread = Thread.new do
      loop do
        self.input_character = read_char
      end
    end
    loop do
      sleep @delay
      refresh
      @cur_step += 1
    end
  end

  private

  def read_char
    input = STDIN.getch
    input << STDIN.read_nonblock(2) if input == "\e"
    input
  end
end
