require 'json'

# Get path to products.json, read the file into a string,
# and transform the string into a usable hash
def setup_files
  path = File.join(File.dirname(__FILE__), '../data/products.json')
  file = File.read(path)
  $products_hash = JSON.parse(file)
end

def make_headings
  $heading_title = [
    "  #####                                 ######                                   ",
    " #     #   ##   #      ######  ####     #     # ###### #####   ####  #####  #####",
    " #        #  #  #      #      #         #     # #      #    # #    # #    #   #  ",
    "  #####  #    # #      #####   ####     ######  #####  #    # #    # #    #   #  ",
    "       # ###### #      #           #    #   #   #      #####  #    # #####    #  ",
    " #     # #    # #      #      #    #    #    #  #      #      #    # #   #    #  ",
    "  #####  #    # ###### ######  ####     #     # ###### #       ####  #    #   #  ",
    "********************************************************************************",
    ""
  ]

  $heading_products = [
    "                     _            _       ",
    "                    | |          | |      ",
    " _ __  _ __ ___   __| |_   _  ___| |_ ___ ",
    "| '_ \\| '__/ _ \\ / _` | | | |/ __| __/ __|",
    "| |_) | | | (_) | (_| | |_| | (__| |_\\__ \\",
    "| .__/|_|  \\___/ \\__,_|\\__,_|\\___|\\__|___/",
    "| |                                       ",
    "|_|                                       ",
    ""
  ]

  $heading_brands = [
    " _                         _     ",
    "| |                       | |    ",
    "| |__  _ __ __ _ _ __   __| |___ ",
    "| '_ \\| '__/ _` | '_ \\ / _` / __|",
    "| |_) | | | (_| | | | | (_| \\__ \\",
    "|_.__/|_|  \\__,_|_| |_|\\__,_|___/",
    ""
  ]
end

def print_divider
  print "-" * 20
end

def print_ascii_art(*lines)
  lines.each {|line| puts line}
end

def print_heading
  # Print "Sales Report" in ascii art
  print_ascii_art($heading_title)
  # Print today's date
  puts "Report Date: #{Time.now.strftime('%m/%d/%Y')}"
end

def print_product_summary(product)
  # Print the product report
  puts product[:title]
  puts print_divider
  puts "Retail Price: $#{product[:price]}"
  puts "Total Purchases: #{product[:total_purchases]}"
  puts "Total Sales: $#{product[:total_sales]}"
  puts "Average Price: $#{product[:avg_price]}"
  puts "Average Discount: #{product[:avg_discount]}%"
  puts print_divider
  puts
end

def print_brand_summary(brand)
  puts brand[0]
  puts print_divider
  puts "Number of Products: #{brand[1][:inventory]}"
  puts "Average Product Price: $#{average(brand[1][:price_sum], brand[1][:count])}"
  puts "Total Sales: $#{brand[1][:sales_sum].round(2)}"
  puts print_divider
  puts
end

def average(total_amount, quantity)
  (total_amount / quantity).round(2)
end

def discount(discounted_price, full_price)
  ((1 - (discounted_price / full_price)) * 100).round(1)
end

def sales_volume_of_item(item)
  item["purchases"].map { |purchase| purchase["price"] }.reduce(:+)
end

def average_price_of_item(item)
  average(sales_volume_of_item(item), item["purchases"].length)
end

def generate_product_summary(item)
  # Gather / calculate the required product data
  retail_price = item["full-price"].to_f
  avg_price = average_price_of_item item
  avg_discount = discount avg_price, retail_price

  product = {
    :title => item["title"],
    :price => retail_price,
    :total_purchases => item["purchases"].length,
    :total_sales => sales_volume_of_item(item),
    :avg_price => avg_price,
    :avg_discount => avg_discount
  }
end

def generate_brand_summary(item, brand_data_hash)
  item_data = {
    :count => 1,
    :inventory => item["stock"],
    :price_sum => item["full-price"].to_f,
    :sales_sum => sales_volume_of_item(item)
  }

  brand_name = item["brand"]
  # Check if the brands hash has this brand in it yet
  if brand_data_hash.has_key?(brand_name)
    # Add the new data to the existing values
    brand_data_hash[brand_name][:count] += 1
    brand_data_hash[brand_name][:inventory] += item_data[:inventory]
    brand_data_hash[brand_name][:price_sum] += item_data[:price_sum]
    brand_data_hash[brand_name][:sales_sum] += item_data[:sales_sum]
  else
    # Insert the data as a new brand
    brand_data_hash[item["brand"]] = item_data
  end
end

def make_products_section(product_data)
  # Print "Products" in ascii art
  print_ascii_art($heading_products)
  # For each product in the data set:
    # Print the name of the toy
    # Print the retail price of the toy
    # Calculate and print the total number of purchases
    # Calculate and print the total amount of sales
    # Calculate and print the average price the toy sold for
    # Calculate and print the average discount based off the average sales price
  product_data.each { |item| print_product_summary(item) }
end

def make_brands_section(brand_data)
  # Print "Brands" in ascii art
  print_ascii_art($heading_brands)
  # For each brand in the data set:
    # Print the name of the brand
    # Count and print the number of the brand's toys we stock
    # Calculate and print the average price of the brand's toys
    # Calculate and print the total sales volume of all the brand's toys combined
  brand_data.each { |item| print_brand_summary(item) }
end

def process_report_data
  # Loop through the main product data hash once and update product and brand
  # data arrays for separate processing.
  product_data_array = []
  brand_data_hash = {}

  $products_hash["items"].each do |item|
    # Gather product data for the item
    product_data_array.push(generate_product_summary(item))
    # Gather the brand data, grouped by unique brands
    generate_brand_summary(item, brand_data_hash)
  end

  # Call the methods to print the sections, passing the appropriate data to each
  make_products_section(product_data_array)
  make_brands_section(brand_data_hash)
end

def print_data
  process_report_data
end

def create_report
  print_heading
  print_data
end

def start
  setup_files # load, read, parse, and create the files
  make_headings
  create_report # create the report!
end

start # call start method to trigger report generation
