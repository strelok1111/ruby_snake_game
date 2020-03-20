class Snake
  attr_reader :segments
  attr_reader :app
  attr_reader :length
  def initialize(app)
    @app = app
    @length = 4
    @head_x = 10
    @head_y = 10
    @direction = :up
    @segments = []
    @length.times do |l|
      @segments[l] = {
        x: @head_x,
        y: @head_y + l
      }
    end
  end

  def step
    new_x = @head_x
    new_y = @head_y
    new_y -= 1 if @direction == :up
    new_y += 1 if @direction == :down
    new_x -= 1 if @direction == :left
    new_x += 1 if @direction == :right
    return if collide_check(x: new_x, y: new_y)

    @head_x = new_x
    @head_y = new_y
    @segments.unshift(x: @head_x, y: @head_y)
    @segments.pop
  end

  def up!
    @direction = :up if @direction != :down
  end

  def left!
    @direction = :left if @direction != :right
  end

  def right!
    @direction = :right if @direction != :left
  end

  def down!
    @direction = :down if @direction != :up
  end

  def render
    @segments.each do |seg|
      app.set_char(x: seg[:x], y: seg[:y], str: '██')
    end
  end

  def head
    {
      x: @head_x,
      y: @head_y
    }
  end

  def collide?
    @collide
  end

  def eat!
    @length += 1
    @segments.unshift(x: @head_x, y: @head_y)
  end

  private

  def collide_check(x:, y:)
    @collide = x.negative? || y.negative? || x >= app.width || y >= app.height || @segments.any? { |seg| seg[:x] == x && seg[:y] == y }
  end
end
