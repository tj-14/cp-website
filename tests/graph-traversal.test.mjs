import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const source = readFileSync(new URL('../book/assets/widgets/graph-traversal.js', import.meta.url), 'utf8');
const GraphTraversal = runInNewContext(`${source}\nGraphTraversal`, {});

const edges = [[0, 1], [0, 2], [0, 3], [1, 4], [2, 4], [2, 5], [3, 6], [4, 7], [5, 7], [6, 7]];
const adj = GraphTraversal.adjacency(8, edges);

test('BFS visits by layer and records distances; DFS goes deep first', () => {
    const b = GraphTraversal.bfs(adj, 0);
    assert.equal(b.map((st) => st.u).join(' '), '0 1 2 3 4 5 6 7');
    assert.equal(b[b.length - 1].dist.join(' '), '0 1 1 1 2 2 2 3');
    assert.equal(GraphTraversal.dfs(adj, 0).map((st) => st.u).join(' '), '0 1 4 2 5 7 6 3');
});

test('traversal stays inside the start component', () => {
    const two = GraphTraversal.adjacency(5, [[0, 1], [1, 2], [3, 4]]);
    assert.equal(GraphTraversal.bfs(two, 3).map((st) => st.u).join(' '), '3 4');
});

test('parseEdges accepts common separators and rejects self-loops', () => {
    assert.equal(GraphTraversal.parseEdges('0-1; 1 2\n2,3').n, 4);
    assert.equal(GraphTraversal.parseEdges('1-1'), null);
    assert.equal(GraphTraversal.parseEdges('0-12'), null);
});
