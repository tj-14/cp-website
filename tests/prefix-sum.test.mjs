import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const source = readFileSync(new URL('../book/assets/widgets/prefix-sum.js', import.meta.url), 'utf8');
const PrefixSum = runInNewContext(`${source}\nPrefixSum`, {});

test('range sums come from two prefix values', () => {
    const pref = PrefixSum.prefix([3, 1, 4, 1, 5, 9, 2, 6]);
    assert.equal(pref.join(' '), '0 3 4 8 9 14 23 25 31');
    assert.equal(pref[5] - pref[1], 1 + 4 + 1 + 5);
});

test('difference array applies overlapping range updates', () => {
    const { result } = PrefixSum.applyUpdates([0, 0, 0, 0, 0], [[2, 4, 10], [1, 2, 1], [5, 5, -3]]);
    assert.equal(result.join(' '), '1 11 10 10 -3');
});
