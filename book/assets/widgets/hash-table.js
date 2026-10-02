// Interactive hash table: h(k) = k mod m with separate chaining or linear probing.
const HashTable = (() => {
    const PRESETS = {
        spread: [15, 8, 23, 4, 42],
        collide: [7, 14, 21, 28, 3],
    };

    const empty = (m, method) => ({ m, method, slots: method === 'chain' ? Array.from({ length: m }, () => []) : Array(m).fill(null) });
    const clone = (t) => ({ ...t, slots: t.slots.map((x) => (Array.isArray(x) ? [...x] : x)) });
    const mod = (k, m) => ((k % m) + m) % m;

    // Returns frames that probe slot by slot; the last frame holds the updated table.
    function insert(table, k) {
        const t = clone(table);
        const h = mod(k, t.m);
        const frames = [{ t: clone(t), hl: [h], note: `h(${k}) = ${k} mod ${t.m} = ${h}` }];
        if (t.method === 'chain') {
            if (t.slots[h].includes(k)) {
                frames.push({ t: clone(t), hl: [h], note: `${k} มีอยู่แล้วใน bucket ${h}` });
                return frames;
            }
            t.slots[h].push(k);
            const note = t.slots[h].length > 1 ? `bucket ${h} มีข้อมูลอยู่แล้ว (collision) จึงต่อท้าย list` : `ใส่ ${k} ใน bucket ${h}`;
            frames.push({ t: clone(t), hl: [h], note });
            return frames;
        }
        for (let step = 0; step < t.m; step++) {
            const i = (h + step) % t.m;
            if (t.slots[i] === k) {
                frames.push({ t: clone(t), hl: [i], note: `${k} มีอยู่แล้วที่ช่อง ${i}` });
                return frames;
            }
            if (t.slots[i] === null) {
                t.slots[i] = k;
                frames.push({ t: clone(t), hl: [i], note: `ช่อง ${i} ว่าง ใส่ ${k} (ตรวจไป ${step + 1} ช่อง)` });
                return frames;
            }
            frames.push({ t: clone(t), hl: [i], note: `ช่อง ${i} มี ${t.slots[i]} แล้ว (collision) ขยับไปช่อง ${(i + 1) % t.m}` });
        }
        frames.push({ t: clone(t), hl: [], note: 'ตารางเต็มแล้ว ใส่ไม่ได้' });
        return frames;
    }

    function search(t, k) {
        const h = mod(k, t.m);
        const frames = [{ t, hl: [h], note: `h(${k}) = ${h}` }];
        if (t.method === 'chain') {
            const found = t.slots[h].includes(k);
            frames.push({ t, hl: [h], note: found ? `ไล่ list ใน bucket ${h} แล้วเจอ ${k}` : `ไล่ list ใน bucket ${h} ครบแล้ว ไม่มี ${k}` });
            return frames;
        }
        for (let step = 0; step < t.m; step++) {
            const i = (h + step) % t.m;
            if (t.slots[i] === null) {
                frames.push({ t, hl: [i], note: `เจอช่องว่างที่ ${i} จึงสรุปได้ว่าไม่มี ${k} (ตรวจ ${step + 1} ช่อง)` });
                return frames;
            }
            if (t.slots[i] === k) {
                frames.push({ t, hl: [i], note: `เจอ ${k} ที่ช่อง ${i} (ตรวจ ${step + 1} ช่อง)` });
                return frames;
            }
            frames.push({ t, hl: [i], note: `ช่อง ${i} เป็น ${t.slots[i]} ไม่ใช่ ${k} ตรวจช่องถัดไป` });
        }
        frames.push({ t, hl: [], note: `ตรวจครบทุกช่องแล้ว ไม่มี ${k}` });
        return frames;
    }

    function size(t) {
        return t.method === 'chain' ? t.slots.reduce((a, b) => a + b.length, 0) : t.slots.filter((x) => x !== null).length;
    }

    function render(root, s) {
        const f = s.frames[s.step] || { t: s.table, hl: [], note: s.note };
        const rows = f.t.slots.map((x, i) => {
            const content = Array.isArray(x)
                ? (x.length ? x.map((k) => `<span class="ht-key">${k}</span>`).join('<span class="ht-arrow">→</span>') : '<span class="ht-empty">ว่าง</span>')
                : (x === null ? '<span class="ht-empty">ว่าง</span>' : `<span class="ht-key">${x}</span>`);
            return `<div class="ht-row${f.hl.includes(i) ? ' is-hl' : ''}"><span class="ht-index">${i}</span>${content}</div>`;
        });
        root.querySelector('.ht-table').innerHTML = rows.join('');
        root.querySelector('.widget-explain').textContent = f.note;
        const n = size(s.table);
        root.querySelector('.widget-summary').textContent = `ข้อมูล ${n} ตัว, ${s.table.m} ช่อง, load factor = ${(n / s.table.m).toFixed(2)}`;
        const busy = s.step < s.frames.length - 1;
        root.querySelectorAll('.ht-ops button').forEach((b) => { b.disabled = busy; });
        root.querySelector('[data-act="next"]').disabled = !busy;
        root.querySelector('[data-act="finish"]').disabled = !busy;
    }

    function template() {
        return `
            <div class="widget-controls">
                <label>วิธีจัดการ collision <select name="method">
                    <option value="chain">separate chaining</option>
                    <option value="probe">linear probing</option></select></label>
                <label>ขนาดตาราง m <select name="m"><option>7</option><option>10</option><option>11</option></select></label>
                <label>ตัวอย่าง <select name="preset">
                    <option value="spread">กระจายดี</option>
                    <option value="collide">ชนกันเยอะ</option></select></label>
            </div>
            <div class="widget-controls ht-ops">
                <label>key <input name="key" type="number" value="35"></label>
                <button type="button" data-act="insert">insert</button>
                <button type="button" data-act="search">search</button>
            </div>
            <div class="ht-table"></div>
            <p class="widget-explain" aria-live="polite"></p>
            <div class="widget-controls">
                <button type="button" data-act="next">ขั้นถัดไป →</button>
                <button type="button" data-act="finish">ทำจนจบ</button>
            </div>
            <p class="widget-summary"></p>`;
    }

    function build(m, method, keys) {
        let t = empty(m, method);
        for (const k of keys) t = insert(t, k).at(-1).t;
        return t;
    }

    function mount(root) {
        root.innerHTML = template();
        const s = { table: null, frames: [], step: 0, note: '' };
        const val = (name) => root.querySelector(`[name="${name}"]`).value;
        const reset = () => {
            s.table = build(Number(val('m')), val('method'), PRESETS[val('preset')]);
            s.frames = [];
            s.note = `ใส่ ${PRESETS[val('preset')].join(', ')} ไว้แล้ว ลอง insert หรือ search key อื่น`;
            render(root, s);
        };
        root.addEventListener('click', (event) => {
            const act = event.target.dataset?.act;
            if (!act) return;
            const k = Number(val('key')) || 0;
            if (act === 'insert') {
                s.frames = insert(s.table, k);
                s.table = s.frames.at(-1).t;
                s.step = 0;
            } else if (act === 'search') {
                s.frames = search(s.table, k);
                s.step = 0;
            } else if (act === 'next') {
                s.step += 1;
            } else if (act === 'finish') {
                s.step = s.frames.length - 1;
            }
            render(root, s);
        });
        root.querySelectorAll('select').forEach((el) => el.addEventListener('change', reset));
        reset();
    }

    return { insert, search, build, mount };
})();

if (typeof document !== 'undefined') {
    document.querySelectorAll('[data-widget="hash-table"]').forEach(HashTable.mount);
}
