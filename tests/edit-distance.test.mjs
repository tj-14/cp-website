import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const source = readFileSync(new URL('../book/assets/widgets/edit-distance.js', import.meta.url), 'utf8');
const ED = runInNewContext(`${source}\nEditDistance`, {});
const dist = (a, b) => ED.solve(a, b)[a.length][b.length];

test('edit distance matches known pairs', () => {
    assert.equal(dist('LOVE', 'MOVIE'), 2);
    assert.equal(dist('KITTEN', 'SITTING'), 3);
    assert.equal(dist('', 'ABC'), 3);
    assert.equal(dist('SAME', 'SAME'), 0);
});

test('the traced edits explain the distance', () => {
    const dp = ED.solve('LOVE', 'MOVIE');
    const { ops, cells } = ED.trace('LOVE', 'MOVIE', dp);
    assert.equal(ops.filter((o) => !o.startsWith('คง')).join(', '), 'แทน L ด้วย M, เพิ่ม I');
    assert.equal(cells.at(-1).join(','), '0,0');
});
