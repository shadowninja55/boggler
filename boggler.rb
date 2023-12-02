require "colorize"
require "io/console"
require "trie"

DICTIONARY = Trie.read "collins"
print "letters: "
BOARD = gets.chomp.chars.map.with_index { |c, i| [Complex(i % 4, i / 4), c] }.to_h
DIRECTIONS = [0-1i, 1-1i, 1+0i, 1+1i, 0+1i, -1+1i, -1+0i, -1-1i]

def search path, word
  solutions = []
  solutions << [path, word] if DICTIONARY.has_key? word
  return solutions if DICTIONARY.children(word).empty?
  solutions + (DIRECTIONS.map { path.last + _1 } - path)
    .intersection(BOARD.keys)
    .flat_map { search(path + [_1], word + BOARD[_1]) }
end

def highlight path, word
  canvas = BOARD.transform_values { _1.ljust 2 }
  path.each.with_index 1 do |point, n|
    canvas[point] = n.to_s.ljust(2).colorize :green
  end
  word + "\n\n" + canvas.values.each_slice(4).map { _1.join " " }.join("\n")
end

solutions = BOARD.keys
  .flat_map { search [_1], BOARD[_1] }
  .reject { _1.last.length < 3 }
  .uniq(&:last)
  .sort_by { _1.last.length }
  .reverse
height = `tput lines`.to_i
solutions.each_slice(height / 7) do |slice|
  $stdout.clear_screen
  print slice.map { highlight(*_1) }.join "\n\n"
  exit if $stdin.getch == "\x03"
end
