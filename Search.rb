module Helper
  
  INPUT_SEPRATOR = " "
  PAGE = "p"
  QUERY = "q"

  def self.user_input
    user_input = { pages_keywords: [], queries_keywords: [] }
    
    input = read_from_command_line
    array_of_strings = convert_input_to_array_of_strings(input)

    until array_of_strings.empty? 
      if array_of_strings.first.downcase == PAGE
        user_input[:pages_keywords].push(array_of_strings.drop(1)) 
      elsif array_of_strings.first.downcase == QUERY
        user_input[:queries_keywords].push(array_of_strings.drop(1))
      end
      input = read_from_command_line
      array_of_strings = convert_input_to_array_of_strings(input)
    end
    
    return user_input
  end	

  def self.read_from_command_line
    input = gets.chomp
    return input
  end	

  def self.convert_input_to_array_of_strings(input)
    input_array = input.split(INPUT_SEPRATOR) 
    return input_array  
  end

end



class Solution
  
  attr_accessor :pages_keywords, :queries_keywords # array of array of strings
  MAX_KEYWORDS_ALLOWED = 8
  MAX_RELEVANT_PAGES_FOR_A_QUERY = 5
 
  def initialize(keywords = {})
    self.pages_keywords = keywords.fetch(:pages_keywords, []) 
    self.queries_keywords = keywords.fetch(:queries_keywords, [])
  end
  
  def solution
    queries_keywords.each_index do |query_no|
      puts output_format(query_no + 1, rank_pages_for_a_query(query_no))
    end  
  end  

  private
  
  def output_format(query_no, rank_array)
    output_string = "Q" + query_no.to_s + ":" + " "
    rank_array.each do |page_no|
      output_string += "P" + page_no.to_s + " "
    end
    output_string     
  end  

  def search_strengths_of_all_pages_for_query(query_no)
    search_strengths = []     
    pages_keywords.each_index do |page_no|
      search_strengths.push(search_strength_of_a_page_for_a_query(page_no, query_no))        
    end
    return search_strengths
  end  

  def rank_pages_for_a_query(query_no)
    search_strengths_of_pages = search_strengths_of_all_pages_for_query(query_no)
    search_strengths_of_pages_in_hash = convert_an_array_to_hash(search_strengths_of_pages)
    
    sorted_search_strengths = sort_hash_by_value_in_descending_order(search_strengths_of_pages_in_hash) 
    
    ranking = []
    
    sorted_search_strengths.each do |page_strength|
      if page_strength.last != 0    # checking page strength
        ranking.push(page_strength.first + 1)   # push page no
        break if ranking.size == MAX_RELEVANT_PAGES_FOR_A_QUERY
      end  
    end
    return ranking    
  end  

  def convert_an_array_to_hash(array)
    hash = Hash.new
    array.each_index do |index|
      hash[index] = array[index]
    end
    return hash  
  end
  
  # return array of arrays a hash like for  { 1 => 30, 2 => 40, 3 => 20, 4 => 10 } it will return 
  # [ [2, 40], [1, 30], [3, 20], [1, 10] ] 

  def sort_hash_by_value_in_descending_order(hash)
    array = hash.sort_by { |key, value| value }
    array.reverse!
    return array
  end  

  def search_strength_of_a_page_for_a_query(page_no, query_no)
    max_strength = MAX_KEYWORDS_ALLOWED
    search_strength = 0
    queries_keywords[query_no].each do |query_keyword|
      search_strength += max_strength * weight_of_a_query_keyword_in_a_page(query_keyword, page_no)
      max_strength -= 1
    end
    return search_strength 
  end  
  
  def weight_of_a_query_keyword_in_a_page(query_keyword, page_no)
     offset = pages_keywords[page_no].index { |element| element.downcase == query_keyword.downcase }
     unless offset.nil?
       return MAX_KEYWORDS_ALLOWED - offset        
     else
       return 0   # return weight 0 when keyword is missing in page
     end 
  end   
 
end

user_input = Helper.user_input

s = Solution.new(user_input)
s.solution

