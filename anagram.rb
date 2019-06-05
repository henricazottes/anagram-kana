require 'minitest/autorun'
require 'time'

class Anagram
  attr_reader :model, :anagrams

  def initialize(model="documenting")
    @@dictionary = parse_dictionary
    @model = model
    @anagrams = find_anagrams
  end

  def parse_dictionary
    wordlist_file = File.open("english_dictionary.txt")
    wordlist_file.read().split(" ")
  end

  def dictionary
    @@dictionary
  end

  def sort_word_letters(word)
    word.downcase.chars.sort.join
  end

  def diff_words(word1, word2)
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

  def find_anagrams
    anagrams_found        = []
    model_length          = @model.length
    counter               = 0
    progression           = 0.0
    possible_first_words  = @@dictionary.select {|item| item.length < model_length}.
                                         select {|item| !(item.chars.uniq & model.chars.uniq).empty?}
    total_words           = possible_first_words.count

    puts "Total words: #{total_words}."
    puts "Progression: #{progression}%."

    tstart     = Time.now
    tend       = tstart
    titeration = tstart

    possible_first_words.each_with_index do |first_word, index|
      counter += 1

      if counter >= 1000
        tend    = Time.now
        delta   = tend - titeration
        titeration  = tend
        counter = 0
        progression += (1000.0*100.0/(total_words))
        puts "Progression: #{progression.round(2)}% done in #{delta.round(2)}s."
      end

      if include_letters? model, first_word
        model_letters_left    = diff_words model, first_word
        possible_second_word  = possible_first_words[index..-1].select {|item| item.length == model_letters_left.length}.
                                                                select {|item| !(item.chars.uniq & model_letters_left.chars.uniq).empty?}

        possible_second_word.each do |second_word|
          extra_letters = diff_words model_letters_left, second_word
          if (model_letters_left.include? second_word) && extra_letters.length.equal?(0)
            anagrams_found.push [first_word, second_word]
          end
        end
      end

    end

    puts "Done in #{(tend-tstart).round(2)}s."
    anagrams_found
  end

  # Tests utils

  def are_pairs_in_wordlist?
    anagrams_found = anagrams
    anagrams.reduce(true) do |memo, anagram|
      memo && (@@dictionary.include? anagram[0]) && (@@dictionary.include? anagram[1])
    end
  end

  def are_pairs_using_all_letters?
    anagrams_found = anagrams
    anagrams.reduce(true) do |memo, anagram|
      sorted_pair = sort_word_letters anagram[0] + anagram[1]
      sorted_model = sort_word_letters @model
      memo && (sorted_model == sorted_pair)
    end
  end

end

anagram = Anagram.new("elephant")
puts "\n#{anagram.anagrams.count} anagrams found for #{anagram.model}."
anagram.anagrams.each do |anagram|
  puts "- #{anagram[0]}/#{anagram[1]}"
end


##
#  Tests
##


describe Anagram do
  before do
    @anagram = Anagram.new
  end

  describe "When word list is loaded in dictionary" do
    it "must not be empty" do
      @anagram.dictionary.length.must_be :>, 0
    end
  end

  describe "When differentiating 'aabbccdd' and 'abcd'" do
    it "must equal the remaining letters 'abcd'" do
      @anagram.diff_words("aabbccdd", "abcd").must_equal "abcd"
    end
  end

  describe "When differentiating 'aabbccdd' and 'dcba'" do
    it "must also equal the remaining letters 'abcd'" do
      @anagram.diff_words("aabbccdd", "dcba").must_equal "abcd"
    end
  end

  describe "When anagrams are found" do
    it "must contains word of the dictionary" do
      @anagram.are_pairs_in_wordlist?.must_equal true
    end
  end

  describe "When anagrams are found" do
    it "must use all letters of the model" do
      @anagram.are_pairs_using_all_letters?.must_equal true
    end
  end
end

