"Gather Prerequisite Info
let SWITCH_NAME = input('Enter Switch Name: ')
let s:PATH = expand('<sfile>:p:h')
"Clean up unwanted command output
$d
g/^.*#$/d
g/Descrip/d
g/Hardware/d
g/MTU/d
g/reliab/d
g/Encapsul/d
g/Keepalive/d
g/duplex/d
g/flow-control/d
g/ARP type/d
g/Last clearing/d
g/Input queue/d
g/Queueing strat/d
g/Output queue/d
g/5 minute/d
g/^     /d
g/Internet add/d
g/L3 in Switched/d
g/L3 out Switched/d
g/Members in this channel/d
g/30 second input rate/d
g/30 second output rate/d
g/Vlan/ d 2
"Try 3 different ways engineer may have entered the show command
"the Global function does not run delete if search string isn't
"present.
g/sh int/d
g/show int/d
g/show interface/d
"Format the file in to a CSV
%s/ is up/,up/g
%s/ is down/,down/g
"Not all switches have shutdown ports, if the search command
"does not find string it fails. Catch failure, alert and continue
try
	%s/ is admini/,admini/g
catch
	echo "No ports found in Shutdown State"
endtry
%s/ line protocol,//g
%s/ (/,/g
%s/)\n  Last input /,/g
%s/ output hang/output hang/g
%s/ output //g
execute "%s/^/" . SWITCH_NAME . ",/g"
1s/^/Switch,Interface,Layer1,Layer2,Status,Last Input,Last Output,Output Hang/
"Test if file exists and save file based on conditionals
if filereadable(s:PATH . "\\" . SWITCH_NAME . ".csv")
	let OVERWRITE = input(SWITCH_NAME . ".csv Exsists, Overwrite? Y/N: ")
	if OVERWRITE ==? "Y"
		execute "w! " . s:PATH . "\\" . SWITCH_NAME . ".csv"
	else
		let NEWNAME = input("New Name \(CSV extension will be added\): ")
		execute "w " . s:PATH . "\\" . NEWNAME . ".csv"
	endif
else
	execute "w " . s:PATH . "\\" . SWITCH_NAME . ".csv"
endif
"Reset Search Highlighting
nohl
