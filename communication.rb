# # Communication
# This page provides dictionary of possible user commands to get information on the state of the game.
require_relative 'game'
require 'colorize'

class Communication

  def initialize(game)
    @game = game
    @mech = @game.mech
  end

  def ac_triggered
    COMMANDS.keys.each do |key|
      puts key + " : "+ COMMANDS[key]
    end
    puts
  end

  def execute_inquiry_command(string)
    if string == "players_order" || string == "infection_rate" || string == "outbreak_index" || string == "show_cities" || string == "players" || string == "rs" || string == "ci" || string == "disease" || string == "idp" || string == "pdp"
      send string.to_sym
    elsif string == "black_disease"
      print_disease_status(@game.black_disease)
    elsif string =="red_disease"
      print_disease_status(@game.red_disease)
    elsif string =="yellow_disease"
      print_disease_status(@game.yellow_disease)
    elsif string =="blue_disease"
      print_disease_status(@game.blue_disease)
    elsif string =="show_cities(1)" || string == "show_cities(2)" || string == "show_cities(3)"
      send string[0..10].to_sym, string[12].to_i
    end
    puts
  end

  def avail_commands_keys
    COMMANDS.keys + ["show_cities(2)", "show_cities(3)"]
  end

  COMMANDS =
    {
    "ac" => "to show available commands",
    "quit" => "to end communication with the board",
    "players_order" => "to show the order of all players(who goes first, etc)",
    "players" => "to show details of all players",
    "infection_rate" => "to show the current infection rate.",
    "outbreak_index" => "to show the current outbreak index.",
    "disease" => "to show the status of all diseases.",
    "show_cities" => "to show cities with any cubes.",
    "show_cities(1)" => "to show cities with 1 cube. Other available commands are 'show_cities(2)' and 'show_cities(3)'",
    "rs" => "Research Station, to show cities with research stations.",
    "ci" => "City Info, to show information of a city",
    "idp" => "Infection Discard Pile, to show cards in the Infection Discard Pile",
    "pdp" => "Player Discard Pile, to show cards in the Player Discard Pile"
    }

  # The following are made as communication means from the command line during game.

  def players_order
    names = @game.players.collect {|player| player.name}
    puts "The player order based on highest population on each hand (first means first turn or player 1): " + names.to_s
  end

  def players
    @game.players.each_with_index do |player, idx|
      puts "Player " + (idx+1).to_s
      puts player.name + " is a " + player.role.to_s + ". "+ player.ability

      print "City Cards : "
      player.names_of_player_cards_in_hand_based_color.each do |color|
        case color[0]
        when "red"
          print color[1..-1].to_s.red + ". "
        when "yellow"
          print color[1..-1].to_s.yellow + ". "
        when "blue"
          print color[1..-1].to_s.blue + ". "
        when "black"
          print color[1..-1].to_s.black.on_white + ". "
        end
      end
      puts

      unless player.desc_of_event_cards_in_hand.empty?
        puts "Event Cards : " + player.desc_of_event_cards_in_hand.to_s
      end

      print "Location : "
      @mech.print_city_name_in_color(@mech.string_to_city(player.location))
      print ", a Research Station city." if @mech.string_to_city(player.location).research_st
      puts
      puts
    end
  end

  def disease
    diseases = [["red",@game.red_disease], ["blue",@game.blue_disease], ["yellow",@game.yellow_disease], ["black",@game.black_disease]]
    diseases.each do |disease|
      print disease[0].red if disease[0] == "red"
      print disease[0].blue if disease[0] == "blue"
      print disease[0].yellow if disease[0] == "yellow"
      print disease[0].black.on_white if disease[0] == "black"
      print ". Cubes available : " + disease[1].cubes_available.to_s + ". Cured : "
      print disease[1].cured.to_s.upcase.green + ". Eradicated : " if disease[1].cured
      print disease[1].cured.to_s + ". Eradicated : " if !disease[1].cured
      puts disease[1].eradicated.to_s.upcase.green if disease[1].eradicated
      puts disease[1].eradicated.to_s if !disease[1].eradicated
    end
  end

  def infection_rate
    puts "Infection Rate : " + @game.infection_rate.to_s
  end

  def outbreak_index
    puts "Outbreak Index : " + @game.outbreak_index.to_s
  end

  def show_cities(number_of_infection = 0)
    if number_of_infection == 0
      number_array = (1..3).to_a
      cities = []
      result = []
      number_array.each do |number|
        cities += @game.board.cities.select {|city| city.color_count == number}
      end
      cities.each do |city|
        @mech.print_city_name_in_color(city)
        print " : "
        @mech.print_city_cube_in_color(city)
        puts
      end
      puts
    else
      if number_of_infection < 0 || number_of_infection > 3
        puts "Only input 1, 2 or 3, or no numbers at all."
      else
        cities = @game.board.cities.select {|city| city.color_count == number_of_infection}
        puts "Cities with " + number_of_infection.to_s + " cubes are : "
        cities.each do |city|
          @mech.print_city_name_in_color(city)
          print " : "
          @mech.print_city_cube_in_color(city)
          puts
        end
      end
    end
  end

  def rs #Research Station
    print "Cities with research station are : "
    cities = @game.board.research_station_cities
    cities.each do |city|
      @mech.print_city_name_in_color(city)
      print ". "
    end
    puts
  end

  def ci #city_info
    satisfied = false
    while !satisfied
      print "Which city would you like to get information of? Type 'cancel' to cancel this action. "
      answer_string = gets.chomp

      if answer_string.downcase == 'cancel'
        return
      else
        city = @game.mech.string_to_city(answer_string)
        if city.nil?
          puts "City unrecognized. Try again!"
        else
          if city.research_st
            research_st_indication = city.research_st.to_s.upcase
          else
            research_st_indication = city.research_st.to_s
          end

          puts "Players : "+city.pawns.to_s+". Cubes : "+city.color_count.to_s+". red, yellow, black, blue : " + city.red.to_s.red + ", "+ city.yellow.to_s.yellow + ", "+ city.black.to_s.black.on_white + ", "+ city.blue.to_s.blue + ". Research St : "+ research_st_indication

          puts "Neighbors : "
          city.neighbors.each do |neighbor|
            if neighbor.research_st
              research_st_indication = neighbor.research_st.to_s.upcase
            else
              research_st_indication = neighbor.research_st.to_s
            end
            puts neighbor.name.to_s + ". Players : "+ neighbor.pawns.to_s + ". Cubes : " + neighbor.color_count.to_s + ". red, yellow, black, blue : " + neighbor.red.to_s.red + ", "+ neighbor.yellow.to_s.yellow + ", "+ neighbor.black.to_s.black.on_white + ", "+ neighbor.blue.to_s.blue + ". Research St : "+research_st_indication
          end

          satisfied = true
        end
      end
    end
    puts
  end

  def idp #infection discard Pile
    print "Cards in the Infection Discard Pile : "
    if @game.infection_discard_pile.empty?
      puts "None. "
    else
      @game.infection_discard_pile.each do |card|
        @mech.print_card_in_color(card)
        print ". "
      end
    end
    puts
  end

  def pdp #player discard pile
    print "Cards in the Player Discard Pile : "
    city_cards = @game.player_discard_pile.select {|card| card.type == :player}
    event_cards = @game.player_discard_pile.select {|card| card.type == :event}

    if city_cards.empty? && event_cards.empty?
      puts "None."
    else
      city_cards.each do |card|
        @mech.print_card_in_color(card)
        print ". "
      end
      event_cards.each {|card| print card.event.to_s + ". "}
    end
    puts
  end

end
