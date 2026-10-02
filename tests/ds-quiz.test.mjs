import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const source = readFileSync(new URL('../book/assets/widgets/ds-quiz.js', import.meta.url), 'utf8');
const DsQuiz = runInNewContext(`${source}\nDsQuiz`, {});

test('every question has a valid answer index and an explanation', () => {
    for (const item of DsQuiz.QUESTIONS) {
        assert.ok(item.answer >= 0 && item.answer < item.options.length, item.q);
        assert.ok(item.why.length > 0, item.q);
        assert.equal(new Set(item.options).size, item.options.length, item.q);
    }
});
