require_relative 'board'
require_relative 'tile'
require 'yaml'
require 'byebug'
require 'colorize'

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
    @selection = [0, 0]
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
      board.display

      stroke = get_char
      case stroke
      when /[wasd]/
        selection = move_selection(stroke)
        board.set_selection(selection)
      when "f"
        board.place_flag(selection)
      when " "
        board.make_move(selection)
        board.populate_mines(selection) unless board.populated?
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

  def make_selection(stroke)

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
  game.test
end
