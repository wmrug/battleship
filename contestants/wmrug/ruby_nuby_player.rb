class Ship
  attr_accessor :known_direction, :coords

  def initialize(start_coord)
    @coords = []
    @coords << start_coord
    @known_direction = nil
  end

  def find_adjacent(state)
    if @known_direction == :horizontal
      return left_pin if left_pin and result(left_pin, state) == :unknown
      return right_pin if right_pin and result(right_pin, state) == :unknown
    elsif @known_direction == :vertical
      return lower_pin if lower_pin and result(lower_pin, state) == :unknown
      return upper_pin if upper_pin and result(upper_pin, state) == :unknown
    else
      #rotate
      return left_pin() if left_pin() and result(left_pin(), state) == :unknown
      return right_pin() if right_pin() and result(right_pin(), state) == :unknown
      return upper_pin() if upper_pin() and result(upper_pin(), state) == :unknown
      return lower_pin() if lower_pin() and  result(lower_pin(), state) == :unknown
      
    end

    return nil
  end

  def result(coord, state)
   return state[coord[1]][coord[0]]
  end

  def left_pin
    return nil if @coords.min[0] == 0
    return [@coords.min[0]-1, @coords.min[1]]
  end

  def right_pin
    return nil if @coords.max[0] == 9
    return [@coords.max[0]+1, @coords.max[1]]
  end
  
  def upper_pin
    return nil if @coords.min[1] == 0
    return [@coords.min[0], @coords.min[1]-1]
  end
  
  def lower_pin
    return nil if @coords.max[1] == 9
    return [@coords.max[0], @coords.max[1]+1]
  end

end

class RubyNubyPlayer
  def name
    "Ruby Nuby"
  end

  def initialize
    @current_move = nil
    @hunt_mode = :seek
    @known_ships = []
    @remaining_positions = [*0..9].collect{|x| [*0..9].collect{|y| [x,y]}}.flatten(1)
  end

  def new_game
    [
      [rand(4), rand(2), 5, :across],
      [rand(5), rand(2)+2, 4, :across],
      [rand(6), rand(2)+4, 3, :across],
      [rand(6), rand(3)+6, 3, :across],
      [9, rand(7), 2, :down]
    ]
  end

  def take_turn(state, ships_remaining)  
    @state = state
    if @current_move
		  last_result = state[@current_move[1]][@current_move[0]]
    end
    
    if @previous_ships_remaining and ships_remaining.length < @previous_ships_remaining.length
        @current_ship = nil
        last_result = :sunk
        @hunt_mode = :seek
    end


    if last_result == :hit
      if @current_ship
        @current_ship.coords << @current_move
        if @current_move[0] == @current_ship.coords.first[0]
          @current_ship.known_direction = :vertical
        else
          @current_ship.known_direction = :horizontal
        end
      else
        @current_ship = Ship.new(@current_move)       
      end

      @hunt_mode = :destroy
    end

    if last_result == :sunk and @known_ships.length>0
      @current_ship = @known_ships.pop
      @hunt_mode = :destroy
    end


    if @hunt_mode == :seek
      @current_move = seek()
    else 
      adjacent = @current_ship.find_adjacent(@state)
      if adjacent
        @current_move = adjacent
      else
        if @current_ship.known_direction == :horizontal
          new_direction = :vertical
        else
          new_direction = :horizontal
        end

        for c in @current_ship.coords do
          ship = Ship.new(c)
          ship.known_direction = new_direction
          @known_ships << ship
        end

        @current_ship = @known_ships.pop
        @current_move = @current_ship.find_adjacent(@state)
        
      end
    end

    @previous_ships_remaining = ships_remaining
    @remaining_positions.delete(@current_move)

    return @current_move
  end
  
  def seek()
    return @remaining_positions[rand(@remaining_positions.length-1)]
  end

end
