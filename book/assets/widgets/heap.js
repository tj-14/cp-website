// Interactive binary min-heap: insert and extract-min one sift step at a time.
const Heap = (() => {
    const MAX_SIZE = 15;

    // Each frame is a snapshot of the array, the highlighted indices, and an explanation.
    function insertFrames(heap, x) {
        const a = [...heap, x];
        let i = a.length - 1;
        const frames = [{ a: [...a], hl: [i], note: `ใส่ ${x} ที่ช่องว่างตัวสุดท้าย (index ${i})` }];
        while (i > 0) {
            const p = Math.floor((i - 1) / 2);
            if (a[p] <= a[i]) {
                frames.push({ a: [...a], hl: [p, i], note: `parent ${a[p]} ≤ ${a[i]} จึงหยุด heap ถูกต้องแล้ว` });
                return frames;
            }
            [a[p], a[i]] = [a[i], a[p]];
            frames.push({ a: [...a], hl: [p, i], note: `${a[p]} น้อยกว่า parent ${a[i]} จึงสลับขึ้นไป (sift up)` });
            i = p;
        }
        frames.push({ a: [...a], hl: [0], note: `${a[0]} ขึ้นถึง root แล้ว` });
        return frames;
    }

    function extractFrames(heap) {
        const a = [...heap];
        const min = a[0];
        const last = a.pop();
        if (a.length === 0) return [{ a: [], hl: [], note: `นำ ${min} ออก heap ว่างแล้ว` }];
        a[0] = last;
        const frames = [{ a: [...a], hl: [0], note: `นำ root ${min} (ค่าน้อยสุด) ออก แล้วย้ายตัวสุดท้าย ${last} ขึ้นมาแทน` }];
        let i = 0;
        for (;;) {
            const l = 2 * i + 1;
            const r = 2 * i + 2;
            let c = l;
            if (l >= a.length) break;
            if (r < a.length && a[r] < a[l]) c = r;
            if (a[i] <= a[c]) {
                frames.push({ a: [...a], hl: [i, c], note: `${a[i]} ≤ ลูกที่น้อยกว่า (${a[c]}) จึงหยุด` });
                return frames;
            }
            [a[i], a[c]] = [a[c], a[i]];
            frames.push({ a: [...a], hl: [i, c], note: `${a[c]} มากกว่าลูกที่น้อยกว่า (${a[i]}) จึงสลับลงไป (sift down)` });
            i = c;
        }
        frames.push({ a: [...a], hl: [i], note: `${a[i]} ถึงใบ (leaf) แล้ว` });
        return frames;
    }

    function renderTree(a, hl) {
        const W = 400;
        const pos = (i) => {
            const depth = Math.floor(Math.log2(i + 1));
            const first = 2 ** depth - 1;
            const slots = 2 ** depth;
            return [((i - first + 0.5) / slots) * W, 26 + depth * 58];
        };
        const edges = a.map((_, i) => {
            if (i === 0) return '';
            const [x1, y1] = pos(Math.floor((i - 1) / 2));
            const [x2, y2] = pos(i);
            return `<line class="hp-edge" x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}"/>`;
        });
        const nodes = a.map((v, i) => {
            const [x, y] = pos(i);
            const cls = hl.includes(i) ? 'hp-node is-hl' : 'hp-node';
            return `<g class="${cls}"><circle cx="${x}" cy="${y}" r="17"/><text x="${x}" y="${y + 5}">${v}</text></g>`;
        });
        const levels = a.length ? Math.floor(Math.log2(a.length)) + 1 : 1;
        const H = 52 + (levels - 1) * 58;
        return `<svg viewBox="0 0 ${W} ${H}" width="${W}" height="${H}" aria-hidden="true">${edges.join('')}${nodes.join('')}</svg>`;
    }

    function renderArray(a, hl) {
        const cells = a.map((v, i) => `<span class="hp-cell${hl.includes(i) ? ' is-hl' : ''}"><small>${i}</small>${v}</span>`);
        return cells.join('') || '<em>ว่าง</em>';
    }

    function render(root, s) {
        const frame = s.frames[s.step] || { a: s.heap, hl: [], note: s.note };
        root.querySelector('.hp-tree').innerHTML = renderTree(frame.a, frame.hl);
        root.querySelector('.hp-array').innerHTML = renderArray(frame.a, frame.hl);
        root.querySelector('.widget-explain').textContent = frame.note;
        const busy = s.step < s.frames.length - 1;
        root.querySelectorAll('[data-act="insert"], [data-act="extract"], [data-act="random"]')
            .forEach((b) => { b.disabled = busy; });
        root.querySelector('[data-act="extract"]').disabled = busy || s.heap.length === 0;
        root.querySelector('[data-act="insert"]').disabled = busy || s.heap.length >= MAX_SIZE;
        root.querySelector('[data-act="next"]').disabled = !busy;
        root.querySelector('[data-act="finish"]').disabled = !busy;
    }

    function template() {
        return `
            <div class="widget-controls">
                <label>ค่า <input name="value" type="number" value="5"></label>
                <button type="button" data-act="insert">insert</button>
                <button type="button" data-act="extract">extract min</button>
                <button type="button" data-act="random">สุ่ม heap ใหม่</button>
            </div>
            <div class="hp-tree widget-table"></div>
            <div class="hp-array" aria-hidden="true"></div>
            <p class="widget-explain" aria-live="polite"></p>
            <div class="widget-controls">
                <button type="button" data-act="next">ขั้นถัดไป →</button>
                <button type="button" data-act="finish">ทำจนจบ</button>
            </div>`;
    }

    function randomHeap() {
        let heap = [];
        for (let k = 0; k < 7; k++) {
            const frames = insertFrames(heap, 1 + Math.floor(Math.random() * 60));
            heap = frames[frames.length - 1].a;
        }
        return heap;
    }

    function mount(root) {
        root.innerHTML = template();
        const s = { heap: [3, 8, 5, 12, 10, 7], frames: [], step: 0, note: 'min-heap: ทุก parent ≤ ลูกของตัวเอง ค่าน้อยสุดจึงอยู่ที่ root' };
        const start = (frames) => {
            s.frames = frames;
            s.step = 0;
            s.heap = frames[frames.length - 1].a;
        };
        const actions = {
            insert: () => {
                const input = root.querySelector('[name="value"]');
                start(insertFrames(s.heap, Number(input.value) || 0));
            },
            extract: () => start(extractFrames(s.heap)),
            random: () => {
                s.heap = randomHeap();
                s.frames = [];
                s.note = 'สุ่ม heap ใหม่แล้ว ลอง insert หรือ extract min';
            },
            next: () => { s.step += 1; },
            finish: () => { s.step = s.frames.length - 1; },
        };
        root.addEventListener('click', (event) => {
            const act = event.target.dataset?.act;
            if (!act) return;
            actions[act]();
            render(root, s);
        });
        render(root, s);
    }

    return { insertFrames, extractFrames, mount };
})();

if (typeof document !== 'undefined') {
    document.querySelectorAll('[data-widget="heap"]').forEach(Heap.mount);
}
