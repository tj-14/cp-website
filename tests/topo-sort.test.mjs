import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const source = readFileSync(new URL('../book/assets/widgets/topo-sort.js', import.meta.url), 'utf8');
const TopoSort = runInNewContext(`${source}\nTopoSort`, {});
const names = (g, order) => order.map((i) => g.names[i]).join('');

test('Kahn orders the DAG so every edge points forward', () => {
    const g = TopoSort.PRESETS.dag;
    const order = TopoSort.kahn(g);
    assert.equal(names(g, order), 'ABCDEFG');
    const at = new Map(order.map((u, i) => [u, i]));
    for (const [a, b] of g.edges) assert.ok(at.get(a) < at.get(b));
});

test('a cycle leaves nodes behind', () => {
    const g = TopoSort.PRESETS.cycle;
    assert.equal(names(g, TopoSort.kahn(g)), 'E');
});

test('removing a node frees successors whose in-degree hits zero', () => {
    const g = TopoSort.PRESETS.dag;
    const { next, freed } = TopoSort.removeNode(g, TopoSort.initial(g), 1);  // B
    assert.equal(names(g, freed), 'D');
    assert.equal(next.indeg[2], 1);  // C still waits for A
});
