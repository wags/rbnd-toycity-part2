require 'json'

# Get path to products.json, read the file into a string,
# and transform the string into a usable hash
def setup_files
  path = File.join(File.dirname(__FILE__), '../data/products.json')
  file = File.read(path)
  $products_hash = JSON.parse(file)
end

def make_headings
  $heading_report = []
  $heading_report.push("  #####                                 ######                                   ")
  $heading_report.push(" #     #   ##   #      ######  ####     #     # ###### #####   ####  #####  #####")
  $heading_report.push(" #        #  #  #      #      #         #     # #      #    # #    # #    #   #  ")
  $heading_report.push("  #####  #    # #      #####   ####     ######  #####  #    # #    # #    #   #  ")
  $heading_report.push("       # ###### #      #           #    #   #   #      #####  #    # #####    #  ")
  $heading_report.push(" #     # #    # #      #      #    #    #    #  #      #      #    # #   #    #  ")
  $heading_report.push("  #####  #    # ###### ######  ####     #     # ###### #       ####  #    #   #  ")
  $heading_report.push("********************************************************************************")
  $heading_report.push("")

  $heading_products = []
  $heading_products.push("                     _            _       ")
  $heading_products.push("                    | |          | |      ")
  $heading_products.push(" _ __  _ __ ___   __| |_   _  ___| |_ ___ ")
  $heading_products.push("| '_ \\| '__/ _ \\ / _` | | | |/ __| __/ __|")
  $heading_products.push("| |_) | | | (_) | (_| | |_| | (__| |_\\__ \\")
  $heading_products.push("| .__/|_|  \\___/ \\__,_|\\__,_|\\___|\\__|___/")
  $heading_products.push("| |                                       ")
  $heading_products.push("|_|                                       ")
  $heading_products.push("")

  $heading_brands = []
  $heading_brands.push(" _                         _     ")
  $heading_brands.push("| |                       | |    ")
  $heading_brands.push("| |__  _ __ __ _ _ __   __| |___ ")
  $heading_brands.push("| '_ \\| '__/ _` | '_ \\ / _` / __|")
  $heading_brands.push("| |_) | | | (_| | | | | (_| \\__ \\")
  $heading_brands.push("|_.__/|_|  \\__,_|_| |_|\\__,_|___/")
  $heading_brands.push("")
end

def print_divider
  print "-" * 20
end

def print_ascii_art(*lines)
  lines.each {|line| puts line}
end

def print_heading
  # Print "Sales Report" in ascii art
  print_ascii_art($heading_report)
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

def get_total_purchases(item)
  item["purchases"].map { |purchase| purchase["price"] }.reduce(:+)
end

def average(total_amount, quantity)
  (total_amount / quantity).round(2)
end

def generate_product_summary(item)
  # Gather / calculate the required product data
  product = {title: "", price: 0, total_purchases: 0, total_sales: 0, avg_price: 0, avg_discount: 0}
  product[:title] = item["title"]
  product[:price] = item["full-price"].to_f
  product[:total_purchases] = item["purchases"].length
  product[:total_sales] = get_total_purchases(item)
  product[:avg_price] = average(product[:total_sales], product[:total_purchases])
  product[:avg_discount] = ((1 - (product[:avg_price] / product[:price])) * 100).round(1)
  # In this method, an explicit return statement is required
  return product
end

def generate_brand_summary(item, brand_data_hash)
  item_data = {count: 1, inventory: item["stock"], price_sum: item["full-price"].to_f, sales_sum: get_total_purchases(item)}

  brand_name = item["brand"]
  # Check if the brands hash has this brand in it yet
  if brand_data_hash.has_key?(brand_name)
    # add the new data to the existing values
    brand_data_hash[brand_name][:count] += 1
    brand_data_hash[brand_name][:inventory] += item_data[:inventory]
    brand_data_hash[brand_name][:price_sum] += item_data[:price_sum]
    brand_data_hash[brand_name][:sales_sum] += item_data[:sales_sum]
  else
    # insert the data as a new brand
    brand_data_hash[item["brand"]] = item_data
  end
end

def process_report_data
  # Loop through the main product data hash once and update product and brand
  # data arrays for separate processing.
  product_data_array = []
  brand_data_hash = {}

  $products_hash["items"].each do |item|
    # generate product data for the item
    product_data_array.push(generate_product_summary(item))

    # generate the brand data, grouped by unique brands
    generate_brand_summary(item, brand_data_hash)
  end

  # call the methods to print the sections, passing in the appropriate arrays
  make_products_section(product_data_array)
  make_brands_section(brand_data_hash)
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

def print_data
  process_report_data
  #make_products_section
  #make_brands_section
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
