import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const source = readFileSync(new URL('../book/assets/widgets/complexity.js', import.meta.url), 'utf8');
const Complexity = runInNewContext(`${source}\nComplexity`, {});
const passing = (n) => Complexity.estimate(n, 1).filter((r) => r.passes).map((r) => r.label).join(' ');

test('n = 10^5 allows up to O(n log n) in one second', () => {
    assert.equal(passing(1e5), 'O(1) O(log n) O(√n) O(n) O(n log n)');
});

test('the classic size table holds at its boundaries', () => {
    assert.ok(passing(10).includes('O(n!)'));
    assert.ok(passing(20).includes('O(2ⁿ)'));
    assert.ok(passing(400).includes('O(n³)'));
    assert.ok(passing(5000).includes('O(n²)'));
});

test('huge counts are formatted without overflowing', () => {
    const fact = Complexity.estimate(1e6, 1).at(-1);
    assert.ok(Number.isFinite(fact.log10));
    assert.equal(Complexity.formatOps(fact.log10), '> 10^300');
    assert.equal(Complexity.formatTime(10), '100.0 วินาที');
});
