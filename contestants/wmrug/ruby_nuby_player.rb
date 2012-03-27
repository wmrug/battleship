class Ship
  attr_accessor :known_direction, :coords

  def initialize(start_coords)
    if (start_coords.flatten.count==2)
      @coords = [start_coords.flatten]
    else
      @coords = start_coords
    end
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
      return left_pin if left_pin and result(left_pin, state) == :unknown
      return right_pin if right_pin and result(right_pin, state) == :unknown
      return upper_pin if upper_pin and result(upper_pin, state) == :unknown
      return lower_pin if lower_pin and  result(lower_pin, state) == :unknown
      
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
        @current_ship.coords << @current_move
        a = @previous_ships_remaining
        @length_of_sunken_ship = 
          a[a.map{|v| a.count(v) != ships_remaining.count(v)}.index(true)]

        if @length_of_sunken_ship != @current_ship.coords.count
          if @current_move <=> @previous_move = 1
            @known_ships <<
              Ship.new(@current_ship.coords.sort.last(@current_ship.coords.count - @length_of_sunken_ship))
          else
            @known_ships << 
              Ship.new(@current_ship.coords.sort.first(@current_ship.coords.count - @length_of_sunken_ship))
          end
          #raise "sunk a ship of length #{@length_of_sunken_ship}. New ship at #{@current_ship.coords.inspect}"
          @hunt_mode = :destroy
        else
          @current_ship = nil
          @hunt_mode = :seek
        end
        
        last_result = :sunk
    end

    @previous_move = @current_move

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
        @hunt_mode = :destroy
      end
    end

    if last_result == :sunk and @known_ships.length>0
      @current_ship = @known_ships.pop
      @hunt_mode = :destroy
    end


    if @hunt_mode == :seek
      @current_move = seek(ships_remaining)
    else 
      adjacent = @current_ship.find_adjacent(@state)
      if adjacent
        @current_move = adjacent
      else
        #raise "changing direction: #{@current_ship.coords.inspect}"
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

    raise "Ship: #{@current_ship.inspect} Last Move: #{@previous_move.inspect}" unless @current_move
    return @current_move
  end
  
  def seek(ships_remaining)
    coord = nil
    while coord == nil
      coord = @remaining_positions[rand(@remaining_positions.length-1)]
      raise "remaining: #{@remaining_positions.inspect}" unless coord
      if not can_fit_ship(coord, ships_remaining.min)
        @remaining_positions.delete(coord)
        coord = nil
      end
    end
    return coord
  end

  def can_fit_ship(coord, length)

    pin_index = (0..coord.first-1).map{|i| @state[coord.last][i] != :unknown }.rindex(true)
    spaces_left = pin_index ? coord.first - pin_index - 1 : coord.first

    spaces_right = (coord.first+1..9).map{|i| @state[coord.last][i] != :unknown }.index(true) || 9-coord.first

    pin_index = (0..coord.last-1).map{|i| @state[i][coord.first] != :unknown }.rindex(true)
    spaces_above = pin_index ? coord.last - pin_index -1 : coord.last

    spaces_below = (coord.last+1..9).map{|i| @state[i][coord.first] != :unknown }.index(true) || 9-coord.last


    if spaces_above + spaces_below + 1 < length and spaces_left + spaces_right + 1 < length
      return false
    end

    return true
  end
end
