# frozen_string_literal: true

class Shopper
  attr_accessor :name, :cart, :purchased_items, :money

  def initialize(name, cart, purchased_items)
    @name = name
    @cart = cart
    @purchased_items = purchased_items
    @money = get_starting_funds
  end

  def view_purchased_items
    puts '~~Purchased Items~~'
    @purchased_items.size.times do |i|
      puts "#{i + 1}) Item Name: #{@purchased_items[i][:name]}"
      puts "   Item Price: #{@purchased_items[i][:price]}"
      puts "-------------------------------\n"
    end
  end

  def get_starting_funds
    print 'How much money do you have?: '
    input = gets.chomp
    until is_valid_number?(input)
      print 'How much money do you have?: '
      input = gets.chomp
    end
    money = input.to_f
    return money
    check_wallet
  end

  def check_wallet
    puts "you have $#{@money} in your wallet."
    print 'Would you like to add more funds? (Enter Y for Yes): '
    input = gets.chomp
    add_funds if input.downcase == 'y'
  end

  def add_funds
    print 'How much money would you like to add?: '
    input = gets.chomp
    until is_valid_number?(input)
      print 'How much money would you like to add?: '
      input = gets.chomp
    end
    @money += input.to_f
    puts "New wallet total is: $#{@money}"
  end

  def out_of_money?
    true if @money <= 0
  end
end
