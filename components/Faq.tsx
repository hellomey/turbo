"use client";

import React from "react";

const faqs = [
  {
    q: "Is HeyMey a coaching institute or course seller?",
    a: "No. HeyMey is a product company building a gamified preparation app. We don't sell 100-hour passive lecture videos. We convert the official TNPSC syllabus into glowing lamps, spaced recall checks, and squad battles.",
  },
  {
    q: "Which exams are covered at launch?",
    a: "Full preparation content is live for TNPSC Group 4 (including VAO) and Group 2/2A. Our Exam Alerts and Eligibility Checker cover all major central and Tamil Nadu government exams from day one.",
  },
  {
    q: "How does the Study Map and Lamp system work?",
    a: "Every topic is a lamp with three rings: Lit when you learn it, Steady when you remember it through spaced recall (1, 3, 7, 21 days), and Gold when you score 80%+ under timed exam conditions. Overdue topics slowly dim to guide your daily revision.",
  },
  {
    q: "Is HeyMey available for free?",
    a: "Yes! HeyMey is free to download and use. Free aspirants get daily check-ins, study map tracking, daily lucky games, and peer duels. HeyMey Pro unlocks the full 10-year PYQ vault, AI doubt solver, and unlimited mocks.",
  },
];

export default function Faq() {
  return (
    <section className="c-faq" id="faq" data-faq="">
      <div className="c-faq__trail" data-trail=""></div>

      <div className="c-faq__content">
        <h3 className="c-faq__title">FAQs</h3>
        <div className="c-faq__list">
          {faqs.map((faq, idx) => (
            <div className="c-accordion" key={idx}>
              <details>
                <summary>{faq.q}</summary>
              </details>
              <div>
                <div>
                  <p>{faq.a}</p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
