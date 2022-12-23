require "trie"
require "colorize"

DICTIONARY = Trie.new
File.readlines("collins.txt").each { DICTIONARY.add _1.chomp }

print "letters: "
BOARD = gets.chomp.chars.map.with_index { |c, i| [Complex(i % 4, i / 4), c] }.to_h
DIRECTIONS = [0-1i, 1-1i, 1+0i, 1+1i, 0+1i, -1+1i, -1+0i, -1-1i]

def search start
  stack = [[[start], BOARD[start]]]
  solutions = []
  until stack.empty? do
    path, word = stack.pop 
    solutions.push [path, word] if DICTIONARY.has_key?(word)
    next if DICTIONARY.children(word).empty?
    curr = path.last
    DIRECTIONS.each do |direction|
      neighbor = curr + direction
      stack.push [path + [neighbor], word + BOARD[neighbor]] if BOARD.has_key? neighbor and not path.include? neighbor
    end
  end
  solutions
end

def highlight path, word
  board = BOARD.clone
  path.each do |point|
    board[point] = board[point].colorize(:green)
  end
  word + "\n\n" + board.values.each_slice(4).map { _1.join(" ") }.join("\n")
end

solutions = BOARD.keys
  .flat_map { search _1 }
  .reject { _1.last.length < 3 }
  .uniq(&:last)
  .sort_by { _1.last.length }
solutions.each { puts highlight(*_1) + "\n\n" }
