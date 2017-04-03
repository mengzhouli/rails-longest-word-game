require 'open-uri'
require 'json'
require 'time'

WORDS = File.read('/usr/share/dict/words').upcase.split("\n")

class WordController < ApplicationController
  def game
    @grid = (0...9).map { (65 + rand(26)).chr }
  end

  def score
    @start = params[:start].to_datetime
    @end = Time.now
    @attempt = params[:guess]
    @grid = params[:grid]
    @results = run_game(@attempt, @grid, @start, @end)
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    if !WORDS.include?(attempt.upcase)
      { translation: nil, score: 0, message: "not an english word" }
    elsif in_grid?(attempt.upcase, grid) == false
      { translation: nil, score: 0, message: "not in the grid" }
    else
      translation = translate(attempt)
      total = -(end_time - start_time).to_i + attempt.length
      { time: end_time - start_time, translation: translation, score: total, message: "well done" }
    end
  end

  def in_grid?(word, grid)
    word.each_char do |c|
      if grid.include?(c)
        grid.delete(c)
      else
        return false
      end
      # goes through each character and deletes it from grid or return false
    end
  end

  def translate(word)
    u = "https://api-platform.systran.net/translation/text/translate?"\
    "source=en&target=fr&key=249325a4-939b-49d5-9627-214d15bd92ef&input=#{word}"
    puts u
    json = JSON.parse(open(u).read)
    translation = json["outputs"][0]["output"]
    translation
    # stores json as a hash file
  end
end
