require "msgpack"

class Save

  attr_reader :word

  def initialize(index)
    @index = index
    @word = ""
    @guessed_letters = []
    @guessed_incorrect = 0

    load
  end

  def load
    filename = get_filename
    return unless File.exist? filename

    file = File.read(filename).chomp
    obj = MessagePack.unpack(file)

    @word = obj["word"]
    @guessed_letters = obj["letters"]
    @guessed_incorrect = obj["incorrect"]
  end

  def save
    obj = MessagePack.pack({
      :word => @word,
      :letters => @guessed_letters,
      :incorrect => @guessed_incorrect
    })

    filename = get_filename
    File.open(filename, "w") do |file|
      file.puts obj
    end
  end

  def delete
    filename = get_filename
    File.delete(filename) if File.exist?(filename)
  end

  def get_summary
    slot_number = (@index + 1).to_s
    if @word != ""
      board = get_board
      guesses = "Guesses Left: " + get_remaining_guesses.to_s
      remaining_space = 47 - board.length - guesses.length
      padding = "".rjust(remaining_space, " ")
      "  | #{slot_number}. #{board} - #{guesses} #{padding}|"
    else
      "  | #{slot_number}. New Game                                           |"
    end
  end

  def get_board
    board = []
    @word.each_char do |c|
      if guessed?(c)
        board << c.upcase
      else
        board << "_"
      end
    end
    board.join(" ")
  end

  def get_guessed
    @guessed_letters.join(" ")
  end

  def get_remaining_guesses
    6 - @guessed_incorrect
  end

  def guessed?(char)
    @guessed_letters.include?(char)
  end

  def guess(char)
    @guessed_letters << char
    @guessed_incorrect += 1 unless @word.include?(char)
  end

  def generate_word
    return if !File.exist? "words.txt"

    file = File.open("words.txt", "r")
    words = file.readlines
    words = words.select { |w| w.length >= 5 && w.length <= 12 }

    random_index = rand(words.length)
    @word = words[random_index].chomp
  end

  def get_filename
    "save#{@index}.txt"
  end

  def won?
    won = true
    @word.each_char do |c|
      won = false unless guessed?(c)
    end
    won
  end

end