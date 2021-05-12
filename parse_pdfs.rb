require "json"
require "fileutils"
require "csv"
require "pry"
require "yomu"


trades = []
holdings = []
pending_trades = []
to_skip_next_one = false
Dir[File.join("pdfs", "*.pdf")].each do |pdf_path|
  yomu = Yomu.new(pdf_path)
  lines = yomu.text.split("\n").keep_if { |a| a.to_s.strip.length > 0 }.collect { |a| a.strip }

  current_section = nil
  current_holdings = []
  lines.each_with_index do |line, index|
    if current_section == :holdings
      line_columns = line.split(" ")
      next unless line_columns[-1].start_with?("$")
      if line_columns[0] == "Total"
        current_section = nil
        total_sum = current_holdings.collect { |a| a[:value].gsub("$", "").gsub(",", "").to_f }.sum
        if total_sum.round == line_columns[1].gsub("$", "").gsub(",", "").to_f.round
          puts "Verified sum, all good"
          next
        else
          binding.pry # sum doesn't align
          raise "Invalid"
        end
      end

      current_holdings << {
        file_name: pdf_path,
        file_name_date: pdf_path.match(/STATEMENT_(\d\d\d\d\-\d\d)/),
        value: line_columns[-1],
        share_price: line_columns[-2],
        shares: line_columns[-3],
        symbol: line_columns[-4],
        security: line_columns[0..-5].join(" "),
      }
    elsif current_section == :trades
      lines_columns = line.split(" ")
      if to_skip_next_one
        next
        to_skip_next_one = false
      end

      if lines_columns[-1].start_with?("$")
        # Some weird rows have that
        if lines[index + 1].include?("as of")
          lines_columns << lines[index + 2]
          to_skip_next_one = true
        end

        new_entry = {
          file_name: pdf_path,
          trade_date: lines_columns[0],
          security: lines_columns[1..-6].join(" "),
          symbol: lines_columns[-5],
          type: lines_columns[-4],
          shares: lines_columns[-3],
          share_price: lines_columns[-2],
          value: lines_columns[-1],
        }
        if current_section == :trades
          trades << new_entry
        elsif current_section == :pending_trades
          pending_trades << new_entry
        end
      elsif lines_columns[0] == "PENDING" && lines_columns[1] == "TRADES"
        current_section == :pending_trades
      elsif lines_columns[0] == "DIVIDENDS"
        current_section = nil
      end
    else
      if line.match?(/Holdings as of/)
        current_section = :holdings
      elsif line.match?(/TRADES/)
        current_section = :trades
      end
    end
  end
  holdings += current_holdings
end

def create_for_array(arr, output)
  FileUtils.mkdir_p("output")
  headers = arr.collect { |a| a.keys }.flatten.uniq

  CSV.open(File.join("output", output), "wb") do |csv|
    csv << headers
    arr.each do |current_row|
      csv << headers.collect { |key| current_row[key] }
    end
  end
end

create_for_array(trades, "trades.csv")
create_for_array(pending_trades, "pending_trades.csv")
create_for_array(holdings, "holdings.csv")
