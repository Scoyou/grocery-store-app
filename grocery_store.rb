# frozen_string_literal: true

require_relative 'anscii_art'
require_relative 'shopper'

def app_main
  welcome
  loop do
    menu
  end
end

@coupon = false

@store_items = [
  { name: 'Apple', price: 2.00, qty: 2 },
  { name: 'Bread', price: 5.00, qty: 15 },
  { name: 'Banana', price: 3.00, qty: 20 },
  { name: 'Milk', price: 3.50, qty: 10 },
  { name: 'Tangerine', price: 3.00, qty: 15 }
]

def welcome
  AnsciiArt.art # located in anscii_art.rb file to keep code clean
  print 'Please enter your name: '
  name = gets.strip.capitalize
  @shopper = Shopper.new(name, [], [])
  puts "Welcome to the Ruby Grocery Store, #{@shopper.name}!"
end

def menu
  menu = [
    'List store items',
    'Add item to cart',
    'Remove item from cart',
    'View items in cart',
    'Add new item to store',
    'Check your wallet',
    'Checkout',
    'View previously purchased items',
    'Exit'
  ]
  puts 'Please choose an action: '
  menu.size.times do |i|
    puts "#{i + 1}) #{menu[i]}"
  end
  get_user_input
end

def get_user_input
  print '> '
  input = gets.chomp
  menu unless is_valid_number?(input)
  selection = input.to_i
  menu_options(selection)
end

def menu_options(selection)
  case selection
  when 1
    clear_terminal
    list_items
  when 2
    clear_terminal
    add_item_to_cart
  when 3
    clear_terminal
    remove_cart_item
  when 4
    clear_terminal
    view_cart
  when 5
    clear_terminal
    add_new_item
  when 6
    clear_terminal
    @shopper.check_wallet
  when 7
    clear_terminal
    if @shopper.out_of_money?
      puts "You don't have any money left!  :(\n"
    else
      check_for_coupon
      checkout
    end
  when 8
    @shopper.view_purchased_items
  when 9
    goodbye
  else
    puts 'Invalid input!'
  end
end

def list_items
  puts '~~Grocery Items~~'
  @store_items.size.times do |i|
    puts "#{i + 1}) Item Name: #{@store_items[i][:name]}"
    puts "   Item Price: #{@store_items[i][:price]}"
    puts "   Item Quantity: #{@store_items[i][:qty]}"
    puts "-------------------------------\n"
  end
end

def add_item_to_cart
  puts 'Which item would you like to add?'
  list_items
  puts "Or press 'E' to return to menu."
  print '> '
  input = gets.chomp
  if input.downcase == 'e'
    menu
  else
    add_item_to_cart unless is_valid_number?(input)
    selection = input.to_i
    index = selection - 1
    if selection > @store_items.length
      puts 'Sorry, I could not find that item.'
      add_item_to_cart
    else
      if is_out_of_stock?(index)
        puts 'Sorry, that item is currently out of stock.'
      else
        @shopper.cart << @store_items[index]
        puts "Added #{@store_items[index][:name]} to cart"
        @store_items[index][:qty] -= 1
        puts "There are #{@store_items[index][:qty]} #{@store_items[index][:name]}s left"
      end
    end
  end
end

def is_out_of_stock?(item)
  return true if @store_items[item][:qty] <= 0
end

def remove_cart_item
  if @shopper.cart.empty?
    puts 'Your cart is empty'
    menu
  else
    puts "Select the item number you'd like to remove, or press 'E' to return to menu"
    select_removed_item
    puts "Removed #{@shopper.cart[@index][:name]} from cart!"
    restock_item(@index)
    @shopper.cart.delete_at(@index)
    until @shopper.cart.empty?
      print 'Would you like to remove another item? '
      choice = gets.chomp
      if choice.downcase == 'y'
        select_removed_item
        puts "Removed #{@shopper.cart[@index][:name]} from cart!"
        restock_item(@index)
        @shopper.cart.delete_at(@index)
      else
        break
      end
    end
  end
end

def select_removed_item
  view_cart
  print '> '
  input = gets.chomp
  menu if input.downcase == 'e'
  if is_valid_number?(input)
    selection = input.to_i
    if selection > @shopper.cart.length
      puts 'Sorry, I could not find that item.'
      remove_cart_item
    else
      @index = selection - 1
    end
  else
    remove_cart_item
  end
end

def restock_item(_item)
  @store_items.size.times do |i|
    if @shopper.cart[@index][:name] == @store_items[i][:name]
      @store_items[i][:qty] += 1
    else
      next
    end
  end
end

def view_cart
  if @shopper.cart.empty?
    puts 'Your cart is empty!'
  else
    puts '~~🛒Cart Items 🛒~~'
    @shopper.cart.size.times do |i|
      puts "#{i + 1}) Item Name: #{@shopper.cart[i][:name]}"
      puts "   Item Price: $#{@shopper.cart[i][:price]}"
      puts "-------------------------------\n"
    end
    calculate_total
    puts "Current total is: $#{@total}\n"
  end
end

def add_new_item
  puts 'Enter new item info: '
  print 'Item Name: '
  name = gets.chomp.capitalize
  print 'Item Price: '
  price_input = gets.chomp
  until is_valid_number?(price_input)
    print 'Item Price: '
    price_input = gets.chomp
  end
  price = price_input.to_f
  print 'Item Quantity: '
  qty_input = gets.chomp
  until is_valid_number?(qty_input)
    print 'Item Quantity: '
    qty_input = gets.chomp
  end
  quantity = qty_input.to_i
  @store_items << create_new_item(name, price, quantity)
end

def create_new_item(name, price, quantity)
  new_item = {
    name: name,
    price: price,
    qty: quantity
  }
end

def checkout
  calculate_total
  puts "Your total is: $#{@total}"
  verify_funds(@total)
  @shopper.cart.size.times do |i|
    @shopper.purchased_items << @shopper.cart[i]
  end
  @shopper.cart.clear
end

def calculate_total
  @total = 0
  @shopper.cart.size.times do |i|
    @total += @shopper.cart[i][:price]
  end
  if @coupon
    discount = (@total * 0.2)
    @total -= discount
  end
  tax = 0.03
  taxes = @total * tax
  @total += taxes
end

def verify_funds(total)
  check = @shopper.money - total
  if check < 0
    puts "You don't have enough money :("
    print 'Remove cart item? Press Y for yes, or any other button to exit: '
    input = gets.chomp
    if input.downcase == 'y'
      remove_cart_item
    else
      goodbye
    end
  else
    @shopper.money -= total
  end
end

def check_for_coupon
  print 'Do you have a coupon? '
  input = gets.chomp
  @coupon = true if input.downcase == 'y'
end

def is_valid_number?(input)
  pattern = /^\d*\.?\d+$/
  if pattern.match?(input)
    return true
  else
    puts "#{input} is not a valid selection."
    return false
  end
end

def clear_terminal
  puts `clear`
end

def goodbye
  puts 'Goodbye!'
  exit
end

app_main
