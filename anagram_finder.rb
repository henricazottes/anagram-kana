require 'time'

class AnagramFinder
  attr_reader :target, :dictionary

  def initialize(target="documenting", source_file="data/english_dictionary.txt", do_log=true)
    @dictionary = parse_dictionary source_file
    @target      = target
    @do_log      = do_log
    @progression = 0.0
    @total_words = 0
    @counter     = 0
  end

  ##
  #  Utils
  ##

  def parse_dictionary(source_file)
    wordlist_file = File.open(source_file)
    wordlist_file.read().split(" ")
  end

  def puts_log(string)
    puts string if @do_log
  end

  def print_log(string)
    print string if @do_log
  end

  def sort_letters(word)
    word.downcase.chars.sort.join
  end

  def substract(word1, word2)
    letters1 = word1.chars
    letters2 = word2.chars

    letters2.each do |letter|
      letters1.delete_at letters1.index(letter) unless letters1.index(letter).nil?
    end

    letters1.join
  end

  def include_letters?(word1, word2)
    letters1 = word1.chars
    letters2 = word2.chars
    result   = true

    letters2.uniq.each do |letter|
      if !(letters1.count(letter) >= letters2.count(letter))
        result = false
        break
      end
    end

    result
  end

  ##
  # Tests utils
  ##

  def are_pairs_in_wordlist?(anagrams)
    anagrams.reduce(true) do |memo, anagram|
      memo && (@dictionary.include? anagram[0]) && (@dictionary.include? anagram[1])
    end
  end

  def are_pairs_using_all_letters?(anagrams)
    anagrams.reduce(true) do |memo, anagram|
      sorted_pair   = sort_letters (anagram[0] + anagram[1])
      sorted_target = sort_letters @target
      memo && (sorted_target == sorted_pair)
    end
  end

  def handle_progression
    if @counter >= 1000
      @counter = 0
      @progression += (1000.0*100.0/(@total_words))
      print_log "\rProgression: [#{"="*@progression.floor}#{" "*(100-@progression)}]"
    end
    @counter += 1
  end

  def display_results(anagrams_found, tstart, tend)
    tend    = Time.now
    puts_log ""
    anagrams_found.each do |anagram|
      puts_log "- #{anagram[0]}/#{anagram[1]}"
    end
    puts_log "\nDone in #{(tend-tstart).round(2)}s."
    puts_log "#{anagrams_found.count} anagrams found for #{@target}."
  end

  ##
  #  Core algorithm
  ##

  def find_anagrams
    possible_first_words  = @dictionary.select {|word| word.length < @target.length}.
                                         select {|word| (word.chars.uniq - target.chars.uniq).empty?}
    anagrams_found        = []
    tstart                = Time.now
    @progression          = 0.0
    @total_words          = possible_first_words.count

    possible_first_words.each_with_index do |first_word, index|
      handle_progression

      if include_letters? target, first_word
        target_letters_left   = substract target, first_word
        possible_second_word  = possible_first_words[index..-1].
                                  select {|word| word.length == target_letters_left.length}.
                                  select {|word| (word.chars.uniq - target_letters_left.chars.uniq).empty?}

        possible_second_word.each do |second_word|
          extra_letters = substract target_letters_left, second_word
          if (target_letters_left.include? second_word) && extra_letters.length.equal?(0)
            anagrams_found.push [first_word, second_word]
          end
        end
      end
    end

    tend = Time.now
    display_results anagrams_found, tstart, tend

    anagrams_found
  end
end
