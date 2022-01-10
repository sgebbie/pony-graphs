PONY_GRAPHS_SRC=$(wildcard ./*.pony)

pony-graphs: $(PONY_GRAPHS_SRC)
	ponyc -b pony-graphs .

clean:
	rm -f pony-graphs
