all: adapter.o 


adapter.o: adapter.cpp
	nvcc -ccbin=g++ $< -Xcompiler=-fpermissive -c -o $@

clean:
	rm -rf adapter.o

