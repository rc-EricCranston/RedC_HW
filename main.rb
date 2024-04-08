def main(input_file)
  puts input_file
  File.foreach(input_file) do |line|
    puts line
  end
end
