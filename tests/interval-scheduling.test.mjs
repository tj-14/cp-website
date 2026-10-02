import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const source = readFileSync(new URL('../book/assets/widgets/interval-scheduling.js', import.meta.url), 'utf8');
const IS = runInNewContext(`${source}\nIntervalScheduling`, {});
const jobs = (k) => IS.toJobs(IS.PRESETS[k].jobs);
const picked = (k, rule) => IS.run(jobs(k), rule).chosen.map((j) => j.name).join('');

test('earliest end picks A and D in the lesson example', () => {
    assert.equal(picked('lesson', 'end'), 'AD');
});

test('each wrong rule has a preset where it loses', () => {
    assert.equal(picked('longFirst', 'start'), 'A');
    assert.equal(IS.optimum(jobs('longFirst')), 4);
    assert.equal(picked('shortMiddle', 'short'), 'C');
    assert.equal(IS.optimum(jobs('shortMiddle')), 2);
});

test('touching intervals do not overlap', () => {
    assert.equal(IS.run(IS.toJobs([['X', 0, 2], ['Y', 2, 4]]), 'end').chosen.length, 2);
});
