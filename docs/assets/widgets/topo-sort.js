// Interactive Kahn's algorithm: remove in-degree-0 nodes by queue order or by hand.
const TopoSort = (() => {
    const PRESETS = {
        dag: {
            label: 'วิชาเรียน (DAG)',
            names: ['A', 'B', 'C', 'D', 'E', 'F', 'G'],
            edges: [[0, 2], [1, 2], [1, 3], [2, 4], [3, 5], [4, 5], [5, 6]],
            pos: [[40, 50], [40, 170], [150, 50], [150, 170], [260, 50], [260, 170], [360, 110]],
        },
        cycle: {
            label: 'มี cycle',
            names: ['A', 'B', 'C', 'D', 'E'],
            edges: [[4, 0], [0, 1], [1, 2], [2, 0], [2, 3]],
            pos: [[40, 110], [150, 40], [260, 110], [360, 110], [150, 190]],
        },
    };

    function initial(g) {
        const indeg = g.names.map(() => 0);
        for (const [, v] of g.edges) indeg[v] += 1;
        const queue = indeg.map((d, i) => (d === 0 ? i : -1)).filter((i) => i >= 0);
        return { indeg, queue, order: [], removed: g.names.map(() => false) };
    }

    // Removes u (which must have in-degree 0) and returns the new state plus what changed.
    function removeNode(g, st, u) {
        const next = { indeg: [...st.indeg], queue: st.queue.filter((x) => x !== u), order: [...st.order, u], removed: [...st.removed] };
        next.removed[u] = true;
        const freed = [];
        for (const [a, b] of g.edges) {
            if (a !== u) continue;
            next.indeg[b] -= 1;
            if (next.indeg[b] === 0) {
                next.queue.push(b);
                freed.push(b);
            }
        }
        return { next, freed };
    }

    function kahn(g) {
        let st = initial(g);
        while (st.queue.length) st = removeNode(g, st, st.queue[0]).next;
        return st.order;
    }

    function renderGraph(g, st, uid, interactive) {
        const nodes = g.pos.map(([x, y], i) => {
            const cls = ['tp-node', st.removed[i] ? 'is-done' : '', !st.removed[i] && st.indeg[i] === 0 ? 'is-ready' : ''].filter(Boolean).join(' ');
            return `<g class="${cls}" data-node="${i}" ${interactive ? 'tabindex="0" role="button"' : ''} aria-label="${g.names[i]} in-degree ${st.indeg[i]}">
                <circle cx="${x}" cy="${y}" r="18"/><text x="${x}" y="${y + 5}">${g.names[i]}</text>
                <text class="tp-deg" x="${x}" y="${y - 24}">${st.removed[i] ? '' : `in ${st.indeg[i]}`}</text></g>`;
        });
        const edges = g.edges.map(([a, b]) => {
            const [x1, y1] = g.pos[a];
            const [x2, y2] = g.pos[b];
            const len = Math.hypot(x2 - x1, y2 - y1);
            const ux = (x2 - x1) / len;
            const uy = (y2 - y1) / len;
            const cls = st.removed[a] ? 'tp-edge is-gone' : 'tp-edge';
            return `<line class="${cls}" x1="${x1 + ux * 18}" y1="${y1 + uy * 18}" x2="${x2 - ux * 22}" y2="${y2 - uy * 22}" marker-end="url(#tp-arrow-${uid})"/>`;
        });
        return `<svg viewBox="0 0 400 220" width="400" height="220">
            <defs><marker id="tp-arrow-${uid}" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
            <path class="tp-arrowhead" d="M 0 0 L 10 5 L 0 10 z"/></marker></defs>${edges.join('')}${nodes.join('')}</svg>`;
    }

    function summary(g, st) {
        const left = g.names.filter((_, i) => !st.removed[i]);
        if (left.length === 0) return `ได้ topological order: ${st.order.map((i) => g.names[i]).join(' → ')}`;
        const ready = g.names.filter((_, i) => !st.removed[i] && st.indeg[i] === 0);
        if (ready.length === 0) return `ไม่มีโหนดที่ in-degree เป็น 0 เหลืออยู่ แต่ยังเหลือ ${left.join(', ')}: กราฟมี cycle จึงไม่มี topological order`;
        return `order ตอนนี้: ${st.order.map((i) => g.names[i]).join(' → ') || '(ว่าง)'}`;
    }

    function render(root, s) {
        const st = s.history[s.history.length - 1];
        root.querySelector('.tp-graph').innerHTML = renderGraph(s.g, st, s.uid, s.mode === 'pick');
        root.querySelector('.tp-queue').textContent = st.queue.map((i) => s.g.names[i]).join(', ') || '(ว่าง)';
        root.querySelector('.tp-queue-line').hidden = s.mode !== 'queue';
        root.querySelector('.widget-explain').textContent = s.message;
        root.querySelector('.tp-result').textContent = summary(s.g, st);
        root.querySelector('[data-act="next"]').hidden = s.mode !== 'queue';
        root.querySelector('[data-act="next"]').disabled = st.queue.length === 0;
        root.querySelector('[data-act="back"]').disabled = s.history.length === 1;
    }

    function template() {
        const opt = Object.entries(PRESETS).map(([k, p]) => `<option value="${k}">${p.label}</option>`).join('');
        return `
            <div class="widget-controls">
                <label>กราฟ <select name="preset">${opt}</select></label>
                <label>โหมด <select name="mode">
                    <option value="queue">ทำตาม queue (Kahn)</option>
                    <option value="pick">เลือกเองว่าจะเอาโหนดไหนออก</option></select></label>
            </div>
            <div class="tp-graph widget-table"></div>
            <p class="widget-summary tp-queue-line">queue: <span class="tp-queue"></span></p>
            <p class="widget-explain" aria-live="polite"></p>
            <div class="widget-controls">
                <button type="button" data-act="back">← ย้อนกลับ</button>
                <button type="button" data-act="next">นำหน้า queue ออก →</button>
            </div>
            <p class="widget-summary tp-result" aria-live="polite"></p>`;
    }

    function take(s, u) {
        const st = s.history[s.history.length - 1];
        const name = (i) => s.g.names[i];
        if (st.removed[u]) return;
        if (st.indeg[u] > 0) {
            const from = s.g.edges.filter(([a, b]) => b === u && !st.removed[a]).map(([a]) => name(a));
            s.message = `${name(u)} ยังมี edge เข้ามาจาก ${from.join(', ')} ต้องเอาโหนดเหล่านั้นออกก่อน`;
            return;
        }
        const { next, freed } = removeNode(s.g, st, u);
        s.history.push(next);
        const outs = s.g.edges.filter(([a]) => a === u).map(([, b]) => name(b));
        s.message = `เอา ${name(u)} ออก`
            + (outs.length ? ` ลด in-degree ของ ${outs.join(', ')}` : '')
            + (freed.length ? ` ทำให้ ${freed.map(name).join(', ')} เหลือ 0 จึงพร้อมแล้ว` : '');
    }

    let counter = 0;

    function mount(root) {
        root.innerHTML = template();
        const s = { uid: counter++ };
        const reset = () => {
            s.g = PRESETS[root.querySelector('[name="preset"]').value];
            s.mode = root.querySelector('[name="mode"]').value;
            s.history = [initial(s.g)];
            s.message = s.mode === 'queue'
                ? 'เริ่มจากใส่ทุกโหนดที่ in-degree = 0 (ไม่มีวิชาบังคับก่อน) ลง queue'
                : 'คลิกโหนดที่ in-degree = 0 (กรอบเขียว) ลองเลือกหลายแบบ จะได้ order ต่างกันแต่ถูกทั้งหมด';
            render(root, s);
        };
        const pick = (target) => {
            const node = target.closest?.('[data-node]');
            if (!node || s.mode !== 'pick') return false;
            const u = Number(node.dataset.node);
            take(s, u);
            render(root, s);
            root.querySelector(`[data-node="${u}"]`)?.focus();
            return true;
        };
        root.addEventListener('click', (event) => {
            if (pick(event.target)) return;
            const act = event.target.dataset?.act;
            if (act === 'next') take(s, s.history.at(-1).queue[0]);
            if (act === 'back') {
                s.history.pop();
                s.message = '';
            }
            if (act) render(root, s);
        });
        root.addEventListener('keydown', (event) => {
            if ((event.key === 'Enter' || event.key === ' ') && pick(event.target)) event.preventDefault();
        });
        root.querySelectorAll('select').forEach((el) => el.addEventListener('change', reset));
        reset();
    }

    return { PRESETS, initial, removeNode, kahn, mount };
})();

if (typeof document !== 'undefined') {
    document.querySelectorAll('[data-widget="topo-sort"]').forEach(TopoSort.mount);
}
