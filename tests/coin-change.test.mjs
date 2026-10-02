import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const source = readFileSync(new URL('../book/assets/widgets/coin-change.js', import.meta.url), 'utf8');
const CoinChange = runInNewContext(`${source}\nCoinChange`, {});

test('solve matches the lesson table and rebuilds an optimal answer', () => {
    const { dp, pick } = CoinChange.solve([1, 3, 4], 10);
    assert.deepEqual([...dp], [0, 1, 2, 1, 1, 2, 2, 2, 2, 3, 3]);
    assert.deepEqual([...CoinChange.rebuild(pick, 6)].sort(), [3, 3]);
});

test('greedy is worse on {1, 3, 4} and fails without a 1 coin', () => {
    assert.deepEqual([...CoinChange.greedy([1, 3, 4], 6)], [4, 1, 1]);
    assert.equal(CoinChange.greedy([3, 5], 7), null);
    assert.equal(CoinChange.solve([3, 5], 7).dp[7], Infinity);
});

test('parseCoins rejects bad input and dedupes', () => {
    assert.deepEqual([...CoinChange.parseCoins('4, 1 3,1')], [1, 3, 4]);
    assert.equal(CoinChange.parseCoins('1, x'), null);
    assert.equal(CoinChange.parseCoins('0'), null);
});
