class Shot
  attr_accessor :x, :y
  def initialize(x,y)
    @x,@y = x,y
  end
end
class TwoMinutesToChocolatePlayer
  PROBABILTY_STEP = 100000
  PROBABILTY_INITIAL_VALUE = 1


  def initialize
    # @file = File.new("/Users/andy/code/battleship/contestants/wmrug/battleship.log", "w")
    @last_game = nil
    @last_shot = nil
    @probability_grid = Array.new
    10.times do |x|
        @probability_grid[x] = Array.new
      10.times do |y|
        @probability_grid[x][y] = PROBABILTY_INITIAL_VALUE
      end
    end

    # @state = []
    # @ships_remaining = []
  end

  def name
    # Uniquely identify your player
    "Two Minutes To Chocolate"
  end

  def new_game
    if @last_game.nil? || @last_game.size < 3
      [
        [1, 1, 5, :across],
        [9, 0, 4, :down],
        [4, 2, 3, :down],
        [6, 8, 3, :across],
        [9, 4, 2, :down]
      ]
    else # we did shit
      [
        [3, 0 , 5, :down],
        [6, 0, 4, :down],
        [0, 0, 3, :down],
        [2, 8, 3, :across],
        [9, 1, 2, :down]
      ]
    end
  end

  def take_turn(state, ships_remaining)
    update_probability_grid(state)
    @last_shot = roulette_selection
    @last_game = ships_remaining
    # state, ships_remaining = state, ships_remaining
    # [
    #   [:miss, :unknown, :unknown, :unknown, :unknown,:unknown, :unknown, :unknown, :unknown, :unknown]
    #   [:unknown, :unknown, :unknown, :unknown, :unknown,:unknown, :unknown, :unknown, :unknown, :unknown]
    #   [:unknown, :unknown, :unknown, :unknown, :unknown,:unknown, :unknown, :unknown, :unknown, :unknown]
    #   [:unknown, :unknown, :unknown, :unknown, :unknown,:unknown, :unknown, :unknown, :unknown, :unknown]
    #   [:unknown, :unknown, :unknown, :unknown, :unknown,:unknown, :unknown, :unknown, :unknown, :unknown]
    #   [:unknown, :unknown, :unknown, :unknown, :unknown,:unknown, :unknown, :unknown, :unknown, :unknown]
    #   [:unknown, :unknown, :unknown, :unknown, :unknown,:unknown, :unknown, :unknown, :unknown, :unknown]
    #   [:unknown, :unknown, :unknown, :unknown, :unknown,:unknown, :unknown, :unknown, :unknown, :unknown]
    #   [:unknown, :unknown, :unknown, :unknown, :unknown,:unknown, :unknown, :unknown, :unknown, :unknown]
    # ]
    # [5,4,3,3,2]
    # [5,4,3,3]
    # [5,4,3,3,2]
    # 0,0   1,0    2,0              0,1       1,1       2,1
    # state is the known state of opponents fleet
    # ships_remaining is an array of the remaining opponents ships

    # return [x,y] # your next shot co-ordinates
    return [@last_shot.x, @last_shot.y]
  end

  def update_probability_grid(state)
    return if @last_shot.nil?
    # @file.puts "updating grid"
    @probability_grid[@last_shot.x][@last_shot.y] = 0
    # @file.write state
    # @file.puts @last_shot.x
    # @file.puts @last_shot.y
    if state[@last_shot.x][@last_shot.y] == :hit
      # @file.puts "-------------"
      # @file.puts "HIT!"
      # @file.puts "-------------"
      # @file.puts "BEFORE:" + @probability_grid[@last_shot.x][@last_shot.y - 1].to_s
      # @file.puts "-------------"
      if @probability_grid[@last_shot.x][@last_shot.y - 1]
        @probability_grid[@last_shot.x][@last_shot.y - 1] += PROBABILTY_STEP unless @probability_grid[@last_shot.x][@last_shot.y - 1] ==0
      end
      # @file.puts "AFTER:" + @probability_grid[@last_shot.x][@last_shot.y - 1].to_s
      # @file.puts "-------------"
      if @probability_grid[@last_shot.x][@last_shot.y + 1]
        @probability_grid[@last_shot.x][@last_shot.y - 1] += PROBABILTY_STEP unless @probability_grid[@last_shot.x][@last_shot.y + 1] ==0
      end
      if @probability_grid[@last_shot.x - 1][@last_shot.y]
        @probability_grid[@last_shot.x - 1][@last_shot.y] += PROBABILTY_STEP unless @probability_grid[@last_shot.x - 1][@last_shot.y] ==0
      end
      if @probability_grid[@last_shot.x + 1][@last_shot.y]
        @probability_grid[@last_shot.x + 1][@last_shot.y] += PROBABILTY_STEP unless @probability_grid[@last_shot.x + 1][@last_shot.y] ==0
      end
    end
    # @file.flush
  end

  def roulette_selection
    max_value = 0
    probability_list = []
    10.times do |x|
      10.times do |y|
        max_value += @probability_grid[x][y]
        probability_list << {value: @probability_grid[x][y], position_x: x, position_y: y}
      end
    end
    # probability_list.each {|i| @file.puts i if i[:value] > 1 }
    # @file.puts probability_list
    probability_list.sort_by! {|item| item[:value] }.reverse!
    # @file.puts probability_list
    random_number = rand(max_value)
    running_total = 0
    current_position = 0
    probability_list.each do |item|
      running_total += item[:value]
      if running_total > random_number
        return Shot.new(item[:position_x], item[:position_y])
      end
    end
  end
end