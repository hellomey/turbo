"use client";

import React from "react";

const testimonialsRow1 = [
  {
    quote: "HeyMey made revising 42 Polity topics feel like progressing in a game. My lamp turned gold and I cleared Group 4!",
    name: "Selvi Muthuram",
    title: "Junior Assistant • TNPSC Gr 4",
    avatar: "/images/lola.webp",
    logo: "/images/cadobook.webp",
  },
  {
    quote: "Squad Battles every Tuesday kept our study group accountable for 8 months straight. Unbeatable motivation.",
    name: "Karthik Rajan",
    title: "Village Administrative Officer",
    avatar: "/images/michael.webp",
    logo: "/images/meta.webp",
  },
  {
    quote: "The spaced recall dimming lamps saved my memory. When a lamp dims, you know exactly what to revise today.",
    name: "Ananya Prakash",
    title: "TNPSC Group 2 Aspirant",
    avatar: "/images/uche.webp",
    logo: "/images/wonderful-work.webp",
  },
  {
    quote: "Best preparation tool for aspirants who refuse to sit through boring 100-hour passive video courses.",
    name: "Vigneshwaran S.",
    title: "Deputy Tahsildar",
    avatar: "/images/daniel.webp",
    logo: "/images/lola-work.webp",
  },
];

const testimonialsRow2 = [
  {
    quote: "Clue Poker and District Quest turned weekend revisions into a high-energy celebration with peers.",
    name: "Priya Dharshini",
    title: "Commercial Taxes Officer",
    avatar: "/images/wonderful.webp",
    logo: "/images/pullbase.webp",
  },
  {
    quote: "The PYQ Vault with instant topic mapping is unmatched. It connects 10 years of exams straight to your lamps.",
    name: "Manikandan T.",
    title: "Group 2A Ranker",
    avatar: "/images/seun.webp",
    logo: "/images/seun-work.webp",
  },
  {
    quote: "I climbed the Career Ladder from Aspirant to Collector in the app, and now I'm living the dream in service.",
    name: "Kavitha Sundaram",
    title: "Sub-Registrar",
    avatar: "/images/shedrack.webp",
    logo: "/images/abdul-work.webp",
  },
  {
    quote: "Preparing for a government job finally feels like progressing in a game you never want to put down.",
    name: "Abdul Rahman",
    title: "Secretariat Assistant",
    avatar: "/images/abdul.webp",
    logo: "/images/cadobook.webp",
  },
];

export default function Testimonials() {
  return (
    <section className="c-testimonial">
      <div className="c-testimonial__content">
        <h3 className="c-styles__title">Made for aspirants, loved by toppers</h3>
        <p className="c-styles__desc">
          See how aspirants across Tamil Nadu are turning daily games into government jobs
        </p>
      </div>

      <div className="c-testimonial__bottom">
        {/* Row 1 - Leftward */}
        <div className="c-testimonial__marquee playing" data-marquee="">
          <div className="c-testimonial__marquee__group">
            {testimonialsRow1.map((item, idx) => (
              <div className="t-card" key={`r1-a-${idx}`}>
                <p className="t-card__desc">“{item.quote}”</p>
                <div className="t-card__bottom">
                  <div className="t-card__bottom__left">
                    <img
                      src={item.avatar}
                      alt={item.name}
                      loading="lazy"
                      className="t-card__avatar"
                    />
                    <div>
                      <h3 className="t-card__title">{item.name}</h3>
                      <p className="t-card__subtitle">{item.title}</p>
                    </div>
                  </div>
                  <img
                    src={item.logo}
                    alt={item.name}
                    loading="lazy"
                    className="t-card__logo"
                  />
                </div>
              </div>
            ))}
          </div>

          <div className="c-testimonial__marquee__group">
            {testimonialsRow1.map((item, idx) => (
              <div className="t-card" key={`r1-b-${idx}`}>
                <p className="t-card__desc">“{item.quote}”</p>
                <div className="t-card__bottom">
                  <div className="t-card__bottom__left">
                    <img
                      src={item.avatar}
                      alt={item.name}
                      loading="lazy"
                      className="t-card__avatar"
                    />
                    <div>
                      <h3 className="t-card__title">{item.name}</h3>
                      <p className="t-card__subtitle">{item.title}</p>
                    </div>
                  </div>
                  <img
                    src={item.logo}
                    alt={item.name}
                    loading="lazy"
                    className="t-card__logo"
                  />
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Row 2 - Rightward */}
        <div className="c-testimonial__marquee playing reversed" data-marquee="">
          <div className="c-testimonial__marquee__group">
            {testimonialsRow2.map((item, idx) => (
              <div className="t-card" key={`r2-a-${idx}`}>
                <p className="t-card__desc">“{item.quote}”</p>
                <div className="t-card__bottom">
                  <div className="t-card__bottom__left">
                    <img
                      src={item.avatar}
                      alt={item.name}
                      loading="lazy"
                      className="t-card__avatar"
                    />
                    <div>
                      <h3 className="t-card__title">{item.name}</h3>
                      <p className="t-card__subtitle">{item.title}</p>
                    </div>
                  </div>
                  <img
                    src={item.logo}
                    alt={item.name}
                    loading="lazy"
                    className="t-card__logo"
                  />
                </div>
              </div>
            ))}
          </div>

          <div className="c-testimonial__marquee__group">
            {testimonialsRow2.map((item, idx) => (
              <div className="t-card" key={`r2-b-${idx}`}>
                <p className="t-card__desc">“{item.quote}”</p>
                <div className="t-card__bottom">
                  <div className="t-card__bottom__left">
                    <img
                      src={item.avatar}
                      alt={item.name}
                      loading="lazy"
                      className="t-card__avatar"
                    />
                    <div>
                      <h3 className="t-card__title">{item.name}</h3>
                      <p className="t-card__subtitle">{item.title}</p>
                    </div>
                  </div>
                  <img
                    src={item.logo}
                    alt={item.name}
                    loading="lazy"
                    className="t-card__logo"
                  />
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
