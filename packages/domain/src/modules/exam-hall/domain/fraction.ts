/**
 * Exact marks as fractions (ADR-0013 "Scoring is exact", §34 no floats). Integers only; always reduced, denominator > 0.
 * Mock totals stay small (hundreds of questions x small marks), so plain safe integers are enough.
 */
export interface Fraction {
  readonly num: number;
  readonly den: number;
}

function gcd(a: number, b: number): number {
  let x = Math.abs(a);
  let y = Math.abs(b);
  while (y) [x, y] = [y, x % y];
  return x || 1;
}

export function frac(num: number, den = 1): Fraction {
  if (!Number.isSafeInteger(num) || !Number.isSafeInteger(den) || den === 0) throw new RangeError("invalid fraction");
  const sign = den < 0 ? -1 : 1;
  const g = gcd(num, den);
  return { num: (sign * num) / g || 0, den: Math.abs(den) / g };
}

export const ZERO: Fraction = { num: 0, den: 1 };

export function add(a: Fraction, b: Fraction): Fraction {
  return frac(a.num * b.den + b.num * a.den, a.den * b.den);
}

export function sub(a: Fraction, b: Fraction): Fraction {
  return frac(a.num * b.den - b.num * a.den, a.den * b.den);
}

export function times(a: Fraction, n: number): Fraction {
  return frac(a.num * n, a.den);
}

/** -1, 0 or 1. */
export function compare(a: Fraction, b: Fraction): number {
  return Math.sign(a.num * b.den - b.num * a.den);
}

/** Display string rounded half away from zero to `decimals` places, computed with integers ("-1.33", "50.00"). */
export function toDisplay(f: Fraction, decimals: number): string {
  const scale = 10 ** decimals;
  const negative = f.num < 0;
  const abs = Math.abs(f.num) * scale;
  const rounded = Math.floor((2 * abs + f.den) / (2 * f.den));
  const whole = Math.floor(rounded / scale);
  const part = String(rounded % scale).padStart(decimals, "0");
  const text = decimals > 0 ? `${whole}.${part}` : String(whole);
  return negative && rounded !== 0 ? `-${text}` : text;
}
