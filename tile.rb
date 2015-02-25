class Tile
  attr_reader :neighbors

  def initialize(pos)
    @mine =     false
    @revealed = false
    @flagged =  false
    @x, @y = pos
    @neighbors = []
    @highlighted = false
  end

  def reveal
    @revealed = true
    if self.neighbor_bomb_count == 0 && !mine?
      applicable = @neighbors.reject do |neighbor|
        neighbor.mine? || neighbor.revealed? || neighbor.flag?
      end
      applicable.each { |neighbor| neighbor.reveal }
    end
  end

  def neighbor?(tile)
    @neighbors.include?(tile)
  end

  def populate_neighbors(board)
    shifts = [[-1, 0], [1, 0], [0, 1], [0, -1],
              [-1, 1], [-1, -1], [1, 1], [1, -1]]
    shifts.each do |x_shift, y_shift|
      coords = [@x + x_shift, @y + y_shift]
      @neighbors << board[coords] if board.in_bound?(coords)
    end
  end

  def neighbor_bomb_count
    neighbors.count { |neighbor| neighbor.mine? }
  end

  def mine?
    @mine
  end

  def set_mine
    @mine = true
  end

  def set_flag
    @flagged = true
  end

  def toggle_flag
    @flagged = !@flagged
  end

  def revealed?
    @revealed
  end

  def flag?
    @flagged
  end

  def set_highlight
    @highlighted = true
  end

  def remove_highlight
    @highlighted = false
  end

  def highlighted?
    @highlighted
  end

  def render
    char = if flag?
      "⚑".colorize(:red)
    elsif !revealed?
      " "
    elsif mine?
      #💣
      "X".colorize(:red)
    else
      neighbor_bomb_count == 0 ? " " : neighbor_bomb_count.to_s
    end
    if highlighted?
      " #{char} ".colorize(background: :light_yellow)
    elsif revealed? && !mine? && !flag?
      " #{char} ".colorize(color: :white, background: :light_blue)
    else
      " #{char} ".colorize(background: :white)
    end
  end

end
