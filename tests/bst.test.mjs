import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const source = readFileSync(new URL('../book/assets/widgets/bst.js', import.meta.url), 'utf8');
const Bst = runInNewContext(`${source}\nBst`, {});
const build = (keys) => keys.reduce((t, k) => Bst.insert(t, k).tree, null);
const order = (t, kind) => Bst.traversal(t, kind).join(' ');

test('traversals of the balanced example', () => {
    const t = build([50, 30, 70, 20, 40, 60, 80]);
    assert.equal(order(t, 'in'), '20 30 40 50 60 70 80');
    assert.equal(order(t, 'pre'), '50 30 20 40 70 60 80');
    assert.equal(order(t, 'post'), '20 40 30 60 80 70 50');
    assert.equal(order(t, 'level'), '50 30 70 20 40 60 80');
});

test('delete handles leaf, one child, two children, and the root', () => {
    let t = build([50, 30, 70, 20, 40, 60, 80, 65]);
    t = Bst.remove(t, 20).tree;          // leaf
    t = Bst.remove(t, 60).tree;          // one child (65)
    t = Bst.remove(t, 50).tree;          // root with two children -> successor 65
    assert.equal(order(t, 'in'), '30 40 65 70 80');
    assert.equal(t.key, 65);
    assert.equal(order(Bst.remove(build([5]), 5).tree, 'in'), '');
});

test('sorted inserts degenerate into a chain; search reports misses', () => {
    assert.equal(Bst.height(build([10, 20, 30, 40, 50, 60])), 6);
    const frames = Bst.search(build([50, 30, 70]), 35);
    assert.match(frames.at(-1).note, /ไม่มี 35/);
});
