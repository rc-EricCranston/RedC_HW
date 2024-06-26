## Red Canary Engineering Interview HW Assignment

### Project Overview 
This project is to trigger endpoint activity and gather respective telemetry logs. These "expected" logs can then be compared to telemetry logs generated on an EDR agent listening to the same endpoint activity for testing purposes. 

This program takes in an input file with specified endpoint activity - starting a process, creating/modifying/deleting a file, and establishing a network connection and transmitting data. The program then parses the input file line by line and calls the appropriate activity method, triggering endpoint activity. For each activity, a respective telemetry log is generated and the log is placed into a central log file in JSON format.

This program includes a "server_side" directory to act as the receiving server for any data transmission activity.

At this time, this project is only supported on macOS. 


### How to use this program

1. **Start the receiving server**

In a terminal window, `cd` into this program directory, and start up the receiving server by running:

> ruby server_side/tcp_server.rb

This should start a TCP server that will stay open in this terminal window and continuously listen for a connection from a client.

2. **Start the program and pass in the input file**

In a different terminal window, start the program and pass in the input file by running:

> rake 'run_mac[mac_activity.txt]'

This command passes the `mac_activity.txt` (which is included in this repo) to the rake task called `run_mac`. This input file is then passed on to the `main.rb` of this program.

3. **What to expect after running this program**

After the program runs, all telemetry logs generated by the endpoint activity will be located at `logging/logs.json`.

If the provided `mac_activity.txt` input file is used, a new directory and file should be generated at `new_dir1/file1.txt` and the server should receive 2 files located at `server_side/received_files/`. 

### How to write a custom input file

Each new line in the input file triggers a new endpoint activity. Activity types include creating/modifying/deleting a file, opening an application, and establishing a network connection and transmitting data.

Each argument in the activity lines should be separated by a `,` and formatted as followed:

***For creating/modifying/deleting a file***

> create_file,<directory_path_to_file>,<file_name>

> modify_file,<directory_path_to_file>,<file_name>

> delete_file,<directory_path_to_file>,<file_name>

Example:
> create_file,./new_dir/,file1.txt

***For opening an application***

> open_app,<application_name>

Example:
> open_app,Calculator

***For establishing a network connection and transmitting data***

> network_connection,<destination_address>,<destination_port>,<file_path>

Example:
> network_connection,localhost,3000,new_dir/file1.txt





### Running via Docker
#### Build a Docker image from your Dockerfile
docker build -t my_app .

#### Run your app in a Docker container
docker run my_app