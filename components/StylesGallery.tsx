"use client";

import React from "react";

const stylesCards = [
  { title: "Study Map", desc: "Syllabus lamps: Lit → Steady → Gold", image: "/images/styles/1.webp" },
  { title: "Career Ladder", desc: "Climb from Aspirant to Chief Secretary", image: "/images/styles/2.webp" },
  { title: "Squad Battles", desc: "Bi-weekly real exam battles with peers", image: "/images/styles/3.webp" },
  { title: "District Quest", desc: "Monopoly board game across 38 TN districts", image: "/images/styles/4.webp" },
  { title: "PYQ Vault", desc: "10+ years of previous questions with deep stats", image: "/images/styles/5.webp" },
  { title: "Clue Poker", desc: "Strategic elimination game on exam facts", image: "/images/styles/6.webp" },
  { title: "Confidence Duel", desc: "Head-to-head live wager duels on exam recall", image: "/images/styles/7.webp" },
  { title: "Lucky Slot & Spin", desc: "Free daily study habit rewards", image: "/images/styles/8.webp" },
  { title: "Exam Hall", desc: "Full-length timed state-level mock tests", image: "/images/styles/9.webp" },
  { title: "Listen Mode", desc: "Audio recall for your daily commute", image: "/images/styles/10.webp" },
];

const all24Cards = Array.from({ length: 24 }, (_, i) => ({
  ...stylesCards[i % stylesCards.length],
  index: i,
  delay: i < 12 ? i : 24 - i,
}));

export default function StylesGallery() {
  return (
    <section className="c-styles" id="styles">
      <div className="c-styles__before"></div>
      <div className="c-styles__inner" data-styles="">
        <div className="c-styles__content">
          <h3 className="c-styles__title">
            Explore every game mode & syllabus topic
          </h3>
          <p className="c-styles__desc">
            Tap, play, and relight every lamp before exam day.
          </p>
        </div>

        <div className="c-styles__gallery" data-styles-gallery="">
          <div className="c-gallery" data-gallery="">
            <div className="c-gallery__inner" data-gallery-inner="">
              {all24Cards.map((card) => (
                <div
                  key={card.index}
                  className="c-gallery__image"
                  data-index={card.index}
                  data-delay={card.delay}
                  style={{ opacity: 1 }}
                >
                  <img
                    src={card.image}
                    alt={card.title}
                    loading="lazy"
                  />
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Desktop hover details */}
        <div className="c-styles__details show-desktop-tab" data-styles-details="">
          <div className="c-styles__details__title" data-details-title="">
            <h4 data-details-title-text=""></h4>
          </div>
          <div className="c-styles__details__desc" data-details-desc="">
            <p data-details-desc-text="">Hover to reveal more information</p>
          </div>
        </div>

        {/* Mobile active details */}
        <div
          className="c-styles__details active show-tablet"
          data-styles-details-mobile=""
        >
          <div
            className="c-styles__details__title"
            data-details-title-mobile=""
          >
            Study Map
          </div>
          <div
            className="c-styles__details__desc"
            data-details-desc-mobile=""
          >
            Syllabus lamps: Lit → Steady → Gold
          </div>
        </div>
      </div>
      <div className="c-styles__after"></div>
    </section>
  );
}
