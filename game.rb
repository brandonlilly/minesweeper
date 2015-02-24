require_relative 'board'
require_relative 'tile'
require 'yaml'
require 'byebug'
require 'colorize'

class Game
  attr_reader :board

  def initialize
    @board = Board.new(9, 9, 10)
  end

  def run
    until won? || lost?
      board.display

      move = get_move(board)
      board.populate_mines(move) unless board.populated?
      if move.last
        board.place_flag(move)
      else
        board.make_move(move)
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

  def get_move(board)
    loop do
      puts "Make a choice"
      input = gets.chomp.downcase
      if input[/\d+.*\d/]
        flag = (input[0] == "f")
        coords = input.scan(/\d+/).map {|n| n.to_i - 1}.first(2) << flag
        return coords if board.in_bound?(coords)
      elsif input.include?('save')
        name = input.split(' ').last
        save(name)
        next
      elsif input.include?('load')
        name = input.split(' ').last
        load(name)
        next
      end
      puts "Invalid move"
    end
  end

  def save(name)
    puts "Saving game '#{name}'..", ' '
    File.write(save_path(name), @board.to_yaml)
  end

  def load(name)
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
