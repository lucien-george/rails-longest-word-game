require 'open-uri'
require 'json'
require 'time'

class GamesController < ApplicationController
  def new
    @start_time = Time.now
    @letters = ('a'..'z').to_a.sample(10)
  end

  def score
    @score = 0
    @end_time = Time.now
    @start_time = params[:start_time]
    @attempt = params[:guess]
    @letters = params[:letters].split(' ')
    @is_english_word = check_english_word?(@attempt)
    @is_in_grid = in_grid?(@attempt, @letters)
    @message = create_message(@is_in_grid, @is_english_word)
    @response_time = @end_time - Time.parse(@start_time)
    @score = (@attempt.length.fdiv(@letters.length) * 100).fdiv(@response_time).round(2) if @is_english_word && @is_in_grid
    if session[:score].nil?
      session[:score] = @score.round(2)
    else
      session[:score] += @score.round(2)
    end
  end

  def reset
    session[:score] = 0
    redirect_to :new
  end

  private

  def check_english_word?(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    result = JSON.parse(open(url).read)
    result['found']
  end

  def in_grid?(attempt, grid)
    attempt.chars.all? do |letter|
      grid.count(letter) >= attempt.chars.count(letter)
    end
  end

  def create_message(is_in_grid, is_english_word)
    return 'well done' if is_in_grid && is_english_word
    return 'the word you entered is not an english word' if is_in_grid && !is_english_word
    return 'the word you entered is not in the grid' unless is_in_grid
  end
end
