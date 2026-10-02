// Interactive BFS / DFS: visit one node per step and show the queue or call stack.
const GraphTraversal = (() => {
    const PRESETS = {
        layers: {
            n: 8,
            edges: [[0, 1], [0, 2], [0, 3], [1, 4], [2, 4], [2, 5], [3, 6], [4, 7], [5, 7], [6, 7]],
            pos: [[200, 30], [80, 105], [200, 105], [320, 105], [80, 185], [200, 185], [320, 185], [200, 255]],
        },
        components: {
            n: 7,
            edges: [[0, 1], [1, 2], [2, 0], [2, 3], [4, 5], [5, 6]],
            pos: [[60, 60], [170, 30], [150, 140], [60, 220], [270, 90], [340, 180], [250, 240]],
        },
    };

    // Accepts "0 1", "0-1" or "0,1" pairs separated by newlines or semicolons; nodes 0-9.
    function parseEdges(text) {
        const pairs = text.split(/[\n;]+/).map((s) => s.trim()).filter(Boolean);
        const edges = [];
        for (const pair of pairs) {
            const m = pair.match(/^(\d)\s*[-, ]\s*(\d)$/);
            if (!m || m[1] === m[2]) return null;
            edges.push([Number(m[1]), Number(m[2])]);
        }
        if (edges.length === 0) return null;
        const n = Math.max(...edges.flat()) + 1;
        const pos = Array.from({ length: n }, (_, i) => {
            const a = (2 * Math.PI * i) / n - Math.PI / 2;
            return [200 + 115 * Math.cos(a), 140 + 115 * Math.sin(a)];
        });
        return { n, edges, pos };
    }

    function adjacency(n, edges) {
        const adj = Array.from({ length: n }, () => []);
        for (const [u, v] of edges) {
            if (!adj[u].includes(v)) adj[u].push(v);
            if (!adj[v].includes(u)) adj[v].push(u);
        }
        return adj.map((list) => list.sort((a, b) => a - b));
    }

    function bfs(adj, s) {
        const dist = adj.map(() => -1);
        const parent = adj.map(() => -1);
        const queue = [s];
        const steps = [];
        dist[s] = 0;
        while (queue.length) {
            const u = queue.shift();
            const added = [];
            for (const v of adj[u]) {
                if (dist[v] !== -1) continue;
                dist[v] = dist[u] + 1;
                parent[v] = u;
                queue.push(v);
                added.push(v);
            }
            steps.push({ u, added, frontier: [...queue], dist: [...dist], parent: [...parent] });
        }
        return steps;
    }

    function dfs(adj, s) {
        const parent = adj.map(() => -1);
        const seen = adj.map(() => false);
        const path = [];
        const steps = [];
        const rec = (u) => {
            seen[u] = true;
            path.push(u);
            steps.push({ u, frontier: [...path], parent: [...parent] });
            for (const v of adj[u]) {
                if (seen[v]) continue;
                parent[v] = u;
                rec(v);
            }
            path.pop();
        };
        rec(s);
        return steps;
    }

    function explain(s, k) {
        if (k === 0) {
            return s.mode === 'bfs'
                ? `เริ่มจากใส่ ${s.start} ลงใน queue โดย dist[${s.start}] = 0`
                : `เริ่มเรียก dfs(${s.start})`;
        }
        const step = s.steps[k - 1];
        if (s.mode === 'bfs') {
            const d = step.dist[step.u];
            const add = step.added.length
                ? `ใส่ ${step.added.join(', ')} ลง queue (dist = ${d + 1})`
                : 'ไม่มีเพื่อนบ้านใหม่';
            return `นำ ${step.u} ออกจาก queue (dist = ${d}) แล้ว${add}`;
        }
        const p = step.parent[step.u];
        if (p === -1) return `เยี่ยม ${step.u} เป็นโหนดแรก`;
        const prev = s.steps[k - 2].u;
        const back = prev === p ? '' : `ไม่มีทางไปต่อจาก ${prev} จึงถอยกลับ (backtrack) ไปที่ ${p} แล้ว`;
        return `${back}เดินจาก ${p} ไปเยี่ยม ${step.u} ซึ่งยังไม่เคยไป`;
    }

    function summary(s) {
        const order = s.steps.map((st) => st.u);
        const missing = [...Array(s.graph.n).keys()].filter((v) => !order.includes(v));
        let text = `ลำดับการเยี่ยม: ${order.join(' → ')}`;
        if (s.mode === 'bfs') {
            const dist = s.steps[s.steps.length - 1].dist;
            text += `. dist จาก ${s.start}: ${order.map((v) => `${v}:${dist[v]}`).join(', ')}`;
        }
        if (missing.length) text += `. เดินไปไม่ถึง ${missing.join(', ')} แสดงว่ากราฟนี้ไม่ connected`;
        return text;
    }

    function view(s) {
        const k = s.step;
        const last = s.steps[k - 1];
        const visited = new Set(s.steps.slice(0, k).map((st) => st.u));
        const frontier = k === 0 ? (s.mode === 'bfs' ? [s.start] : []) : last.frontier;
        const parent = k === 0 ? Array(s.graph.n).fill(-1) : last.parent;
        const dist = s.mode === 'bfs' && k > 0 ? last.dist : null;
        return { visited, frontier, parent, dist, current: last ? last.u : -1 };
    }

    function nodeSvg(s, v, x, y, vw) {
        const cls = ['gt-node'];
        if (vw.visited.has(v)) cls.push('is-done');
        if (vw.frontier.includes(v)) cls.push('is-frontier');
        if (v === vw.current) cls.push('is-current');
        const dist = vw.dist && vw.dist[v] >= 0 ? `<text class="gt-dist" x="${x + 19}" y="${y - 14}">${vw.dist[v]}</text>` : '';
        return `<g class="${cls.join(' ')}" data-node="${v}" tabindex="${s.guessMode ? 0 : -1}" role="button" aria-label="โหนด ${v}">`
            + `<circle cx="${x}" cy="${y}" r="16"/><text x="${x}" y="${y + 5}">${v}</text>${dist}</g>`;
    }

    function renderGraph(root, s, vw) {
        const { edges, pos } = s.graph;
        const lines = edges.map(([a, b]) => {
            const tree = vw.parent[a] === b || vw.parent[b] === a;
            const [x1, y1] = pos[a];
            const [x2, y2] = pos[b];
            return `<line class="gt-edge${tree ? ' is-tree' : ''}" x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}"/>`;
        });
        const nodes = pos.map(([x, y], v) => nodeSvg(s, v, x, y, vw));
        root.querySelector('.gt-graph').innerHTML =
            `<svg viewBox="0 0 400 285" width="400" height="285">${lines.join('')}${nodes.join('')}</svg>`;
    }

    function render(root, s) {
        const vw = view(s);
        const done = s.step >= s.steps.length;
        renderGraph(root, s, vw);
        root.querySelector('.gt-frontier-label').textContent = s.mode === 'bfs' ? 'queue (หน้า → หลัง)' : 'call stack (ล่าง → บน)';
        root.querySelector('.gt-frontier').textContent = vw.frontier.length ? vw.frontier.join(', ') : '(ว่าง)';
        root.querySelector('.widget-explain').textContent = s.message || explain(s, s.step);
        root.querySelector('.gt-guess-hint').hidden = !s.guessMode || done;
        root.querySelector('.widget-score').textContent = s.tries ? `ทายถูก ${s.correct}/${s.tries}` : '';
        root.querySelector('.gt-result').textContent = done ? summary(s) : '';
        root.querySelector('[data-act="back"]').disabled = s.step === 0;
        root.querySelector('[data-act="next"]').disabled = done || s.guessMode;
        root.querySelector('[data-act="all"]').disabled = done;
    }

    function template() {
        return `
            <div class="widget-controls">
                <label><select name="mode"><option value="bfs">BFS</option><option value="dfs">DFS</option></select></label>
                <label>กราฟ <select name="preset">
                    <option value="layers">กราฟตัวอย่าง</option>
                    <option value="components">มีสอง component</option>
                    <option value="custom">กำหนดเอง</option></select></label>
                <label>เริ่มที่ <input name="start" type="number" min="0" max="9" value="0"></label>
                <label><input name="guess-mode" type="checkbox"> ให้ฉันทายก่อน</label>
            </div>
            <div class="widget-controls gt-custom" hidden>
                <label>edges (โหนด 0-9) <input name="edges" value="0-1; 1-2; 2-3; 3-0; 2-4" size="28"></label>
            </div>
            <div class="gt-graph widget-table"></div>
            <p class="widget-summary"><span class="gt-frontier-label"></span>: <span class="gt-frontier"></span></p>
            <p class="widget-explain" aria-live="polite"></p>
            <p class="gt-guess-hint" hidden>คลิกโหนดที่คิดว่าจะถูกเยี่ยมเป็นลำดับถัดไป <span class="widget-score"></span></p>
            <div class="widget-controls">
                <button type="button" data-act="back">← ย้อนกลับ</button>
                <button type="button" data-act="next">ถัดไป →</button>
                <button type="button" data-act="all">ทำจนจบ</button>
                <button type="button" data-act="reset">เริ่มใหม่</button>
            </div>
            <p class="widget-summary gt-result" aria-live="polite"></p>`;
    }

    function readGraph(root) {
        const preset = root.querySelector('[name="preset"]').value;
        root.querySelector('.gt-custom').hidden = preset !== 'custom';
        return preset === 'custom' ? parseEdges(root.querySelector('[name="edges"]').value) : PRESETS[preset];
    }

    function guess(s, v) {
        const truth = s.steps[s.step].u;
        s.tries += 1;
        if (v === truth) s.correct += 1;
        s.step += 1;
        const verdict = v === truth ? '✓ ถูกต้อง' : `✗ ยังไม่ถูก โหนดถัดไปคือ ${truth}`;
        s.message = `${verdict} - ${explain(s, s.step)}`;
    }

    function mount(root) {
        root.innerHTML = template();
        let s = null;
        const reset = () => {
            const graph = readGraph(root);
            const input = root.querySelector('[name="start"]');
            if (!graph) {
                s = null;
                root.querySelector('.widget-explain').textContent = 'ใส่ edge เป็นคู่โหนด 0-9 เช่น 0-1; 1-2';
                return;
            }
            const start = Math.min(Math.max(Number(input.value) || 0, 0), graph.n - 1);
            input.value = start;
            const mode = root.querySelector('[name="mode"]').value;
            const adj = adjacency(graph.n, graph.edges);
            const steps = mode === 'bfs' ? bfs(adj, start) : dfs(adj, start);
            const guessMode = root.querySelector('[name="guess-mode"]').checked;
            s = { graph, mode, start, steps, guessMode, step: 0, tries: 0, correct: 0, message: '' };
            render(root, s);
        };
        const actions = {
            next: () => { s.step += 1; },
            back: () => { s.step -= 1; },
            all: () => { s.step = s.steps.length; },
        };
        const pickNode = (target) => {
            const node = target.closest?.('[data-node]');
            if (!node || !s || !s.guessMode || s.step >= s.steps.length) return false;
            const v = Number(node.dataset.node);
            guess(s, v);
            render(root, s);
            // The SVG is rebuilt on render; keep keyboard focus on the picked node.
            root.querySelector(`[data-node="${v}"]`)?.focus();
            return true;
        };
        root.addEventListener('click', (event) => {
            if (pickNode(event.target)) return;
            const act = event.target.dataset?.act;
            if (!act || !s) return;
            if (act === 'reset') return reset();
            s.message = '';
            actions[act]();
            render(root, s);
        });
        root.addEventListener('keydown', (event) => {
            if (event.key === 'Enter' || event.key === ' ') {
                if (pickNode(event.target)) event.preventDefault();
            }
        });
        root.querySelectorAll('select, input').forEach((el) => el.addEventListener('change', reset));
        reset();
    }

    return { parseEdges, adjacency, bfs, dfs, mount };
})();

if (typeof document !== 'undefined') {
    document.querySelectorAll('[data-widget="graph-traversal"]').forEach(GraphTraversal.mount);
}
