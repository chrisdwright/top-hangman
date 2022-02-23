require "./save"

class Hangman

  def initialize
    load_saves
    show_menu
  end

  def load_saves
    @saves = []
    3.times do |i|
      save = Save.new(i)
      @saves << save
    end
  end

  def show_menu
    system("clear")
    load_saves

    print "\n"
    puts "  +======================= Hangman =======================+"

    @saves.each { |save| puts save.get_summary }

    puts "  | 4. Quit                                               |"
    puts "  +=======================================================+"

    loop do
      print "  Select option: "
      save_number = gets.chomp.to_i

      if save_number.between?(1, 3)
        start_game(save_number - 1)
        break
      elsif save_number == 4
        return
      else
        puts "Selection must be between 1-4. Try again."
      end
    end
  end

  def start_game(save_index)
    @save = @saves[save_index]

    if @save.word == ""
      @save.generate_word 
      @save.save
    end

    @quit_game = false
    loop do
      system("clear")

      print "\n\n"
      puts "    Here is your word:"
      print "\n"
      puts "    " + @save.get_board
      print "\n"
      puts "    You have guessed: " + @save.get_guessed
      puts "    You have #{@save.get_remaining_guesses.to_s} guess(es) remaining."
      print "\n"
      print "    Type 'quit' to quit.\n"

      letter = ""
      loop do
        print "    Guess a letter: "
        letter = gets.chomp.strip.downcase

        if letter == "quit"
          @quit_game = true
          break
        elsif letter.length == 1 && letter.match?(/\A[a-z]*\z/)
          break unless @save.guessed?(letter)
        end
      end

      if @quit_game
        puts "\n    Thanks for playing!\n"
        break
      else
        @save.guess(letter)
        @save.save
        if @save.get_remaining_guesses == 0
          print "\n    No guesses remaining. You lose!\n\n"
          @save.delete
          break
        elsif @save.won?
          print "\n    You guessed them all. You won!\n\n"
          @save.delete
          break
        end
      end
    end
  end



end

game = Hangman.new