import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const source = readFileSync(new URL('../book/assets/widgets/heap.js', import.meta.url), 'utf8');
const Heap = runInNewContext(`${source}\nHeap`, {});
const last = (frames) => [...frames.at(-1).a];
const isMinHeap = (a) => a.every((v, i) => i === 0 || a[Math.floor((i - 1) / 2)] <= v);

test('insert sifts a small value up to the root', () => {
    const frames = Heap.insertFrames([3, 8, 5, 12, 10, 7], 1);
    assert.deepEqual(last(frames), [1, 8, 3, 12, 10, 7, 5]);
});

test('extract-min returns the heap property', () => {
    const after = last(Heap.extractFrames([3, 8, 5, 12, 10, 7]));
    assert.deepEqual(after, [5, 8, 7, 12, 10]);
    assert.ok(isMinHeap(after));
});

test('repeated extraction yields sorted order (heap sort)', () => {
    let heap = [];
    for (const x of [9, 4, 7, 1, 8, 2, 6]) heap = last(Heap.insertFrames(heap, x));
    const out = [];
    while (heap.length) {
        out.push(heap[0]);
        heap = last(Heap.extractFrames(heap));
    }
    assert.deepEqual(out, [1, 2, 4, 6, 7, 8, 9]);
});
