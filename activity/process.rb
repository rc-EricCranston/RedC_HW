def open_app(command, activity, application)
  # Spawn new process to open the application, rescue if error
  begin
    open_app_command = "open -a #{application}"
    app_pid = Process.spawn(open_app_command)
    app_process = Sys::ProcTable.ps(pid: app_pid)
    
    # Add a process activity log
    create_process_log(app_process)
  rescue Errno::ENOENT => e
    puts "Error: #{e.message}"
  end
end
