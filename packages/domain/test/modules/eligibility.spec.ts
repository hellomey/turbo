// Eligibility engine invariants: aidlc/construction/units/U-exams/domain-model.md (1-9).
import { describe, expect, it } from "vitest";
import { OFFICIAL_CONFIRM_LINE } from "@heymey/contracts";
import { FakeClock } from "@heymey/testing";
import {
  completedYears,
  createExamsModule,
  evaluateEligibility,
  formatDate,
  type Answers,
  type EligibilityRuleRecord,
  type ExamRecord,
  type ExamsRepository,
  type ExamWithRule,
} from "../../src/modules/exams/index.js";

const TODAY = "2026-10-20";

function exam(over: Partial<ExamRecord> = {}): ExamRecord {
  return {
    code: "tnpsc-group-4",
    name: "TNPSC Group 4",
    conductingBody: "TNPSC",
    level: "state",
    minQualification: "sslc",
    fullPrep: true,
    description: "d",
    stages: [],
    patternMode: "omr",
    patternQuestions: 200,
    patternMinutes: 180,
    negativeMarking: false,
    officialUrl: "https://www.tnpsc.gov.in/",
    notificationUrl: null,
    status: "published",
    lastCheckedAt: null,
    ...over,
  };
}

function rule(over: Partial<EligibilityRuleRecord> = {}): EligibilityRuleRecord {
  return {
    version: 1,
    status: "published",
    ageAsOf: "2026-07-01",
    minAge: 18,
    maxAgeByCommunity: { OC: 32, BC: 34, BCM: 34, MBC_DNC: 34, SC: 37, SCA: 37, ST: 37 },
    relaxationYears: { PWD: 10, EX_SERVICEMAN: 5, DESTITUTE_WIDOW: 7 },
    qualifications: ["sslc"],
    degreeSubjects: [],
    pstmNote: null,
    ...over,
  };
}

function answers(over: Partial<Answers> = {}): Answers {
  return {
    dateOfBirth: "2000-01-15",
    qualification: "degree",
    community: "OC",
    pstm: false,
    specialCategories: [],
    ...over,
  };
}

const one = (a: Answers, r: EligibilityRuleRecord = rule(), e: ExamRecord = exam()) => {
  const res = evaluateEligibility(a, TODAY, [{ exam: e, rule: r }]);
  const item = res.eligible[0] ?? res.notEligible[0];
  if (!item) throw new Error("exam left out");
  return item;
};
const codes = (item: { reasons: { code: string }[] }) => item.reasons.map((r) => r.code);

describe("date helpers", () => {
  it("completed years: birthday on the date counts, the day before does not", () => {
    expect(completedYears("2008-07-01", "2026-07-01")).toBe(18);
    expect(completedYears("2008-07-02", "2026-07-01")).toBe(17);
    expect(completedYears("2008-06-30", "2026-07-01")).toBe(18);
  });
  it("29 February birthdays complete a year on 1 March in non-leap years", () => {
    expect(completedYears("2004-02-29", "2026-02-28")).toBe(21);
    expect(completedYears("2004-02-29", "2026-03-01")).toBe(22);
  });
  it("formats dates in simple English", () => {
    expect(formatDate("2026-07-01")).toBe("1 July 2026");
    expect(formatDate("2027-01-01")).toBe("1 January 2027");
  });
});

describe("under 18 (invariant 1)", () => {
  it("refuses under 18 on today's date before looking at exams", () => {
    expect(() => evaluateEligibility(answers({ dateOfBirth: "2008-10-21" }), TODAY, [])).toThrowError(
      expect.objectContaining({ code: "UNDER_18" }),
    );
  });
  it("accepts someone whose 18th birthday is today", () => {
    expect(() => evaluateEligibility(answers({ dateOfBirth: "2008-10-20" }), TODAY, [])).not.toThrow();
  });
  it("refuses a date of birth in the future", () => {
    expect(() => evaluateEligibility(answers({ dateOfBirth: "2030-01-01" }), TODAY, [])).toThrowError(
      expect.objectContaining({ code: "UNDER_18" }),
    );
  });

  describe("uses the Asia/Kolkata date, not UTC (FakeClock)", () => {
    const repo: ExamsRepository = {
      listPublished: async () => [],
      findByCode: async () => null,
      listPublishedWithRules: async () => [{ exam: exam(), rule: rule() }],
      getChoices: async () => [],
      replaceChoices: async () => {},
    };
    // 18th birthday on 21 October 2026 (IST). 18:30 UTC on 20 October = 00:00 IST on 21 October.
    const dob = answers({ dateOfBirth: "2008-10-21" });

    it("18:29Z on the 20th is still the 20th in IST: UNDER_18", async () => {
      const clock = new FakeClock("2026-10-20T18:29:00.000Z");
      await expect(createExamsModule({ repository: repo, clock }).checkEligibility(dob)).rejects.toMatchObject({ code: "UNDER_18" });
    });

    it("18:31Z on the 20th is the 21st in IST: allowed", async () => {
      const clock = new FakeClock("2026-10-20T18:31:00.000Z");
      const res = await createExamsModule({ repository: repo, clock }).checkEligibility(dob);
      expect(res.eligible.length + res.notEligible.length).toBe(1);
    });
  });
});

describe("age on the rule's age-as-on date (invariants 2, 3)", () => {
  it("exactly the minimum age on ageAsOf (birthday that day) is eligible", () => {
    const item = one(answers({ dateOfBirth: "2008-07-01" }), rule({ ageAsOf: "2026-07-01", minAge: 18 }));
    expect(item.eligible).toBe(true);
    expect(item.reasons[0]).toEqual({ code: "AGE_OK", text: "Your age fits: 18 to 32 on 1 July 2026." });
  });

  it("one day short of the minimum age is AGE_TOO_LOW", () => {
    const item = one(answers({ dateOfBirth: "2008-07-02" }), rule({ ageAsOf: "2026-07-01", minAge: 18 }), exam());
    expect(item.eligible).toBe(false);
    expect(item.reasons[0]).toEqual({ code: "AGE_TOO_LOW", text: "You must be at least 18 on 1 July 2026. Your age on that date: 17." });
  });

  it("exactly the maximum age is eligible; one more year is AGE_TOO_HIGH", () => {
    // OC max 32: 32 on 1 July 2026 -> born 1993-07-02..1994-07-01
    expect(one(answers({ dateOfBirth: "1993-07-02" })).eligible).toBe(true); // 32
    const tooOld = one(answers({ dateOfBirth: "1993-07-01" })); // 33 on the date
    expect(tooOld.eligible).toBe(false);
    expect(tooOld.reasons[0]).toEqual({ code: "AGE_TOO_HIGH", text: "The age limit is 32 on 1 July 2026. Your age on that date: 33." });
  });

  it.each([
    ["OC", 32],
    ["BC", 34],
    ["BCM", 34],
    ["MBC_DNC", 34],
    ["SC", 37],
    ["SCA", 37],
    ["ST", 37],
  ] as const)("community %s uses its own max age %i", (community, max) => {
    const atMax = `${2026 - max}-07-01`; // exactly `max` on 1 July 2026
    const over = `${2026 - max - 1}-07-01`;
    expect(one(answers({ community, dateOfBirth: atMax })).eligible).toBe(true);
    const item = one(answers({ community, dateOfBirth: over }));
    expect(item.eligible).toBe(false);
    expect(item.ageLimit).toEqual({ min: 18, max, asOf: "2026-07-01" });
  });

  it("null max = no upper age limit for that community", () => {
    const r = rule({ maxAgeByCommunity: { OC: 32, SC: null } });
    const item = one(answers({ community: "SC", dateOfBirth: "1960-01-01" }), r);
    expect(item.eligible).toBe(true);
    expect(item.ageLimit.max).toBeNull();
    expect(item.reasons[0]?.text).toBe("Your age fits: 18 or older on 1 July 2026. There is no upper age limit for you.");
  });

  it("a community missing from the rule falls back to the OC limit (never 'no limit')", () => {
    const r = rule({ maxAgeByCommunity: { OC: 30 } });
    expect(one(answers({ community: "ST", dateOfBirth: "1990-01-01" }), r).ageLimit.max).toBe(30);
  });

  it("no relaxation reason when there is no upper limit", () => {
    const r = rule({ maxAgeByCommunity: { OC: null } });
    const item = one(answers({ specialCategories: ["PWD"] }), r);
    expect(codes(item)).not.toContain("AGE_RELAXATION_APPLIED");
  });
});

describe("relaxations (invariant 3)", () => {
  it("PwD raises the limit by 10 years, with a reason", () => {
    const born = "1985-07-01"; // 41 on 1 July 2026: over OC 32, within 42
    const item = one(answers({ dateOfBirth: born, specialCategories: ["PWD"] }));
    expect(item.eligible).toBe(true);
    expect(item.ageLimit.max).toBe(42);
    expect(item.reasons).toContainEqual({
      code: "AGE_RELAXATION_APPLIED",
      text: "Age limit raised by 10 years for persons with disability.",
    });
  });

  it("several categories: the LARGEST relaxation applies, they do not add up", () => {
    const item = one(answers({ specialCategories: ["EX_SERVICEMAN", "PWD", "DESTITUTE_WIDOW"] }));
    expect(item.ageLimit.max).toBe(42); // 32 + max(5, 10, 7), not 32 + 22
    const tooOld = one(answers({ dateOfBirth: "1983-07-01", specialCategories: ["EX_SERVICEMAN", "PWD"] })); // 43
    expect(tooOld.eligible).toBe(false);
    expect(codes(tooOld)).toEqual(["AGE_TOO_HIGH", "AGE_RELAXATION_APPLIED", "QUALIFICATION_OK"]);
  });

  it("ex-servicemen and destitute widows get their own years", () => {
    expect(one(answers({ specialCategories: ["EX_SERVICEMAN"] })).ageLimit.max).toBe(37);
    const widow = one(answers({ specialCategories: ["DESTITUTE_WIDOW"] }));
    expect(widow.ageLimit.max).toBe(39);
    expect(widow.reasons).toContainEqual({ code: "AGE_RELAXATION_APPLIED", text: "Age limit raised by 7 years for destitute widows." });
  });

  it("a category with no relaxation in the rule changes nothing", () => {
    const item = one(answers({ specialCategories: ["PWD"] }), rule({ relaxationYears: {} }));
    expect(item.ageLimit.max).toBe(32);
    expect(codes(item)).not.toContain("AGE_RELAXATION_APPLIED");
  });

  it("relaxation stacks on the community limit", () => {
    expect(one(answers({ community: "SC", specialCategories: ["PWD"] })).ageLimit.max).toBe(47);
  });
});

describe("qualification (invariants 4, 5)", () => {
  const levels = ["sslc", "hsc", "iti", "diploma", "degree", "pg"] as const;

  it.each(levels.flatMap((need, i) => levels.map((have, j) => [need, have, j >= i] as const)))(
    "needs %s, has %s -> eligible %s",
    (need, have, ok) => {
      const item = one(answers({ qualification: have }), rule({ qualifications: [need] }));
      expect(item.eligible).toBe(ok);
      expect(codes(item)).toContain(ok ? "QUALIFICATION_OK" : "QUALIFICATION_TOO_LOW");
    },
  );

  it("the LOWEST accepted level is the minimum", () => {
    const r = rule({ qualifications: ["degree", "diploma"] });
    expect(one(answers({ qualification: "diploma" }), r).eligible).toBe(true);
    expect(one(answers({ qualification: "iti" }), r).eligible).toBe(false);
  });

  it("empty qualifications fall back to the exam's minimum qualification", () => {
    const r = rule({ qualifications: [] });
    expect(one(answers({ qualification: "sslc" }), r, exam({ minQualification: "hsc" })).eligible).toBe(false);
    expect(one(answers({ qualification: "hsc" }), r, exam({ minQualification: "hsc" })).eligible).toBe(true);
  });

  it("reason text is simple English", () => {
    const item = one(answers({ qualification: "sslc" }), rule({ qualifications: ["degree"] }));
    expect(item.reasons).toContainEqual({ code: "QUALIFICATION_TOO_LOW", text: "This exam needs a degree or higher." });
    expect(one(answers(), rule({ qualifications: ["hsc"] })).reasons).toContainEqual({
      code: "QUALIFICATION_OK",
      text: "Your qualification fits: Class 12 (HSC) or higher is needed.",
    });
  });

  describe("degree subject", () => {
    const r = rule({ qualifications: ["degree"], degreeSubjects: ["Mathematics", "Statistics"] });

    it("matches case-insensitively", () => {
      expect(one(answers({ degreeSubject: "  mathematics " }), r).eligible).toBe(true);
      expect(one(answers({ qualification: "pg", degreeSubject: "STATISTICS" }), r).eligible).toBe(true);
    });

    it("wrong or missing subject -> DEGREE_SUBJECT_REQUIRED", () => {
      for (const degreeSubject of ["History", undefined]) {
        const item = one(answers({ degreeSubject }), r);
        expect(item.eligible).toBe(false);
        expect(item.reasons).toContainEqual({
          code: "DEGREE_SUBJECT_REQUIRED",
          text: "This exam needs a degree in one of these subjects: Mathematics, Statistics.",
        });
      }
    });

    it("does not apply when a lower qualification is accepted and the candidate has it", () => {
      const r2 = rule({ qualifications: ["diploma", "degree"], degreeSubjects: ["Mathematics"] });
      expect(one(answers({ qualification: "diploma" }), r2).eligible).toBe(true);
    });
  });
});

describe("PSTM (invariant 6)", () => {
  const note = "Some posts are set aside for people who studied in Tamil medium (PSTM).";
  it("adds the PSTM note when pstm is true", () => {
    const item = one(answers({ pstm: true }), rule({ pstmNote: note }));
    expect(item.reasons).toContainEqual({ code: "PSTM_PREFERENCE", text: note });
    expect(item.eligible).toBe(true);
  });
  it("no reason without pstm or without a note", () => {
    expect(codes(one(answers({ pstm: false }), rule({ pstmNote: note })))).not.toContain("PSTM_PREFERENCE");
    expect(codes(one(answers({ pstm: true }), rule({ pstmNote: null })))).not.toContain("PSTM_PREFERENCE");
  });
  it("never changes eligibility", () => {
    const tooOld = answers({ pstm: true, dateOfBirth: "1970-01-01" });
    expect(one(tooOld, rule({ pstmNote: note })).eligible).toBe(false);
  });
});

describe("published only (invariant 7)", () => {
  it("leaves out unpublished exams, unpublished rules and exams without a rule", () => {
    const list: ExamWithRule[] = [
      { exam: exam({ code: "a" }), rule: rule() },
      { exam: exam({ code: "b", status: "draft" }), rule: rule() },
      { exam: exam({ code: "c" }), rule: rule({ status: "draft" }) },
      { exam: exam({ code: "d" }), rule: rule({ status: "superseded" }) },
      { exam: exam({ code: "e" }), rule: null },
    ];
    const res = evaluateEligibility(answers(), TODAY, list);
    expect([...res.eligible, ...res.notEligible].map((x) => x.examCode)).toEqual(["a"]);
  });
});

describe("result shape (invariant 9)", () => {
  it("links the notification, else the official site; disclaimer has the official line", () => {
    const res = evaluateEligibility(answers(), TODAY, [
      { exam: exam({ code: "a", name: "A", notificationUrl: "https://www.tnpsc.gov.in/n.pdf" }), rule: rule() },
      { exam: exam({ code: "b", name: "B" }), rule: rule() },
    ]);
    expect(res.eligibleCount).toBe(2);
    expect(res.eligible.map((e) => e.officialNotificationUrl)).toEqual(["https://www.tnpsc.gov.in/n.pdf", "https://www.tnpsc.gov.in/"]);
    expect(res.disclaimer).toContain(OFFICIAL_CONFIRM_LINE);
  });
});

describe("fit ranking (invariant 8)", () => {
  it("launch exams first, then closest qualification, then age headroom, then name", () => {
    const list: ExamWithRule[] = [
      // central, needs SSLC (gap 4 for a degree holder), big headroom
      { exam: exam({ code: "c-sslc", name: "C", fullPrep: false, minQualification: "sslc" }), rule: rule({ qualifications: ["sslc"], maxAgeByCommunity: { OC: 40 } }) },
      // central, needs degree (gap 0), small headroom
      { exam: exam({ code: "c-degree", name: "D", fullPrep: false, minQualification: "degree" }), rule: rule({ qualifications: ["degree"], maxAgeByCommunity: { OC: 27 } }) },
      // launch, needs SSLC (gap 4)
      { exam: exam({ code: "l-sslc", name: "L1", fullPrep: true }), rule: rule({ qualifications: ["sslc"] }) },
      // launch, needs degree (gap 0), headroom 32-26=6
      { exam: exam({ code: "l-degree-32", name: "L2", fullPrep: true }), rule: rule({ qualifications: ["degree"] }) },
      // launch, needs degree, no upper limit -> most headroom
      { exam: exam({ code: "l-degree-none", name: "L3", fullPrep: true }), rule: rule({ qualifications: ["degree"], maxAgeByCommunity: { OC: null } }) },
    ];
    const res = evaluateEligibility(answers({ dateOfBirth: "2000-01-15" }), TODAY, list); // 26, degree
    expect(res.eligible.map((e) => [e.examCode, e.fitRank])).toEqual([
      ["l-degree-none", 1],
      ["l-degree-32", 2],
      ["l-sslc", 3],
      ["c-degree", 4],
      ["c-sslc", 5],
    ]);
  });

  it("ties broken by name; not-eligible list is ranked too, starting at 1", () => {
    const list: ExamWithRule[] = [
      { exam: exam({ code: "z", name: "Zeta" }), rule: rule() },
      { exam: exam({ code: "a", name: "Alpha" }), rule: rule() },
      { exam: exam({ code: "x", name: "X", fullPrep: false }), rule: rule({ qualifications: ["pg"] }) },
      { exam: exam({ code: "y", name: "Y", fullPrep: true }), rule: rule({ qualifications: ["pg"] }) },
    ];
    const res = evaluateEligibility(answers(), TODAY, list);
    expect(res.eligible.map((e) => [e.examCode, e.fitRank])).toEqual([["a", 1], ["z", 2]]);
    expect(res.notEligible.map((e) => [e.examCode, e.fitRank])).toEqual([["y", 1], ["x", 2]]);
  });
});
