// Interactive recursion call tree: grow fib(n) / factorial(n) one call at a time.
const RecursionTree = (() => {
    const FUNCS = {
        fib: { name: 'fib', max: 6, base: (n) => n <= 1, baseValue: (n) => n, args: (n) => [n - 1, n - 2] },
        factorial: { name: 'factorial', max: 8, base: (n) => n <= 1, baseValue: () => 1, args: (n) => [n - 1] },
    };

    // Returns every call as a node plus the call/return events in execution order.
    function trace(key, n, memo) {
        const fn = FUNCS[key];
        const nodes = [];
        const events = [];
        const cache = new Map();
        const finished = new Set();
        const rec = (arg, parent, depth) => {
            const node = { id: nodes.length, arg, parent, depth, children: [], value: null, kind: 'call' };
            node.repeat = !memo && finished.has(arg);
            nodes.push(node);
            if (parent !== null) nodes[parent].children.push(node.id);
            events.push({ type: 'call', id: node.id });
            if (memo && cache.has(arg)) {
                node.kind = 'memo';
                node.value = cache.get(arg);
            } else if (fn.base(arg)) {
                node.kind = 'base';
                node.value = fn.baseValue(arg);
            } else {
                const parts = fn.args(arg).map((a) => rec(a, node.id, depth + 1));
                node.value = key === 'fib' ? parts[0] + parts[1] : arg * parts[0];
            }
            if (memo) cache.set(arg, node.value);
            finished.add(arg);
            events.push({ type: 'return', id: node.id });
            return node.value;
        };
        rec(n, null, 0);
        return { nodes, events };
    }

    // Leaves take consecutive columns; a parent sits centred over its children.
    function layout(nodes) {
        let column = 0;
        const place = (node) => {
            if (node.children.length === 0) {
                node.x = column++;
            } else {
                node.children.forEach((c) => place(nodes[c]));
                const xs = node.children.map((c) => nodes[c].x);
                node.x = (Math.min(...xs) + Math.max(...xs)) / 2;
            }
        };
        place(nodes[0]);
        return column;
    }

    function stateAt(t, step) {
        const called = new Set();
        const returned = new Set();
        const stack = [];
        for (const ev of t.events.slice(0, step)) {
            if (ev.type === 'call') {
                called.add(ev.id);
                stack.push(ev.id);
            } else {
                returned.add(ev.id);
                stack.pop();
            }
        }
        return { called, returned, stack };
    }

    function describe(s, ev) {
        if (!ev) return 'กด "ถัดไป" เพื่อเริ่มเรียกฟังก์ชัน';
        const node = s.t.nodes[ev.id];
        const label = `${s.fn.name}(${node.arg})`;
        if (ev.type === 'call') {
            if (node.kind === 'memo') return `เรียก ${label} - มีคำตอบใน memo แล้ว ไม่ต้องคำนวณซ้ำ`;
            const note = node.repeat ? ' (เคยคำนวณไปแล้ว แต่ต้องคำนวณใหม่ทั้งหมด!)' : '';
            return `เรียก ${label}${note}`;
        }
        if (node.kind === 'memo') return `${label} คืนค่า ${node.value} จาก memo ทันที`;
        if (node.kind === 'base') return `${label} เป็น base case คืนค่า ${node.value}`;
        const kids = node.children.map((c) => s.t.nodes[c]);
        const expr = s.key === 'fib'
            ? `${kids[0].value} + ${kids[1].value}`
            : `${node.arg} × ${kids[0].value}`;
        return `${label} = ${expr} = ${node.value} แล้วคืนค่ากลับไปให้ผู้เรียก`;
    }

    function nodeClass(node, st) {
        const cls = ['rt-node'];
        if (st.stack.includes(node.id)) cls.push('is-active');
        if (st.stack[st.stack.length - 1] === node.id) cls.push('is-current');
        if (st.returned.has(node.id)) cls.push('is-done');
        if (node.repeat) cls.push('is-repeat');
        if (node.kind === 'memo') cls.push('is-memo');
        return cls.join(' ');
    }

    function renderTree(root, s, st) {
        const W = 58;
        const H = 62;
        const width = s.columns * W;
        const height = (Math.max(...s.t.nodes.map((n) => n.depth)) + 1) * H;
        const cx = (n) => n.x * W + W / 2;
        const cy = (n) => n.depth * H + 22;
        const shown = s.t.nodes.filter((n) => st.called.has(n.id));
        const edges = shown.filter((n) => n.parent !== null).map((n) => {
            const p = s.t.nodes[n.parent];
            return `<line class="rt-edge" x1="${cx(p)}" y1="${cy(p) + 14}" x2="${cx(n)}" y2="${cy(n) - 14}"/>`;
        });
        const prefix = s.key === 'fib' ? 'f' : 'fact';
        const circles = shown.map((n) => {
            const value = st.returned.has(n.id) ? `<text class="rt-value" x="${cx(n)}" y="${cy(n) + 30}">=${n.value}</text>` : '';
            return `<g class="${nodeClass(n, st)}"><rect x="${cx(n) - 26}" y="${cy(n) - 14}" width="52" height="28" rx="6"/>`
                + `<text x="${cx(n)}" y="${cy(n) + 5}">${prefix}(${n.arg})</text>${value}</g>`;
        });
        root.querySelector('.rt-tree').innerHTML = `<svg width="${width}" height="${height}" viewBox="0 0 ${width} ${height}" aria-hidden="true">${edges.join('')}${circles.join('')}</svg>`;
    }

    function render(root, s) {
        const st = stateAt(s.t, s.step);
        renderTree(root, s, st);
        const stack = st.stack.map((id) => `${s.fn.name}(${s.t.nodes[id].arg})`);
        root.querySelector('.rt-stack').textContent = stack.length ? stack.join(' → ') : '(ว่าง)';
        root.querySelector('.widget-explain').textContent = describe(s, s.t.events[s.step - 1]);
        const calls = st.called.size;
        const total = s.t.nodes.length;
        const repeats = s.t.nodes.filter((n) => st.called.has(n.id) && n.repeat).length;
        root.querySelector('.rt-counts').textContent =
            `เรียกฟังก์ชันแล้ว ${calls}/${total} ครั้ง` + (repeats ? `, เป็นการคำนวณซ้ำ ${repeats} ครั้ง` : '');
        const done = s.step >= s.t.events.length;
        root.querySelector('[data-act="back"]').disabled = s.step === 0;
        root.querySelector('[data-act="next"]').disabled = done;
        root.querySelector('[data-act="all"]').disabled = done;
    }

    function template() {
        return `
            <div class="widget-controls">
                <label>ฟังก์ชัน <select name="fn"><option value="fib">fib(n)</option><option value="factorial">factorial(n)</option></select></label>
                <label>n <input name="n" type="number" min="0" max="6" value="5"></label>
                <label><input name="memo" type="checkbox"> ใช้ memoization</label>
            </div>
            <div class="rt-tree widget-table" tabindex="0" role="region" aria-label="call tree"></div>
            <p class="widget-explain" aria-live="polite"></p>
            <p class="widget-summary">call stack: <span class="rt-stack"></span></p>
            <div class="widget-controls">
                <button type="button" data-act="back">← ย้อนกลับ</button>
                <button type="button" data-act="next">ถัดไป →</button>
                <button type="button" data-act="all">ทำจนจบ</button>
                <button type="button" data-act="reset">เริ่มใหม่</button>
            </div>
            <p class="widget-summary rt-counts"></p>`;
    }

    function mount(root) {
        root.innerHTML = template();
        let s = null;
        const reset = () => {
            const key = root.querySelector('[name="fn"]').value;
            const fn = FUNCS[key];
            const input = root.querySelector('[name="n"]');
            const memoBox = root.querySelector('[name="memo"]');
            input.max = fn.max;
            const n = Math.min(Math.max(Number(input.value) || 0, 0), fn.max);
            input.value = n;
            memoBox.disabled = key !== 'fib';
            const t = trace(key, n, key === 'fib' && memoBox.checked);
            s = { key, fn, t, columns: layout(t.nodes), step: 0 };
            render(root, s);
        };
        const actions = {
            next: () => { s.step += 1; },
            back: () => { s.step -= 1; },
            all: () => { s.step = s.t.events.length; },
        };
        root.addEventListener('click', (event) => {
            const act = event.target.dataset?.act;
            if (!act || !s) return;
            if (act === 'reset') return reset();
            actions[act]();
            render(root, s);
        });
        root.querySelectorAll('[name="fn"], [name="n"], [name="memo"]')
            .forEach((el) => el.addEventListener('change', reset));
        reset();
    }

    return { trace, layout, stateAt, mount };
})();

if (typeof document !== 'undefined') {
    document.querySelectorAll('[data-widget="recursion-tree"]').forEach(RecursionTree.mount);
}
