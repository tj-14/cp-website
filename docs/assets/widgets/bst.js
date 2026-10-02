// Interactive binary search tree: insert, search, delete, and traversals step by step.
const Bst = (() => {
    const PRESETS = {
        balanced: [50, 30, 70, 20, 40, 60, 80],
        sorted: [10, 20, 30, 40, 50, 60],
    };
    const MAX_NODES = 15;

    const clone = (t) => (t ? JSON.parse(JSON.stringify(t)) : null);
    const frame = (tree, hl, note) => ({ tree: clone(tree), hl, note });

    function count(t) {
        return t ? 1 + count(t.left) + count(t.right) : 0;
    }

    function height(t) {
        return t ? 1 + Math.max(height(t.left), height(t.right)) : 0;
    }

    function insert(tree, x) {
        const frames = [];
        if (!tree) return { tree: { key: x, left: null, right: null }, frames: [frame({ key: x, left: null, right: null }, [x], `tree ว่าง: ${x} เป็น root`)] };
        let cur = tree;
        const path = [];
        for (;;) {
            path.push(cur.key);
            if (x === cur.key) {
                frames.push(frame(tree, [...path], `${x} มีอยู่แล้ว ไม่ใส่ซ้ำ`));
                return { tree, frames };
            }
            const side = x < cur.key ? 'left' : 'right';
            const dir = side === 'left' ? `${x} < ${cur.key} ไปทางซ้าย` : `${x} > ${cur.key} ไปทางขวา`;
            if (!cur[side]) {
                frames.push(frame(tree, [...path], dir));
                cur[side] = { key: x, left: null, right: null };
                frames.push(frame(tree, [...path, x], `ช่องนั้นว่าง จึงใส่ ${x} เป็นลูก${side === 'left' ? 'ซ้าย' : 'ขวา'}ของ ${cur.key}`));
                return { tree, frames };
            }
            frames.push(frame(tree, [...path], dir));
            cur = cur[side];
        }
    }

    function search(tree, x) {
        const frames = [];
        const path = [];
        for (let cur = tree; cur; cur = x < cur.key ? cur.left : cur.right) {
            path.push(cur.key);
            if (x === cur.key) {
                frames.push(frame(tree, [...path], `เจอ ${x} หลังเทียบ ${path.length} ครั้ง`));
                return frames;
            }
            frames.push(frame(tree, [...path], x < cur.key ? `${x} < ${cur.key} ไปทางซ้าย` : `${x} > ${cur.key} ไปทางขวา`));
        }
        frames.push(frame(tree, path, `ถึงช่องว่างแล้ว ไม่มี ${x} ใน tree`));
        return frames;
    }

    // Returns the subtree with x removed, recording frames against the whole tree.
    function removeFrom(node, x, ctx) {
        if (!node) return null;
        ctx.path.push(node.key);
        if (x !== node.key) {
            const side = x < node.key ? 'left' : 'right';
            ctx.frames.push(frame(ctx.tree, [...ctx.path], `${x} ${side === 'left' ? '<' : '>'} ${node.key} ไปทาง${side === 'left' ? 'ซ้าย' : 'ขวา'}`));
            node[side] = removeFrom(node[side], x, ctx);
            return node;
        }
        ctx.found = true;
        if (!node.left || !node.right) {
            const child = node.left || node.right;
            ctx.frames.push(frame(ctx.tree, [...ctx.path], child
                ? `${x} มีลูกเดียว จึงให้ลูก (${child.key}) ขึ้นมาแทนที่`
                : `${x} เป็นใบ (leaf) ลบออกได้เลย`));
            return child;
        }
        let succ = node.right;
        const succPath = [...ctx.path, succ.key];
        while (succ.left) {
            succ = succ.left;
            succPath.push(succ.key);
        }
        ctx.frames.push(frame(ctx.tree, succPath, `${x} มีสองลูก: หา successor = ค่าน้อยสุดใน subtree ขวา คือ ${succ.key}`));
        node.key = succ.key;
        ctx.path = [];
        node.right = removeFrom(node.right, succ.key, { ...ctx, frames: [] });
        ctx.frames.push(frame(ctx.tree, [succ.key], `แทนค่า ${x} ด้วย ${succ.key} แล้วลบ ${succ.key} ตัวเดิมออกจาก subtree ขวา`));
        return node;
    }

    function remove(tree, x) {
        const ctx = { tree, path: [], frames: [], found: false };
        ctx.tree = removeFrom(tree, x, ctx) ?? null;
        // A root replaced by its child changes the tree object, so redraw the final state.
        if (!ctx.found) ctx.frames.push(frame(ctx.tree, ctx.path, `ไม่มี ${x} ใน tree`));
        else ctx.frames.push(frame(ctx.tree, [], `ลบ ${x} เสร็จแล้ว`));
        return { tree: ctx.tree, frames: ctx.frames };
    }

    const ORDERS = {
        pre: { label: 'preorder', walk: (t, out) => { if (t) { out.push(t.key); ORDERS.pre.walk(t.left, out); ORDERS.pre.walk(t.right, out); } } },
        in: { label: 'inorder', walk: (t, out) => { if (t) { ORDERS.in.walk(t.left, out); out.push(t.key); ORDERS.in.walk(t.right, out); } } },
        post: { label: 'postorder', walk: (t, out) => { if (t) { ORDERS.post.walk(t.left, out); ORDERS.post.walk(t.right, out); out.push(t.key); } } },
    };

    function traversal(tree, kind) {
        const out = [];
        if (kind === 'level') {
            const queue = tree ? [tree] : [];
            while (queue.length) {
                const t = queue.shift();
                out.push(t.key);
                if (t.left) queue.push(t.left);
                if (t.right) queue.push(t.right);
            }
        } else {
            ORDERS[kind].walk(tree, out);
        }
        return out;
    }

    function traversalFrames(tree, kind) {
        const order = traversal(tree, kind);
        const label = kind === 'level' ? 'level order (BFS)' : ORDERS[kind].label;
        return order.map((k, i) => frame(tree, order.slice(0, i + 1), `${label}: ${order.slice(0, i + 1).join(' ')}`));
    }

    function renderTree(tree, hl) {
        const nodes = [];
        const place = (t, depth) => {
            if (!t) return;
            place(t.left, depth + 1);
            nodes.push({ t, depth, x: nodes.length });
            place(t.right, depth + 1);
        };
        place(tree, 0);
        const W = Math.max(400, nodes.length * 46);
        const H = Math.max(1, height(tree)) * 56 + 8;
        const at = new Map(nodes.map((n) => [n.t, [(n.x + 0.5) * (W / Math.max(nodes.length, 1)), 26 + n.depth * 56]]));
        const last = hl[hl.length - 1];
        const edges = nodes.flatMap(({ t }) => ['left', 'right'].filter((s) => t[s]).map((s) => {
            const [x1, y1] = at.get(t);
            const [x2, y2] = at.get(t[s]);
            return `<line class="bst-edge" x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}"/>`;
        }));
        const circles = nodes.map(({ t }) => {
            const [x, y] = at.get(t);
            const cls = ['bst-node', hl.includes(t.key) ? 'is-path' : '', t.key === last ? 'is-hl' : ''].filter(Boolean).join(' ');
            return `<g class="${cls}"><circle cx="${x}" cy="${y}" r="17"/><text x="${x}" y="${y + 5}">${t.key}</text></g>`;
        });
        return `<svg viewBox="0 0 ${W} ${H}" width="${W}" height="${H}" aria-hidden="true">${edges.join('')}${circles.join('')}</svg>`;
    }

    function render(root, s) {
        const f = s.frames[s.step] || frame(s.tree, [], s.note);
        root.querySelector('.bst-tree').innerHTML = f.tree ? renderTree(f.tree, f.hl) : '<p><em>tree ว่าง</em></p>';
        root.querySelector('.widget-explain').textContent = f.note;
        // height() counts levels; the lesson defines height in edges (single node = 0).
        root.querySelector('.widget-summary').textContent = `จำนวน node = ${count(s.tree)}, ความสูง = ${s.tree ? height(s.tree) - 1 : '-'}`;
        const busy = s.step < s.frames.length - 1;
        root.querySelectorAll('.bst-ops button, .bst-ops select').forEach((b) => { b.disabled = busy; });
        root.querySelector('[data-act="next"]').disabled = !busy;
        root.querySelector('[data-act="finish"]').disabled = !busy;
    }

    function template() {
        return `
            <div class="widget-controls bst-ops">
                <label>ค่า <input name="value" type="number" value="45"></label>
                <button type="button" data-act="insert">insert</button>
                <button type="button" data-act="search">search</button>
                <button type="button" data-act="remove">delete</button>
            </div>
            <div class="widget-controls bst-ops">
                <label>traversal <select name="order">
                    <option value="in">inorder</option><option value="pre">preorder</option>
                    <option value="post">postorder</option><option value="level">level order</option></select></label>
                <button type="button" data-act="walk">เริ่ม traversal</button>
                <label>ตัวอย่าง <select name="preset">
                    <option value="balanced">สมดุล</option><option value="sorted">ใส่ค่าที่เรียงแล้ว</option></select></label>
            </div>
            <div class="bst-tree widget-table"></div>
            <p class="widget-explain" aria-live="polite"></p>
            <div class="widget-controls">
                <button type="button" data-act="next">ขั้นถัดไป →</button>
                <button type="button" data-act="finish">ทำจนจบ</button>
            </div>
            <p class="widget-summary"></p>`;
    }

    function build(keys) {
        let tree = null;
        for (const k of keys) tree = insert(tree, k).tree;
        return tree;
    }

    function mount(root) {
        root.innerHTML = template();
        const s = { tree: build(PRESETS.balanced), frames: [], step: 0, note: 'ทุก node: ค่าใน subtree ซ้ายน้อยกว่า และค่าใน subtree ขวามากกว่า' };
        const value = () => Number(root.querySelector('[name="value"]').value) || 0;
        const play = (frames) => {
            s.frames = frames;
            s.step = 0;
        };
        const actions = {
            insert: () => {
                if (count(s.tree) >= MAX_NODES) {
                    play([frame(s.tree, [], `ตัวอย่างนี้จำกัด ${MAX_NODES} node`)]);
                    return;
                }
                const r = insert(clone(s.tree), value());
                s.tree = r.tree;
                play(r.frames);
            },
            search: () => play(search(s.tree, value())),
            remove: () => {
                const r = remove(clone(s.tree), value());
                s.tree = r.tree;
                play(r.frames);
            },
            walk: () => play(traversalFrames(s.tree, root.querySelector('[name="order"]').value)),
            next: () => { s.step += 1; },
            finish: () => { s.step = s.frames.length - 1; },
        };
        root.addEventListener('click', (event) => {
            const act = event.target.dataset?.act;
            if (!act) return;
            actions[act]();
            render(root, s);
        });
        root.querySelector('[name="preset"]').addEventListener('change', (event) => {
            s.tree = build(PRESETS[event.target.value]);
            s.frames = [];
            s.note = event.target.value === 'sorted'
                ? 'ใส่ค่าที่เรียงแล้วทำให้ tree เอียงเป็นเส้นตรง ความสูง = n - 1 การค้นหาจึงช้าเป็น O(n)'
                : 'tree สมดุล ความสูงประมาณ log n';
            render(root, s);
        });
        render(root, s);
    }

    return { insert, search, remove, traversal, height, mount };
})();

if (typeof document !== 'undefined') {
    document.querySelectorAll('[data-widget="bst"]').forEach(Bst.mount);
}
