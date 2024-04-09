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

def create_file(line, activity, dir_path, file_name)
  # Make the directory and file, rescue if error
  begin
    Dir.mkdir(dir_path) unless Dir.exist?(dir_path)
    
    File.open(dir_path+file_name, 'a+') do |file|
      file.write()
    end
    
    # Add a file activity log
    ruby_process = Sys::ProcTable.ps(pid: Process.pid)
    
    create_file_activity_log = 
    { timestamp: Time.now,
    file_path: dir_path+file_name,
    activity: activity,
    username: ruby_process.environ["USER"],
    process_name: ruby_process.comm,
    process_command_line: ruby_process.cmdline,
    process_id: ruby_process.pid }
    
    log_path = './logs.json'
    
    existing_logs = File.read(log_path) if File.exist?(log_path)
    logs_data = existing_logs ? JSON.parse(existing_logs) : []
    logs_data << create_file_activity_log
    updated_json = JSON.pretty_generate(logs_data)
    File.open(log_path, 'w') do |file|
      file.write(updated_json)
    end
  rescue Errno::ENOENT => e
    puts "Error: #{e.message}"
  end
end

def modify_file(command, activity, file_path, added_text)
  # Add text to end of file, rescue if file doesn't exist
  begin
    File.open(file_path, 'r+') do |file|
      file.write(added_text)
    end
  rescue Errno::ENOENT => e
    puts "Error: #{e.message}"
  end
end

def delete_file(command, activity, file_path)
  # Delete the file, rescue if file doesn't exist
  begin
    File.delete(file_path)
  rescue Errno::ENOENT => e
    puts "Error: #{e.message}"
  end
end