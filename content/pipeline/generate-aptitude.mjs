#!/usr/bin/env node
// Generates content/questions/aptitude.yaml: 80 original practice questions for the five aptitude topics.
// Every answer is computed from the numbers in the question, so none can be mistyped. Wording and numbers are ours.
// Output is sample content, under review: it is NOT verified against any official paper.
//   node content/pipeline/generate-aptitude.mjs
import { writeFileSync } from "node:fs";
import { createHash } from "node:crypto";

const T = {
  percentage: "0199f5a0-0601-7000-8000-000000000601",
  ratio: "0199f5a0-0602-7000-8000-000000000602",
  interest: "0199f5a0-0603-7000-8000-000000000603",
  series: "0199f5a0-0604-7000-8000-000000000604",
  work: "0199f5a0-0605-7000-8000-000000000605",
};
const num = (n) => (Number.isInteger(n) ? String(n) : String(Math.round(n * 100) / 100));
const gcd = (a, b) => (b ? gcd(b, a % b) : a);
const q = [];
const add = (topic, code, diff, stem, correct, wrong, why) => q.push({ topic, code, diff, stem, correct, wrong, why });

// ---------------------------------------------------------------- Percentage
for (const [p, n] of [[15, 240], [35, 80]])
  add("percentage", "of", 1, `What is ${p}% of ${n}?`, (p * n) / 100, [(p * n) / 10, (p * n) / 100 + 10, n - p], `${p}% of ${n} = ${p} / 100 x ${n} = ${num((p * n) / 100)}.`);
for (const [v, p] of [[800, 25], [1200, 15]])
  add("percentage", "increase", 2, `A price of Rs ${v} is raised by ${p}%. What is the new price in rupees?`, (v * (100 + p)) / 100, [(v * p) / 100, (v * (100 - p)) / 100, v + p], `Increase = ${p}% of ${v} = ${(v * p) / 100}. New price = ${v} + ${(v * p) / 100} = ${(v * (100 + p)) / 100}.`);
for (const [a, b] of [[40, 50], [250, 300]])
  add("percentage", "change", 2, `A value goes up from ${a} to ${b}. What is the percentage increase?`, ((b - a) * 100) / a, [((b - a) * 100) / b, b - a, ((b - a) * 100) / a + 5], `Percentage increase = (change / original) x 100 = (${b - a} / ${a}) x 100 = ${num(((b - a) * 100) / a)}%.`);
for (const [m, t] of [[360, 500], [27, 36]])
  add("percentage", "score", 1, `A student scores ${m} marks out of ${t}. What is the percentage?`, (m * 100) / t, [(m * 100) / t + 5, (m * 100) / t - 8, t - m], `Percentage = ${m} / ${t} x 100 = ${num((m * 100) / t)}%.`);
for (const [a, b] of [[20, 20], [10, 30]]) {
  const net = a - b - (a * b) / 100;
  const word = net < 0 ? "decrease" : "increase";
  add("percentage", "successive", 3, `A price is first increased by ${a}% and then decreased by ${b}%. What is the net change?`, `${num(Math.abs(net))}% ${word}`, [`${num(Math.abs(a - b) || 1)}% increase`, `${num(Math.abs(net) + 2)}% ${word}`, "No change"], `Start with 100. After +${a}% it is ${100 + a}. After -${b}% it is ${num(((100 + a) * (100 - b)) / 100)}. Net change is ${num(net)}%.`);
}
for (const [a, b] of [[25, 20], [150, 75]])
  add("percentage", "whatpercent", 2, `${a} is what percent of ${b}?`, (a * 100) / b, [(b * 100) / a, (a * 100) / b + 10, a - b], `Percent = (${a} / ${b}) x 100 = ${num((a * 100) / b)}%.`);
for (const [pass, fail, got] of [[40, 20, 130], [30, 15, 105]]) {
  const total = ((got + fail) * 100) / pass;
  add("percentage", "passmarks", 3, `To pass an exam a student needs ${pass}%. A student scores ${got} marks and fails by ${fail} marks. What is the total marks of the exam?`, total, [got + fail, total + 50, total - 50], `Pass mark = ${got} + ${fail} = ${got + fail}. This is ${pass}% of the total, so total = ${got + fail} x 100 / ${pass} = ${total}.`);
}
for (const [mp, d] of [[2000, 15], [900, 10]])
  add("percentage", "discount", 2, `A shirt is marked at Rs ${mp}. A discount of ${d}% is given. What is the selling price in rupees?`, (mp * (100 - d)) / 100, [(mp * d) / 100, (mp * (100 + d)) / 100, mp - d], `Discount = ${d}% of ${mp} = ${(mp * d) / 100}. Selling price = ${mp} - ${(mp * d) / 100} = ${(mp * (100 - d)) / 100}.`);

// ---------------------------------------------------------------- Ratio and proportion
for (const [n, a, b] of [[900, 2, 3], [1260, 4, 3]]) {
  const big = Math.max(a, b), small = Math.min(a, b);
  add("ratio", "share", 1, `Rs ${n} is divided between two people in the ratio ${a}:${b}. What is the larger share in rupees?`, (n * big) / (a + b), [(n * small) / (a + b), n / 2 + 50, (n * big) / (a + b) + 60], `Total parts = ${a} + ${b} = ${a + b}. One part = ${n} / ${a + b} = ${n / (a + b)}. Larger share = ${big} x ${n / (a + b)} = ${(n * big) / (a + b)}.`);
}
for (const [a, b, c] of [[3, 5, 12], [4, 7, 20]])
  add("ratio", "proportion", 2, `If ${a} : ${b} = ${c} : x, what is x?`, (b * c) / a, [(a * c) / b, b + c - a, (b * c) / a + 5], `In a proportion the product of the extremes equals the product of the means: ${a} x x = ${b} x ${c}, so x = ${b * c} / ${a} = ${num((b * c) / a)}.`);
for (const [a, b, s] of [[3, 5, 40], [5, 7, 60]])
  add("ratio", "ages", 2, `The ages of two brothers are in the ratio ${a}:${b} and their ages add up to ${s} years. What is the age of the elder brother in years?`, (s * b) / (a + b), [(s * a) / (a + b), s / 2 + 3, (s * b) / (a + b) + 2], `One part = ${s} / ${a + b} = ${s / (a + b)} years. Elder brother = ${b} x ${s / (a + b)} = ${(s * b) / (a + b)} years.`);
for (const [b, g, t] of [[4, 5, 180], [7, 5, 240]])
  add("ratio", "boysgirls", 1, `In a class the ratio of boys to girls is ${b}:${g}. There are ${t} students in all. How many girls are there?`, (t * g) / (b + g), [(t * b) / (b + g), (t * g) / (b + g) + 10, t - b - g], `One part = ${t} / ${b + g} = ${t / (b + g)}. Girls = ${g} x ${t / (b + g)} = ${(t * g) / (b + g)}.`);
for (const [x, y] of [[4, 9], [16, 25]])
  add("ratio", "meanprop", 3, `What is the mean proportional between ${x} and ${y}?`, Math.sqrt(x * y), [(x + y) / 2, (x * y) / 2, Math.sqrt(x * y) + 2], `The mean proportional of x and y is the square root of x times y. Square root of (${x} x ${y}) = square root of ${x * y} = ${Math.sqrt(x * y)}.`);
for (const [n, c, m] of [[6, 90, 15], [8, 200, 12]])
  add("ratio", "direct", 2, `${n} notebooks cost Rs ${c}. What is the cost of ${m} notebooks in rupees at the same rate?`, (c * m) / n, [c + m - n, c * (m - n), (c * m) / n + 25], `Cost is directly proportional to the number of notebooks. One notebook = ${c} / ${n} = ${c / n}. ${m} notebooks = ${m} x ${c / n} = ${(c * m) / n}.`);
for (const [m, cm] of [[2, 50], [3, 150]]) {
  const g = gcd(m * 100, cm);
  add("ratio", "units", 2, `What is the ratio of ${m} metres to ${cm} centimetres in its simplest form?`, `${(m * 100) / g}:${cm / g}`, [`${m}:${cm}`, `${cm / g}:${(m * 100) / g}`, `${(m * 100) / g + 1}:${cm / g}`], `Convert to the same unit: ${m} m = ${m * 100} cm. Ratio = ${m * 100}:${cm}, which is ${(m * 100) / g}:${cm / g} after dividing both by ${g}.`);
}
for (const [i, e, inc] of [[5, 4, 18000], [7, 5, 28000]])
  add("ratio", "savings", 3, `A person's income and expenditure are in the ratio ${i}:${e}. If the income is Rs ${inc}, what are the savings in rupees?`, inc - (inc * e) / i, [(inc * e) / i, inc / i + 500, inc - (inc * e) / i + 1000], `Income is ${i} parts = Rs ${inc}, so one part = ${inc / i}. Expenditure = ${e} x ${inc / i} = ${(inc * e) / i}. Savings = ${inc} - ${(inc * e) / i} = ${inc - (inc * e) / i}.`);

// ---------------------------------------------------------------- Simple and compound interest
for (const [p, r, t] of [[5000, 8, 3], [12000, 5, 2]])
  add("interest", "si", 1, `What is the simple interest on Rs ${p} at ${r}% per year for ${t} years, in rupees?`, (p * r * t) / 100, [(p * r) / 100, (p * r * t) / 10, (p * r * t) / 100 + p / 10], `Simple interest = P x R x T / 100 = ${p} x ${r} x ${t} / 100 = ${(p * r * t) / 100}.`);
for (const [si, r, t] of [[1800, 6, 3], [2400, 8, 5]])
  add("interest", "principal", 2, `Simple interest of Rs ${si} is earned in ${t} years at ${r}% per year. What is the principal in rupees?`, (si * 100) / (r * t), [(si * 100) / r, (si * r * t) / 100, (si * 100) / (r * t) + 1000], `P = SI x 100 / (R x T) = ${si} x 100 / (${r} x ${t}) = ${(si * 100) / (r * t)}.`);
for (const [p, si, t] of [[8000, 1600, 4], [5000, 1500, 3]])
  add("interest", "rate", 2, `Rs ${p} earns simple interest of Rs ${si} in ${t} years. What is the rate per year, in percent?`, (si * 100) / (p * t), [(si * 100) / p, (si * 100) / (p * t) + 2, si / t], `R = SI x 100 / (P x T) = ${si} x 100 / (${p} x ${t}) = ${num((si * 100) / (p * t))}%.`);
for (const [p, r, t] of [[4000, 10, 3], [6000, 5, 4]])
  add("interest", "amount", 2, `Rs ${p} is lent at ${r}% simple interest for ${t} years. What is the total amount to be repaid in rupees?`, p + (p * r * t) / 100, [(p * r * t) / 100, p + (p * r) / 100, p + (p * r * t) / 100 + 100], `Interest = ${p} x ${r} x ${t} / 100 = ${(p * r * t) / 100}. Amount = principal + interest = ${p} + ${(p * r * t) / 100} = ${p + (p * r * t) / 100}.`);
for (const [p, r] of [[4000, 10], [10000, 20]]) {
  const first = (p * (100 + r)) / 100;
  const second = Math.round((first * (100 + r)) / 100);
  const ci = second - p;
  add("interest", "ci2", 3, `What is the compound interest on Rs ${p} for 2 years at ${r}% per year, compounded yearly, in rupees?`, ci, [(p * r * 2) / 100, ci + 100, ci - 100], `After 1 year the amount is ${p} x ${(100 + r) / 100} = ${first}. After 2 years it is ${first} x ${(100 + r) / 100} = ${second}. Compound interest = ${second} - ${p} = ${ci}.`);
}
for (const [p, r] of [[5000, 10], [8000, 5]]) {
  const d = (p * r * r) / 10000;
  add("interest", "diff", 3, `What is the difference between compound interest and simple interest on Rs ${p} for 2 years at ${r}% per year, in rupees?`, d, [d * 2, d + 10, (p * r) / 100], `For 2 years the difference is P x (R / 100)^2 = ${p} x (${r} / 100)^2 = ${num(d)}.`);
}
for (const [si, p, r] of [[900, 3000, 5], [1440, 4000, 6]])
  add("interest", "time", 2, `Rs ${p} earns simple interest of Rs ${si} at ${r}% per year. For how many years was it invested?`, (si * 100) / (p * r), [(si * 100) / (p * r) + 1, si / p, ((si * 100) / (p * r)) * 2], `T = SI x 100 / (P x R) = ${si} x 100 / (${p} x ${r}) = ${num((si * 100) / (p * r))} years.`);
for (const r of [5, 10])
  add("interest", "double", 2, `At simple interest, in how many years does a sum of money double if the rate is ${r}% per year?`, 100 / r, [200 / r, 50 / r, 100 / r + 5], `Doubling means the interest equals the principal. P = P x ${r} x T / 100, so T = 100 / ${r} = ${100 / r} years.`);

// ---------------------------------------------------------------- Number series
for (const [a, d] of [[7, 5], [100, -6]]) {
  const s = [0, 1, 2, 3, 4].map((i) => a + i * d);
  add("series", "ap", 1, `Find the next number: ${s.join(", ")}, ?`, a + 5 * d, [a + 5 * d + 1, a + 6 * d, a + 5 * d - 2], `The difference between terms is always ${d}. Next term = ${s[4]} + (${d}) = ${a + 5 * d}.`);
}
for (const [a, r] of [[2, 3], [5, 2]]) {
  const s = [0, 1, 2, 3].map((i) => a * r ** i);
  add("series", "gp", 2, `Find the next number: ${s.join(", ")}, ?`, a * r ** 4, [s[3] + r, a * r ** 4 + a, s[3] * (r - 1)], `Each term is ${r} times the one before. Next term = ${s[3]} x ${r} = ${a * r ** 4}.`);
}
for (const st of [2, 4]) {
  const s = [0, 1, 2, 3, 4].map((i) => (st + i) ** 2);
  add("series", "squares", 2, `Find the next number: ${s.join(", ")}, ?`, (st + 5) ** 2, [(st + 5) ** 2 + 1, (st + 5) ** 2 - 2, s[4] + (st + 5)], `These are squares of consecutive numbers: ${[0, 1, 2, 3, 4].map((i) => `${st + i}^2`).join(", ")}. Next is ${st + 5}^2 = ${(st + 5) ** 2}.`);
}
for (const [a, d, e] of [[3, 2, 2], [1, 1, 2]]) {
  const s = [a];
  let step = d;
  for (let i = 0; i < 4; i++) { s.push(s[s.length - 1] + step); step += e; }
  add("series", "second", 3, `Find the next number: ${s.join(", ")}, ?`, s[4] + step, [s[4] + step - e, s[4] + step + e, s[4] + d], `The differences are ${s.slice(1).map((v, i) => v - s[i]).join(", ")}, going up by ${e} each time. The next difference is ${step}, so the next term is ${s[4]} + ${step} = ${s[4] + step}.`);
}
for (const [a, b, c] of [[2, 100, 3], [5, 50, 4]]) {
  const s = [a, b, a + c, b - c, a + 2 * c, b - 2 * c];
  add("series", "alt", 3, `Find the next number: ${s.join(", ")}, ?`, a + 3 * c, [b - 3 * c, a + 2 * c, a + 3 * c + 1], `Two series are mixed together. The terms in odd places go ${a}, ${a + c}, ${a + 2 * c}, adding ${c} each time. The terms in even places go ${b}, ${b - c}, ${b - 2 * c}. The next term is in an odd place: ${a + 3 * c}.`);
}
for (const st of [1, 3]) {
  const s = [0, 1, 2, 3].map((i) => (st + i) ** 3);
  add("series", "cubes", 3, `Find the next number: ${s.join(", ")}, ?`, (st + 4) ** 3, [(st + 4) ** 2, (st + 4) ** 3 - st, s[3] + 3 * (st + 4)], `These are cubes of consecutive numbers: ${[0, 1, 2, 3].map((i) => `${st + i}^3`).join(", ")}. Next is ${st + 4}^3 = ${(st + 4) ** 3}.`);
}
for (const [a, d] of [[4, 6], [11, 7]]) {
  const s = [0, 1, 2, 3, 4].map((i) => a + i * d);
  add("series", "missing", 2, `Find the missing number: ${s[0]}, ${s[1]}, ?, ${s[3]}, ${s[4]}`, s[2], [s[2] + d, s[2] - 1, s[2] + 2], `The series goes up by ${d} each time, so the missing number is ${s[1]} + ${d} = ${s[2]}.`);
}
for (const [a, b] of [[1, 2], [2, 3]]) {
  const s = [a, b];
  for (let i = 0; i < 4; i++) s.push(s[s.length - 1] + s[s.length - 2]);
  add("series", "fib", 3, `Find the next number: ${s.join(", ")}, ?`, s[5] + s[4], [s[5] * 2, s[5] + s[3], s[5] + s[4] + 1], `Each term is the sum of the two before it. Next term = ${s[4]} + ${s[5]} = ${s[4] + s[5]}.`);
}

// ---------------------------------------------------------------- Time and work
for (const [x, y] of [[12, 12], [10, 15]])
  add("work", "together", 2, `A can finish a job in ${x} days and B can finish it in ${y} days. Working together, in how many days will they finish it?`, (x * y) / (x + y), [(x + y) / 2, x + y, (x * y) / (x + y) + 2], `In one day A does 1/${x} and B does 1/${y} of the job. Together that is ${x + y}/${x * y} per day, so they need ${x * y}/${x + y} = ${num((x * y) / (x + y))} days.`);
for (const [x, d] of [[20, 5], [15, 6]]) {
  const g = gcd(d, x);
  add("work", "fraction", 1, `A can complete a job in ${x} days. What fraction of the job does A finish in ${d} days?`, `${d / g}/${x / g}`, [`${x / g}/${d / g}`, `1/${d}`, `${d + 1}/${x}`], `In 1 day A does 1/${x} of the job. In ${d} days A does ${d}/${x}, which simplifies to ${d / g}/${x / g}.`);
}
for (const [m, d, m2] of [[6, 20, 8], [10, 12, 15]])
  add("work", "mandays", 2, `${m} workers can build a wall in ${d} days. How many days will ${m2} workers take to build the same wall?`, (m * d) / m2, [d - (m2 - m), (m * d) / m2 + 4, (d * m2) / m], `Total work = ${m} x ${d} = ${m * d} worker-days. ${m2} workers need ${m * d} / ${m2} = ${num((m * d) / m2)} days.`);
for (const [x, y] of [[12, 20], [10, 15]])
  add("work", "pipes", 3, `A pipe fills a tank in ${x} hours. A leak at the bottom can empty the full tank in ${y} hours. If both work together, in how many hours will the empty tank fill?`, (x * y) / (y - x), [x + y, y - x, (x * y) / (y - x) - 3], `Filling per hour = 1/${x}. Leaking per hour = 1/${y}. Net per hour = 1/${x} - 1/${y} = ${y - x}/${x * y}. Time = ${x * y}/${y - x} = ${num((x * y) / (y - x))} hours.`);
for (const [d, x] of [[6, 10], [8, 24]]) {
  const y = (d * x) / (x - d);
  add("work", "other", 3, `A and B together finish a job in ${d} days. A alone can do it in ${x} days. In how many days can B alone do it?`, y, [x - d, y + 6, d + x], `B's share per day = 1/${d} - 1/${x} = ${x - d}/${d * x}. So B alone needs ${d * x}/${x - d} = ${num(y)} days.`);
}
for (const [x, y, d] of [[20, 30, 5], [12, 24, 4]]) {
  const left = 1 - d / x;
  const t = left * y;
  add("work", "leaves", 3, `A can do a job in ${x} days and B in ${y} days. A works alone for ${d} days and then leaves. In how many more days will B finish the rest?`, t, [y - d, t + 5, x - d], `A does ${d}/${x} of the job in ${d} days, so ${num(left)} of it is left. B does 1/${y} per day, so B needs ${num(left)} x ${y} = ${num(t)} days.`);
}
for (const [k, d] of [[2, 12], [3, 8]]) {
  const a = (d * (k + 1)) / k;
  add("work", "efficiency", 3, `A works ${k} times as fast as B. Together they finish a job in ${d} days. How many days will A alone take?`, a, [d * (k + 1), d * k, a + 2], `Say B does 1 part a day, so A does ${k} parts. Together that is ${k + 1} parts a day, so the job is ${(k + 1) * d} parts. A alone needs ${(k + 1) * d} / ${k} = ${num(a)} days.`);
}
for (const [x, y, w] of [[3, 2, 1000], [5, 3, 1600]])
  add("work", "wages", 2, `A works for ${x} days and B works for ${y} days on the same job at the same daily rate. They share Rs ${w} fairly. How much does A get in rupees?`, (w * x) / (x + y), [(w * y) / (x + y), w / 2, (w * x) / (x + y) + 100], `Wages are shared in the ratio of days worked, ${x}:${y}. A's share = ${x}/${x + y} x ${w} = ${(w * x) / (x + y)}.`);

// ---------------------------------------------------------------- Build YAML
const seen = new Set();
const uid = (label) => {
  const h = createHash("sha1").update(`heymey-q:${label}`).digest("hex");
  return `${h.slice(0, 8)}-${h.slice(8, 12)}-5${h.slice(13, 16)}-8${h.slice(17, 20)}-${h.slice(20, 32)}`;
};
let out = `# Aptitude and Mental Ability: SAMPLE practice questions, under review.
# GENERATED by content/pipeline/generate-aptitude.mjs. Do not edit by hand: change the generator and re-run it.
# Original questions written for HeyMey from standard school arithmetic. Not copied from any paper, book, app or website.
# review_status is "sample" until a human reviewer checks each item; the app labels these "sample content, under review".
set: aptitude-sample-1
review_status: sample
source:
  kind: original
  citation: "HeyMey original practice question (sample content, under review). Standard school arithmetic."
  url: null
questions:
`;
const counters = {};
const quote = (s) => JSON.stringify(s);
q.forEach((it, idx) => {
  const opts = [it.correct, ...it.wrong].map((v) => (typeof v === "number" ? num(v) : String(v)));
  if (new Set(opts).size !== 4) throw new Error(`duplicate options in: ${it.stem} -> ${opts.join(" | ")}`);
  const order = [0, 1, 2, 3].sort((a, b) => ((a * 7 + idx * 5) % 11) - ((b * 7 + idx * 5) % 11) || a - b);
  const shuffled = order.map((i) => opts[i]);
  const correctIdx = shuffled.indexOf(opts[0]);
  counters[it.topic] = (counters[it.topic] ?? 0) + 1;
  const id = uid(`${it.topic}:${it.code}:${it.stem}`);
  if (seen.has(id)) throw new Error(`duplicate id: ${it.stem}`);
  seen.add(id);
  out += `  - id: ${id}
    topic_id: ${T[it.topic]}
    difficulty: ${it.diff}
    stem: ${quote(it.stem)}
    options:
${shuffled.map((o, i) => `      - { id: ${"abcd"[i]}, text: ${quote(o)} }`).join("\n")}
    correct: ${"abcd"[correctIdx]}
    explanation: ${quote(it.why)}
`;
});
writeFileSync(new URL("../questions/aptitude.yaml", import.meta.url), out);
console.log(`wrote ${q.length} questions`, counters);
