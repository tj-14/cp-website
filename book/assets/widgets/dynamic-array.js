// Interactive dynamic array: push elements and count the copies each growth policy causes.
const DynamicArray = (() => {
    const POLICIES = {
        double: { label: 'ขยายเป็น 2 เท่า', grow: (cap) => cap * 2 },
        plusOne: { label: 'เพิ่มทีละ 1 ช่อง', grow: (cap) => cap + 1 },
    };

    // Simulates n pushes starting from capacity 1; returns per-push copy counts.
    function simulate(policy, n) {
        let cap = 1;
        let size = 0;
        const copies = [];
        for (let i = 0; i < n; i++) {
            let moved = 0;
            if (size === cap) {
                moved = size;
                cap = POLICIES[policy].grow(cap);
            }
            size += 1;
            copies.push(moved);
        }
        return { cap, size, copies };
    }

    function render(root, s) {
        const { cap, size, copies } = simulate(s.policy, s.n);
        const shown = Math.min(cap, 64);
        const cells = Array.from({ length: shown }, (_, i) => {
            const cls = i < size ? (i === size - 1 ? 'is-new' : 'is-full') : '';
            return `<span class="da-cell ${cls}">${i < size ? i + 1 : ''}</span>`;
        }).join('');
        const more = cap > shown ? `<span class="da-more">… อีก ${cap - shown} ช่อง</span>` : '';
        root.querySelector('.da-cells').innerHTML = cells + more;
        const total = copies.reduce((a, b) => a + b, 0);
        const last = copies[copies.length - 1] ?? 0;
        const avg = s.n ? (total / s.n).toFixed(2) : '0';
        root.querySelector('.widget-explain').textContent = s.n === 0
            ? 'array ว่าง capacity = 1'
            : last
                ? `push ครั้งที่ ${s.n}: array เต็ม จึงจองที่ใหม่ capacity ${cap} แล้วคัดลอก ${last} ตัวเดิมไป`
                : `push ครั้งที่ ${s.n}: ยังมีที่ว่าง ใส่ได้ทันที ไม่ต้องคัดลอก`;
        root.querySelector('.widget-summary').textContent =
            `size = ${size}, capacity = ${cap}, คัดลอกรวม ${total} ครั้ง, เฉลี่ย ${avg} ครั้งต่อการ push`;
    }

    function template() {
        const options = Object.entries(POLICIES)
            .map(([k, p]) => `<option value="${k}">${p.label}</option>`).join('');
        return `
            <div class="widget-controls">
                <label>เมื่อเต็ม <select name="policy">${options}</select></label>
                <button type="button" data-act="push">push 1 ตัว</button>
                <button type="button" data-act="push10">push 10 ตัว</button>
                <button type="button" data-act="push100">push 100 ตัว</button>
                <button type="button" data-act="reset">เริ่มใหม่</button>
            </div>
            <div class="da-cells" aria-hidden="true"></div>
            <p class="widget-explain" aria-live="polite"></p>
            <p class="widget-summary"></p>`;
    }

    function mount(root) {
        root.innerHTML = template();
        const s = { policy: 'double', n: 0 };
        const add = { push: 1, push10: 10, push100: 100 };
        root.addEventListener('click', (event) => {
            const act = event.target.dataset?.act;
            if (!act) return;
            s.n = act === 'reset' ? 0 : Math.min(s.n + add[act], 5000);
            render(root, s);
        });
        root.querySelector('[name="policy"]').addEventListener('change', (event) => {
            s.policy = event.target.value;
            render(root, s);
        });
        render(root, s);
    }

    return { simulate, mount };
})();

if (typeof document !== 'undefined') {
    document.querySelectorAll('[data-widget="dynamic-array"]').forEach(DynamicArray.mount);
}
