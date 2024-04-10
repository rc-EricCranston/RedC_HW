require 'json'
require 'sys/proctable'
require_relative 'activity/file/create'
require_relative 'activity/file/delete'
require_relative 'activity/file/modify'
require_relative 'activity/network_connection'
require_relative 'activity/process'
require_relative 'logging/process_log'

def main(input_file)
  ruby_process = Sys::ProcTable.ps(pid: Process.pid)
  create_process_log(ruby_process)
  
  # Parse activity in input file
  File.foreach(input_file) do |line|
    line.chomp!
    line_args = line.split(",")
    case line_args[0]
    when "create_file"
      create_file(line, line_args[0], line_args[1], line_args[2])
    when "modify_file"
      modify_file(line, line_args[0], line_args[1], line_args[2])
    when "delete_file"
      delete_file(line, line_args[0], line_args[1])
    when "network_connection"
      network_connection(line, line_args[0], line_args[1], line_args[2], line_args[3])
    when "open_app"
      open_app(line, line_args[0], line_args[1])
    end
  end
end
