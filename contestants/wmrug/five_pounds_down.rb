class Move
  attr_accessor :x, :y, :state, :previous_move, :ships_remaining
  MIN_SIZE = 0
  MAX_SIZE = 9

  def initialize(state, ships_remaining, previous_move=nil)
    self.state = state
    if previous_move
      self.previous_move = previous_move
      self.previous_move.state = nil
    end
    self.ships_remaining = ships_remaining
    puts self.inspect
  end

  def make_move
    hit_chain = previous_move.hit_chain_from if previous_move
    arr = if hit_chain
            chain_x = hit_chain[0]
            chain_y = hit_chain[1]
            circle_around(chain_x, chain_y)
          else
            find_optimum_move
          end
    self.x = arr[0]
    self.y = arr[1]
    [x,y]
  end

  def find_optimum_move
    remaining_moves = []
    (0..9).each do |i|
      (0..9).each do |j|
        if state[j][i] == :unknown
          remaining_moves << [i,j]
        end
      end
    end
    biggest_ship = ships_remaining.max
    optimum_moves = remaining_moves.collect {|m| can_be_occupied_by_ship?(state, m, biggest_ship)}
    remaining_moves[rand(optimum_moves.length - 1)]
  end


  def hit_chain_from(move=nil)
    move ||= previous_move
    while move
      if move.hit?
        if !move.sunk_ship?
          return [move.x, move.y]
        else
          return nil
        end
      else
        hit_chain_from(move.previous_move)
      end
    end
  end

  def circle_around(chain_x, chain_y)
    # NORTH
    upcoming_move = [chain_x, chain_y - 1]
    return upcoming_move if valid_move?(upcoming_move[0], upcoming_move[1])
    # EAST
    upcoming_move = [chain_x + 1, chain_y]
    return upcoming_move if valid_move?(upcoming_move[0], upcoming_move[1])
    # SOUTH
    upcoming_move = [chain_x, chain_y + 1]
    return upcoming_move if valid_move?(upcoming_move[0], upcoming_move[1])
    # WEST
    upcoming_move = [chain_x - 1, chain_y]
    return upcoming_move if valid_move?(upcoming_move[0], upcoming_move[1])
  end

  def sunk_ship?
    state == :hit && ships_remaining != previous_move.ships_remaining
  end

  def hit?
    state == :hit
  end

  def miss?
    state == :miss
  end

  def valid_move?(next_x, next_y)
    state[next_y, next_x] == :unknown &&
      next_x >= MIN_SIZE &&
      next_x <= MAX_SIZE &&
      next_y >= MIN_SIZE &&
      next_y <= MAX_SIZE
  end

  def can_be_a_ship?(state, x, y)
    return false unless (0..9).include?(x) && (0..9).include?(y)
    state[y,x] != :miss
  end

  def find_space_on_the_left(state, x, y)
    return 0 if x == 0
    return 4 if can_be_a_ship?(state, x-4, y) && can_be_a_ship?(state, x-3, y) && can_be_a_ship?(state, x-2, y) && can_be_a_ship?(state, x-1, y)
    return 3 if can_be_a_ship?(state, x-3, y) && can_be_a_ship?(state, x-2, y) && can_be_a_ship?(state, x-1, y)
    return 2 if can_be_a_ship?(state, x-2, y) && can_be_a_ship?(state, x-1, y)
    return 1 if can_be_a_ship?(state, x-1, y)
  end

  def find_space_on_the_right(state, x, y)
    return 0 if x == 9
    return 4 if can_be_a_ship?(state, x+4, y) && can_be_a_ship?(state, x+3, y) && can_be_a_ship?(state, x+2, y) && can_be_a_ship?(state, x+1, y)
    return 3 if can_be_a_ship?(state, x+3, y) && can_be_a_ship?(state, x+2, y) && can_be_a_ship?(state, x+1, y)
    return 2 if can_be_a_ship?(state, x+2, y) && can_be_a_ship?(state, x+1, y)
    return 1 if can_be_a_ship?(state, x+1, y)
  end

  def find_space_on_the_top(state, x, y)
    return 0 if y == 0
    return 4 if can_be_a_ship?(state, x, y-4) && can_be_a_ship?(state, x, y-3) && can_be_a_ship?(state, x, y-2) && can_be_a_ship?(state, x, y-1)
    return 3 if can_be_a_ship?(state, x, y-3) && can_be_a_ship?(state, x, y-2) && can_be_a_ship?(state, x, y-1)
    return 2 if can_be_a_ship?(state, x, y-2) && can_be_a_ship?(state, x, y-1)
    return 1 if can_be_a_ship?(state, x, y-1)
  end

  def find_space_on_the_bottom(state, x, y)
    return 0 if y == 9
    return 4 if can_be_a_ship?(state, x, y+4) && can_be_a_ship?(state, x, y+3) && can_be_a_ship?(state, x, y+2) && can_be_a_ship?(state, x, y+1)
    return 3 if can_be_a_ship?(state, x, y+3) && can_be_a_ship?(state, x, y+2) && can_be_a_ship?(state, x, y+1)
    return 2 if can_be_a_ship?(state, x, y+2) && can_be_a_ship?(state, x, y+1)
    return 1 if can_be_a_ship?(state, x, y+1)
  end

  def can_be_occupied_by_ship?(state, position, ship_size)
    space_on_the_left = find_space_on_the_left(state, position[0], position[1])
    space_on_the_right = find_space_on_the_right(state, position[0], position[1])
    space_on_the_top = find_space_on_the_top(state, position[0], position[1])
    space_on_the_bottom = find_space_on_the_bottom(state, position[0], position[1])
    return space_on_the_left + 1 + space_on_the_right >= ship_size || space_on_the_top + 1 + space_on_the_bottom >= ship_size
  end


end


class MinimumPlayer
  def name
    "five pounds down."
  end

  attr_accessor :move_tail

  def new_game
    [
     [0, 0, 5, :down],
     [4, 4, 4, :across],
     [9, 3, 3, :down],
     [2, 2, 3, :across],
     [9, 7, 2, :down]
    ]

  end

  def take_turn(state, ships_remaining)
    move = Move.new(state, ships_remaining, self.move_tail)
    move.make_move
  end

end
