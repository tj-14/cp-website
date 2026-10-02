import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const source = readFileSync(new URL('../book/assets/widgets/recursion-tree.js', import.meta.url), 'utf8');
const RecursionTree = runInNewContext(`${source}\nRecursionTree`, {});

test('fib(5) makes 15 calls, 9 of them repeats; memoization cuts it to 2n - 1', () => {
    const plain = RecursionTree.trace('fib', 5, false);
    assert.equal(plain.nodes.length, 15);
    assert.equal(plain.nodes[0].value, 5);
    assert.equal(plain.nodes.filter((n) => n.repeat).length, 9);
    const memo = RecursionTree.trace('fib', 5, true);
    assert.equal(memo.nodes.length, 9);
    assert.equal(memo.nodes[0].value, 5);
});

test('call stack follows the events and empties at the end', () => {
    const t = RecursionTree.trace('factorial', 4, false);
    assert.equal(t.nodes[0].value, 24);
    assert.deepEqual([...RecursionTree.stateAt(t, 4).stack], [0, 1, 2, 3]);
    assert.equal(RecursionTree.stateAt(t, t.events.length).stack.length, 0);
});
