// Interactive interval scheduling: compare greedy rules on a timeline, one interval per step.
const IntervalScheduling = (() => {
    const PRESETS = {
        lesson: { label: 'ตัวอย่างในบท', jobs: [['A', 1, 3], ['B', 2, 5], ['C', 3, 9], ['D', 6, 8]] },
        longFirst: { label: 'งานยาวเริ่มก่อน', jobs: [['A', 0, 10], ['B', 1, 3], ['C', 3, 5], ['D', 5, 7], ['E', 7, 9]] },
        shortMiddle: { label: 'งานสั้นคร่อมกลาง', jobs: [['A', 0, 5], ['B', 6, 11], ['C', 4, 7]] },
    };

    const RULES = {
        end: { label: 'จบเร็วสุดก่อน', key: (j) => [j.end, j.start] },
        start: { label: 'เริ่มเร็วสุดก่อน', key: (j) => [j.start, j.end] },
        short: { label: 'สั้นสุดก่อน', key: (j) => [j.end - j.start, j.start] },
    };

    const toJobs = (rows) => rows.map(([name, start, end]) => ({ name, start, end }));
    const overlaps = (a, b) => a.start < b.end && b.start < a.end;  // half-open [start, end)

    function run(jobs, rule) {
        const order = [...jobs].sort((a, b) => {
            const [x1, x2] = RULES[rule].key(a);
            const [y1, y2] = RULES[rule].key(b);
            return x1 - y1 || x2 - y2;
        });
        const chosen = [];
        const steps = order.map((job) => {
            const clash = chosen.find((c) => overlaps(c, job));
            if (!clash) chosen.push(job);
            return { job, ok: !clash, clash, chosen: [...chosen] };
        });
        return { order, steps, chosen };
    }

    const optimum = (jobs) => run(jobs, 'end').chosen.length;

    function renderTimeline(s, step) {
        const jobs = s.jobs;
        const maxT = Math.max(...jobs.map((j) => j.end)) + 1;
        const W = 400;
        const rowH = 30;
        const x = (t) => 40 + (t / maxT) * (W - 50);
        const done = new Map(s.result.steps.slice(0, s.step).map((st) => [st.job.name, st.ok]));
        const bars = jobs.map((j, i) => {
            const y = 10 + i * rowH;
            const state = done.has(j.name) ? (done.get(j.name) ? 'is-chosen' : 'is-rejected') : '';
            const cur = step && step.job.name === j.name ? ' is-current' : '';
            return `<g class="iv-job ${state}${cur}"><text class="iv-label" x="12" y="${y + 17}">${j.name}</text>
                <rect x="${x(j.start)}" y="${y}" width="${x(j.end) - x(j.start)}" height="${rowH - 8}" rx="4"/>
                <text class="iv-time" x="${(x(j.start) + x(j.end)) / 2}" y="${y + 16}">${j.start}-${j.end}</text></g>`;
        });
        const H = 20 + jobs.length * rowH;
        const ticks = Array.from({ length: maxT + 1 }, (_, t) => `<text class="iv-tick" x="${x(t)}" y="${H + 2}">${t}</text>`);
        return `<svg viewBox="0 0 ${W} ${H + 8}" width="${W}" height="${H + 8}" aria-hidden="true">${bars.join('')}${ticks.join('')}</svg>`;
    }

    function explain(s, step) {
        if (!step) return `เรียงงานตามกฎ "${RULES[s.rule].label}": ${s.result.order.map((j) => j.name).join(', ')} แล้วพิจารณาทีละงาน`;
        const { job, ok, clash } = step;
        return ok ? `${job.name} (${job.start}-${job.end}) ไม่ชนกับงานที่เลือกไว้ จึงเลือก` : `${job.name} ชนกับ ${clash.name} ที่เลือกไปแล้ว จึงข้าม`;
    }

    function render(root, s) {
        const step = s.result.steps[s.step - 1];
        root.querySelector('.iv-timeline').innerHTML = renderTimeline(s, step);
        root.querySelector('.widget-explain').textContent = explain(s, step);
        const done = s.step >= s.result.steps.length;
        const best = optimum(s.jobs);
        const got = s.result.chosen.length;
        root.querySelector('.widget-summary').textContent = done
            ? `กฎนี้เลือกได้ ${got} งาน (${s.result.chosen.map((j) => j.name).join(', ')}) คำตอบที่ดีที่สุดคือ ${best} งาน${got < best ? ' - กฎนี้ไม่ optimal!' : ''}`
            : '';
        root.querySelector('[data-act="back"]').disabled = s.step === 0;
        root.querySelector('[data-act="next"]').disabled = done;
        root.querySelector('[data-act="all"]').disabled = done;
    }

    function template() {
        const opt = (o) => Object.entries(o).map(([k, v]) => `<option value="${k}">${v.label}</option>`).join('');
        return `
            <div class="widget-controls">
                <label>กฎ greedy <select name="rule">${opt(RULES)}</select></label>
                <label>ชุดงาน <select name="preset">${opt(PRESETS)}</select></label>
            </div>
            <div class="iv-timeline widget-table"></div>
            <p class="widget-explain" aria-live="polite"></p>
            <div class="widget-controls">
                <button type="button" data-act="back">← ย้อนกลับ</button>
                <button type="button" data-act="next">ถัดไป →</button>
                <button type="button" data-act="all">ทำจนจบ</button>
            </div>
            <p class="widget-summary" aria-live="polite"></p>`;
    }

    function mount(root) {
        root.innerHTML = template();
        const s = {};
        const reset = () => {
            s.rule = root.querySelector('[name="rule"]').value;
            s.jobs = toJobs(PRESETS[root.querySelector('[name="preset"]').value].jobs);
            s.result = run(s.jobs, s.rule);
            s.step = 0;
            render(root, s);
        };
        root.addEventListener('click', (event) => {
            const act = event.target.dataset?.act;
            if (!act) return;
            if (act === 'next') s.step += 1;
            if (act === 'back') s.step -= 1;
            if (act === 'all') s.step = s.result.steps.length;
            render(root, s);
        });
        root.querySelectorAll('select').forEach((el) => el.addEventListener('change', reset));
        reset();
    }

    return { PRESETS, toJobs, run, optimum, mount };
})();

if (typeof document !== 'undefined') {
    document.querySelectorAll('[data-widget="interval-scheduling"]').forEach(IntervalScheduling.mount);
}
