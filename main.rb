def main(input_file)
  puts input_file
  File.foreach(input_file) do |line|
    line.chomp!
    line_args = line.split(",")
    case line_args[0]
    when "create"
      create_file(line, line_args[1], line_args[2])
    when "modify"
      modify_file(line, line_args[1], line_args[2])
    end
  end
end

def create_file(command, path, file_name)
  `mkdir -p #{path} && touch #{path}#{file_name}`
end

def modify_file(command, file, added_text)
  `echo #{added_text} >> #{file}`
end