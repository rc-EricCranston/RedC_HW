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
