import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const source = readFileSync(new URL('../book/assets/widgets/stack-queue.js', import.meta.url), 'utf8');
const StackQueue = runInNewContext(`${source}\nStackQueue`, {});
const verdict = (text) => StackQueue.bracketSteps(text).at(-1).verdict;

test('bracket checker accepts nested pairs and rejects each failure kind', () => {
    assert.equal(verdict('{[()()]}'), true);
    assert.equal(verdict('([)]'), false);   // wrong closing order
    assert.equal(verdict(')('), false);     // close before open
    assert.equal(verdict('(('), false);     // leftovers
    assert.equal(verdict(''), true);
});

test('checker stops at the first mismatch', () => {
    const steps = StackQueue.bracketSteps('(]))');
    assert.equal(steps.length, 2);
    assert.equal(steps[1].i, 1);
});
