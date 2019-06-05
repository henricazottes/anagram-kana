require "../anagram_finder.rb"
require 'minitest/autorun'


describe AnagramFinder do
  before do
    @anagram_finder  = AnagramFinder.new("africaacrobat", "../data/wordlist.txt", false)
    @anagrams = @anagram_finder.find_anagrams
  end

  describe "When word list is loaded in dictionary" do
    it "must not be empty" do
      @anagram_finder.dictionary.length.must_be :>, 0
    end
  end

  describe "When differentiating 'aabbccdd' and 'abcd'" do
    it "must equal the remaining letters 'abcd'" do
      @anagram_finder.substract("aabbccdd", "abcd").must_equal "abcd"
    end
  end

  describe "When differentiating 'aabbccdd' and 'dcba'" do
    it "must also equal the remaining letters 'abcd'" do
      @anagram_finder.substract("aabbccdd", "dcba").must_equal "abcd"
    end
  end

  describe "When anagrams are found" do
    it "must contains words of the dictionary" do
      @anagram_finder.are_pairs_in_wordlist?(@anagrams).must_equal true
    end
  end

  describe "When anagrams are found" do
    it "must contains words of the dictionary" do
      @anagram_finder.are_pairs_in_wordlist?([["", ""]]).must_equal false
    end
  end

  describe "When anagrams are found" do
    it "must use all letters of the target" do
      @anagram_finder.are_pairs_using_all_letters?(@anagrams).must_equal true
    end
  end

  describe "When anagrams are found" do
    it "must use all letters of the target" do
      @anagram_finder.are_pairs_using_all_letters?([["", ""]]).must_equal false
    end
  end
end