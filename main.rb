#!/usr/bin/env ruby
require 'io/console'
require "spaceship"
require 'csv'

puts "Enter password"
pass = STDIN.noecho(&:gets)
Spaceship::Tunes.login("<your-email>", pass)
app = Spaceship::Tunes::Application.find("<your-app-id>")

CSV.foreach("/Users/<user>/iaps.csv", quote_char: '"', col_sep: ',', row_sep: :auto, headers: true) do |row|
	productType = row['Type (consumable -1, non-consumable -2)'] == "1" ? Spaceship::Tunes::IAPType::CONSUMABLE : Spaceship::Tunes::IAPType::NON_CONSUMABLE
	productName = row['Reference Name']
	productDescription = row['IAP description-EN']
	productIdentifier = row['Product ID']
	productTier = row['IAP Price-TIER'].to_i
	puts "Processing product '%s', it's a '%s' %s of tier %d" % [productIdentifier, productName, productType, productTier]
	app.in_app_purchases.create!(
		type: productType, 
		versions: {
		  "en-US" => {
		    name: productName,
		    description: productDescription
		  }
		},
		reference_name: productName,
		product_id: productIdentifier,
		cleared_for_sale: true,
		review_notes: "",
		review_screenshot: "/Users/<user>/default.jpg", 
		pricing_intervals: 
		  [
		    {
		      country: "WW",
		      begin_date: nil,
		      end_date: nil,
		      tier: productTier
		    }
		  ] 
		)
end