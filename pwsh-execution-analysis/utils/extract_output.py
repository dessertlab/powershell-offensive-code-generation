import sys

#from file with list to list
with open("exec_samples//list_exec.txt", "r") as f:
    lines = f.readlines()
    line = [line.strip() for line in lines][0]
    lista = [int(elem) for elem in line.split(",") ]
f.close()

path = sys.argv[1]
samples = []
with open(path, "r") as f:
    for i,line in enumerate(f.readlines()):
        if((i+1) in lista):
            samples.append(line.strip())
            
with open(sys.argv[2], "w") as f:
    for sample in samples:
        f.write(sample+"\n")
f.close()

