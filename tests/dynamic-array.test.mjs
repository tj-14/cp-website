import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const source = readFileSync(new URL('../book/assets/widgets/dynamic-array.js', import.meta.url), 'utf8');
const DynamicArray = runInNewContext(`${source}\nDynamicArray`, {});
const total = (policy, n) => DynamicArray.simulate(policy, n).copies.reduce((a, b) => a + b, 0);

test('doubling copies fewer than 2n elements in total', () => {
    assert.equal(total('double', 8), 7);
    assert.equal(DynamicArray.simulate('double', 9).cap, 16);
    assert.ok(total('double', 1000) < 2000);
});

test('growing by one copies n(n - 1) / 2 elements', () => {
    assert.equal(total('plusOne', 8), 28);
    assert.equal(total('plusOne', 1000), 499500);
});
