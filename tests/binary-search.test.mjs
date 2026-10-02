import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const source = readFileSync(new URL('../book/assets/widgets/binary-search.js', import.meta.url), 'utf8');
const BinarySearch = runInNewContext(`${source}\nBinarySearch`, {});
const a = [1, 3, 3, 5, 6, 8, 9, 12, 12, 15, 17, 20, 21, 24, 27, 30];
const lb = (x) => BinarySearch.lowerBoundSteps(a, x).answer;

test('lower_bound finds the first index with a[i] >= x', () => {
    assert.equal(lb(12), 7);   // first of the duplicates
    assert.equal(lb(13), 9);
    assert.equal(lb(0), 0);
    assert.equal(lb(31), 16);  // none: n
});

test('step count stays within ceil(log2(n + 1))', () => {
    for (let x = 0; x <= 31; x++) {
        assert.ok(BinarySearch.lowerBoundSteps(a, x).steps.length <= 5, `x = ${x}`);
    }
});
