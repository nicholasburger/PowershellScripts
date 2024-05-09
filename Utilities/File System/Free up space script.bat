rmdir "C:\Windows\Software Distribution\Downloads"
rmdir "C:\MSOCache"
rmdir "C:\Windows\Temp"
rmdir "E:\Temp"
   for /D %%x in ("Z:\Users\*") do ( 
        rmdir /s /q "%%x\AppData\Local\Temp" 
         rmdir /s /q "%%x\AppData\Local\Microsoft\Windows\Temporary Internet Files" 
     )