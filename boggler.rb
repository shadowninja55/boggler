require "trie"
require "colorize"

DICTIONARY = Trie.new
File.readlines("collins.txt").each { DICTIONARY.add _1.chomp }

print "letters: "
BOARD = gets.chomp.chars.map.with_index { |c, i| [Complex(i % 4, i / 4), c] }.to_h
DIRECTIONS = [0-1i, 1-1i, 1+0i, 1+1i, 0+1i, -1+1i, -1+0i, -1-1i]

def search path, word
  solutions = []
  solutions << [path, word] if DICTIONARY.has_key? word
  return solutions if DICTIONARY.children(word).empty?
  solutions += (DIRECTIONS.map { path.last + _1 } - path)
    .intersection(BOARD.keys)
    .flat_map { search(path + [_1], word + BOARD[_1]) }
  solutions
end

def highlight path, word
  canvas = BOARD.clone
  path.each do |point|
    canvas[point] = canvas[point].colorize(:green)
  end
  word + "\n\n" + canvas.values.each_slice(4).map { _1.join(" ") }.join("\n")
end

BOARD.keys
  .flat_map { search [_1], BOARD[_1] }
  .reject { _1.last.length < 3 }
  .uniq(&:last)
  .sort_by { _1.last.length }
  .each { puts highlight(*_1) + "\n\n" }
