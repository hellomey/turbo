"use client";

import React from "react";

const testimonialsRow1 = [
  {
    quote: "honestly was skeptical about the whole study lamp thing but after 2 weeks on the beta apk my polity revision is actually on track?? pls launch on app store soon so i can get my friends on squad battles",
    name: "Pooja R.",
    title: "Beta tester • TNPSC Gr 2 prep",
    avatar: "https://api.dicebear.com/9.x/lorelei/svg?seed=Pooja&backgroundColor=ffd5dc",
  },
  {
    quote: "The spaced repetition dimming lamps are genuinely genius. In other apps I forget what I studied 10 days ago. here when teh lamp dims I just know what to revise today. Really solid test build.",
    name: "Arun Karthik",
    title: "Early Access • UPSC CSE Aspirant",
    avatar: "https://api.dicebear.com/9.x/lorelei/svg?seed=Arun&backgroundColor=b6e3f4",
  },
  {
    quote: "finally got beta access yesterday night!! the district quest map is so addictive lol already finished 3 modules instead of scrolling reels. pls dont change anything before public release",
    name: "kavya_s",
    title: "Waitlist Member #142 • Group 4",
    avatar: "https://api.dicebear.com/9.x/lorelei/svg?seed=Kavya&backgroundColor=c0aede",
  },
  {
    quote: "been using the early build for quant & current affairs. The streak mechanics actually guilt-trip me into studying even after a 10 hr workday. Cant wait for the official rollout.",
    name: "Siddharth Menon",
    title: "Closed Beta Tester • Banking Exams",
    avatar: "https://api.dicebear.com/9.x/lorelei/svg?seed=Siddharth&backgroundColor=d1d4f9",
  },
];

const testimonialsRow2 = [
  {
    quote: "clue poker with my study partner in the test version was chaotic in the best way possible haha. never thought solving previous year questions could feel like playing cards. launch it fast guys!!",
    name: "Divya Bharathi",
    title: "Early Tester • TNPSC Group 1",
    avatar: "https://api.dicebear.com/9.x/lorelei/svg?seed=Divya&backgroundColor=ffd5dc",
  },
  {
    quote: "Found one tiny ui glitch in the leaderboard tab on day 1 (reported it on discord), but otherwise the study map concept is 10/10. It completely replaces my messy notion revision tracker.",
    name: "Mohammed Farhan",
    title: "Beta tester • SSC CGL 2026",
    avatar: "https://api.dicebear.com/9.x/lorelei/svg?seed=Farhan&backgroundColor=ffdfbf",
  },
  {
    quote: "tbh standard test series are so dry and depressing. lightng my first study lamp and seeing it turn gold actually gave me dopamine to finish company law. praying the servers hold up at launch lol",
    name: "sneha r.",
    title: "Early Access • CA Foundation",
    avatar: "https://api.dicebear.com/9.x/lorelei/svg?seed=Sneha&backgroundColor=b6e3f4",
  },
  {
    quote: "Got the testflight invite last Tuesday. Have completed 18 lamps so far without burn out. If the final release is as smooth as this preview build, its going to change how everyone prepares.",
    name: "Vignesh W.",
    title: "TestFlight Tester • Group 2 Aspirant",
    avatar: "https://api.dicebear.com/9.x/lorelei/svg?seed=Vignesh&backgroundColor=c0aede",
  },
];

export default function Testimonials() {
  return (
    <section className="c-testimonial">
      <div className="c-testimonial__content">
        <h3 className="c-styles__title">Loved by our early beta testers</h3>
        <p className="c-styles__desc">
          Unfiltered feedback from students testing our private preview builds before official launch
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
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
