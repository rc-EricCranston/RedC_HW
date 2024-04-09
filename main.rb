require 'json'
require 'sys/proctable'

def main(input_file)
  # Create a process activity log
  ruby_process = Sys::ProcTable.ps(pid: Process.pid)
  
  process_activity_log = 
  { timestamp: Time.now,
  username: ruby_process.environ["USER"],
  process_name: ruby_process.comm,
  process_command_line: ruby_process.cmdline,
  process_id: ruby_process.pid }
  
  file_path = './logs.json'
  
  existing_logs = File.read(file_path) if File.exist?(file_path)
  logs_data = existing_logs ? JSON.parse(existing_logs) : []
  logs_data << process_activity_log
  updated_json = JSON.pretty_generate(logs_data)
  File.open(file_path, 'w') do |file|
    file.write(updated_json)
  end
  
  # Parse activity in input file
  File.foreach(input_file) do |line|
    line.chomp!
    line_args = line.split(",")
    case line_args[0]
    when "create"
      create_file(line, line_args[0], line_args[1], line_args[2])
    when "modify"
      modify_file(line, line_args[0], line_args[1], line_args[2])
    when "delete"
      delete_file(line, line_args[0], line_args[1])
    end
  end
end

def create_file(line, activity, path, file_name)
  # Make the directory if it doesn't exist
  Dir.mkdir(path) unless Dir.exist?(path)
  
  # Make the file if it doesn't exist
  File.open(path+file_name, 'a+') do |file|
    file.write()
  end
end

def modify_file(command, activity, file, added_text)
  `echo #{added_text} >> #{file}`
end

def delete_file(command, activity, path)
  `rm #{path}`
end
