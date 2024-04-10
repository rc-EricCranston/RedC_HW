def modify_file(command, activity, file_path, added_text)
  # Add text to end of file, rescue if error
  begin
    File.open(file_path, 'r+') do |file|
      existing_data = file.read
      updated_data = existing_data.chomp + "\n" + added_text
      file.rewind
      file.write(updated_data)
    end
    
    # Add a file activity log
    ruby_process = Sys::ProcTable.ps(pid: Process.pid)
    
    modify_file_activity_log = 
    { timestamp: Time.now,
    full_path: file_path,
    activity: activity,
    username: ruby_process.environ["USER"],
    process_name: ruby_process.comm,
    process_command_line: ruby_process.cmdline,
    process_id: ruby_process.pid }
    
    log_path = './logs.json'
    
    existing_logs = File.read(log_path) if File.exist?(log_path)
    logs_data = existing_logs ? JSON.parse(existing_logs) : []
    logs_data << modify_file_activity_log
    updated_json = JSON.pretty_generate(logs_data)
    File.open(log_path, 'w') do |file|
      file.write(updated_json)
    end
  rescue Errno::ENOENT => e
    puts "Error: #{e.message}"
  end
end
