function fsize(filename)
   file = io.open(filename,"r")
   local current = file:seek()
   local size = file:seek("end")
   file:seek("set",current)
   file:close()
   return size
end

function main(filename)

   m.log(4,"Inspection for "..filename);

   -- Configure paths
   local clamdscan  = "/usr/bin/clamdscan"
   local clamscan  = "/usr/bin/clamscan"

   -- failoverOnClamdFailure: failover to clamscan if clamdscan report an error
   local failoverOnClamdFailure = true

   -- fail (and block) if clamdscan (and clamscan) fails
   local failOnError = false

   -- local var
   local agent = "clamdscan"

   -- Skip empty items because if clamd is not working and you
   -- use the clamscan agent an empty file can take about 12 secs 
   -- to be analyzed
   if fsize(filename) == 0 then
     m.log(1, "[scanav skipped, file " .. filename .." size is zero]")
     return nil
   end

   -- The system command we want to call with fdpass flag to 
   -- do not incur in a permission issue
   local cmd = clamdscan .. " --fdpass --stdout --no-summary"

   -- Run the command and get the output
   local f = io.popen(cmd .. " " .. filename .. " || true")
   local l = f:read("*a")
   f:close()

   -- Check the output for the FOUND or ERROR strings which indicate
   -- an issue we want to block access on
   local isVuln = string.find(l, "FOUND")
   local isError = string.find(l, "ERROR")
  -- If clamdscan fails and you want failover to the traditional clamscan...
   if isError and failoverOnClamdFailure then
     -- Try to use the clamscan program
     m.log(1, "[clamdscan fails (" .. l .. "), failover to clamscan]")
     agent = "clamscan"
     cmd = clamscan .. " --stdout --no-summary"
     f = io.popen(cmd .. " " .. filename .. " || true")
     l = f:read("*a")
     f:close()
     isVuln = string.find(l, "FOUND")
     isError = string.find(l, "ERROR")
   end

   if isVuln then
     m.log(1, "[" .. agent .. " scanner message: " .. l .. "]\n")
     return "Virus Detected"
   elseif isError and failOnError then
     -- is a error (not a virus) a failure event?
     m.log(1, "[" .. agent .. " scanner message: " .. l .. "]\n")
     return "Error Detected"
   else
     return nil
   end
end
