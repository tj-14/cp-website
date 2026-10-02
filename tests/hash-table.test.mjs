import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const source = readFileSync(new URL('../book/assets/widgets/hash-table.js', import.meta.url), 'utf8');
const HashTable = runInNewContext(`${source}\nHashTable`, {});
const keys = [7, 14, 21, 28, 3];

test('linear probing clusters colliding keys into consecutive slots', () => {
    const t = HashTable.build(7, 'probe', keys);
    assert.equal(JSON.stringify(t.slots), '[7,14,21,28,3,null,null]');
    const miss = HashTable.search(t, 35);
    assert.match(miss.at(-1).note, /ช่องว่างที่ 5/);
    assert.equal(miss.length, 7);  // the hash frame plus six probes
});

test('chaining keeps colliding keys in one bucket list', () => {
    const t = HashTable.build(7, 'chain', keys);
    assert.equal(JSON.stringify(t.slots[0]), '[7,14,21,28]');
    assert.equal(JSON.stringify(t.slots[3]), '[3]');
});

test('negative keys hash into range and a full probe table rejects inserts', () => {
    assert.match(HashTable.insert(HashTable.build(7, 'chain', []), -3)[0].note, /= 4$/);
    const full = HashTable.build(7, 'probe', [0, 1, 2, 3, 4, 5, 6]);
    assert.match(HashTable.insert(full, 7).at(-1).note, /เต็ม/);
});
