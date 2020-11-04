## List Java procceses running
jps

## Threadup of the JVM
jstack -l <PID>

## Print the memory statistics of the JVM
jmap -dump:file=DumpFile.txt <process-id>