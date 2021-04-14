require "json"
require "fileutils"
require "csv"
require "pry"

data = JSON.parse(File.read("wealthfront.json"))
completed_transfers = data["transfers"]["completed_transfers"]
puts "Parsing #{completed_transfers.count} transactions"

results = {} # top level is `class_type`
# => ["dividend", "dividend-investment", "other-investment", "index-optimization", "harvest", "withdrawal", "liquidation"]

completed_transfers.each do |transfer|
  row = {}
  row[:created_at] = transfer["created_at"]
  row[:class_type] = transfer["class_type"]
  row[:amount] = transfer["amount"].gsub("$", "") if transfer["amount"]
  row[:currency] = "$"
  row[:type] = transfer["type"]
  row[:transaction_type] = transfer["transaction_type"]

  if transfer["class_type"] == "dividend"
    # For dividends, there might be multiple per day, but we only care about each transaction
    row.delete(:amount)
    transfer["dividends"].each do |dividend|
      row[:dividends_symbol] = dividend["symbol"]
      row[:dividends_ex_date] = Date.parse(dividend["ex_date"]).to_s
      row[:dividends_amount_per_share] = dividend["amount_per_share"]
      row[:dividends_amount] = dividend["amount"]

      results[transfer["class_type"]] ||= []
      results[transfer["class_type"]] << row

      row = row.dup
    end
  elsif transfer["class_type"] == "dividend-investment"
    row.delete(:amount)
    transfer["trades"].each do |dividend|
      row[:dividends_investment_trade_symbol] = dividend["symbol"]
      row[:dividends_investment_trade_type] = dividend["type"]
      row[:dividends_investment_trade_shares] = dividend["shares"]
      row[:dividends_investment_trade_share_price] = dividend["share_price"]
      row[:dividends_investment_trade_date] = dividend["date"]
      row[:dividends_investment_trade_value] = dividend["value"].gsub("$", "")

      results[transfer["class_type"]] ||= []
      results[transfer["class_type"]] << row
      row = row.dup
    end
  elsif transfer["class_type"] == "fee"
    row[:fee_paid] = transfer["your_fee"]
    row[:period] = transfer["period"]
  elsif transfer["index-optimization"]
    # TODO: Not yet implemented
  else
    results[transfer["class_type"]] ||= []
    results[transfer["class_type"]] << row
  end
end

["dividend", "dividend-investment"].each do |type|
  FileUtils.mkdir_p("output")
  headers = results[type].collect { |a| a.keys }.flatten.uniq

  CSV.open("output/wealthfront_#{type}.csv", "wb") do |csv|
    csv << headers
    results[type].each do |current_row|
      csv << headers.collect { |key| current_row[key] }
    end
  end
end

puts "Successfullyl generated ./output"
