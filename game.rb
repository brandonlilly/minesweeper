require_relative 'board'
require_relative 'tile'
require 'yaml'
require 'colorize'
require 'byebug'

def get_char
  state = `stty -g`
  `stty raw -echo -icanon isig`

  STDIN.getc.chr
ensure
  `stty #{state}`
end

class Game
  attr_reader :board

  def initialize
    @board = Board.new(9, 9, 10)
    @selection = [1, 1]
  end

  def test
    loop do
      stroke = get_char
      p stroke
      exit if stroke == "\e"
    end
  end

  def run

    until won? || lost?
      board.set_selection(@selection)
      board.display

      stroke = get_char
      case stroke
      when /[wasd]/
        move_selection(stroke)
      when "f"
        board.place_flag(@selection)
      when "\r", "e", " "
        board.populate_mines(@selection) unless board.populated?
        board.make_move(@selection)
      when "\u0013" # ctrl-s
        save
      when "\f"
        load
      end
    end

    board.tiles.each { |tile| tile.reveal if tile.mine? } if lost?
    board.tiles.each { |tile| tile.set_flag if tile.mine? } if won?
    board.display

    puts "That's too bad" if lost?
    puts "You won!" if won?
  end

  def won?
    @board.tiles.each do |tile|
      return false if !tile.mine? && !tile.revealed?
    end
    true
  end

  def lost?
    @board.tiles.any? { |tile| tile.mine? && tile.revealed? }
  end

  def move_selection(stroke)
    offsets = {
      w: [0, 1],
      a: [-1,0],
      s: [0,-1],
      d: [1, 0]
    }
    stroke = stroke.to_sym
    x, y = @selection
    x_shift, y_shift = offsets[stroke]
    pos = [x + x_shift, y + y_shift]
    @selection = pos if @board.in_bound?(pos)
  end

  def save(name = "default")
    puts "Saving game '#{name}'..", ' '
    File.write(save_path(name), @board.to_yaml)
  end

  def load(name = "default")
    path = save_path(name)
    if File.exist?(path)
      puts "Loading game '#{name}'..", ' '
      contents = File.read(path)
      @board = YAML::load(contents)
      @board.display
    else
      puts "Cannot find load file '#{name}'"
    end
  end

  private

    def save_path(name)
      "saves/#{name}.yml"
    end

end

if __FILE__ == $PROGRAM_NAME
  game = Game.new
  game.run
end
