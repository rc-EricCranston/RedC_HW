def open_app(command, activity, application)
  open_app_command = "open -a #{application}"
  app_pid = Process.spawn(open_app_command)
  app_process = Sys::ProcTable.ps(pid: app_pid)
  
  # Create a process activity log
  process_activity_log = 
  { timestamp: Time.now,
  username: app_process.environ["USER"],
  process_name: app_process.comm,
  process_command_line: app_process.cmdline,
  process_id: app_process.pid }
  
  file_path = './logs.json'
  
  existing_logs = File.read(file_path) if File.exist?(file_path)
  logs_data = existing_logs ? JSON.parse(existing_logs) : []
  logs_data << process_activity_log
  updated_json = JSON.pretty_generate(logs_data)
  File.open(file_path, 'w') do |file|
    file.write(updated_json)
  end
end
