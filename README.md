# Pony Graph

This library provides the some basic graph related algorithms for use
with[Pony][ponylang] programmes.

The main algorithms implemented are:

* dominators
* topological sort

## Notes

* While the dominator algorithm is tested, the actual Pony API is still very
  rough and requires refinement relative to the reference capabilities supported
  for graph nodes.

[ponylang]: https://www.ponylang.org/ "Pony is an open-source, object-oriented, actor-model, capabilities-secure, high-performance programming language."

# References

[eclipse-dom]: http://help.eclipse.org/kepler/index.jsp?topic=%2Forg.eclipse.mat.ui.help%2Fconcepts%2Fdominatortree.html
[wikipedia-dom]: https://en.wikipedia.org/wiki/Dominator_(graph_theory)
[simple-dom]: http://www.hipersoft.rice.edu/grads/publications/dom14.pdf 'Cooper, Keith D.; Harvey, Timothy J; Kennedy, Ken (2001). "A Simple, Fast Dominance Algorithm"'
[fast-dom]: http://portal.acm.org/ft_gateway.cfm?id=357071&type=pdf&coll=GUIDE&dl=GUIDE&CFID=79528182&CFTOKEN=33765747 'Lengauer, Thomas; and Tarjan; Robert Endre (July 1979). "A fast algorithm for finding dominators in a flowgraph"'
[lect-dom]: http://pages.cs.wisc.edu/~fischer/cs701.f08/lectures/Lecture19.4up.pdf "Lecture notes on dominators by Charles N. Fischer"
[blog-dom]: https://tanujkhattar.wordpress.com/2016/01/11/dominator-tree-of-a-directed-graph/ "Dominator Tree of a Directed Graph by Tanuj Khattar"
