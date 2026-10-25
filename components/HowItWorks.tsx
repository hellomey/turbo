"use client";

import React from "react";

export default function HowItWorks() {
  return (
    <section className="c-how" data-how="" id="how" style={{ background: "#ffffff" }}>
      <div className="c-how__mockup">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 80 80"
          width="80"
          height="80"
          data-how-artboard=""
        >
          <path
            fill="url(#paint0_linear_3752_31835)"
            d="M0 12C0 5.373 5.373 0 12 0h56c6.627 0 12 5.373 12 12v56c0 6.627-5.373 12-12 12H12C5.373 80 0 74.627 0 68V12Z"
          ></path>
          <path fill="#fff" d="M10 18a8 8 0 0 1 8-8h44a8 8 0 0 1 8 8v62H10V18Z"></path>
          <defs>
            <linearGradient
              id="paint0_linear_3752_31835"
              x1="40"
              x2="40"
              y1="-25.191"
              y2="103.78"
              gradientUnits="userSpaceOnUse"
            >
              <stop stopColor="#CCE7FF"></stop>
              <stop offset="1" stopColor="#fff"></stop>
            </linearGradient>
          </defs>
        </svg>
      </div>

      {/* Target coordinates container for GSAP Flip calculations */}
      <div className="c-how__icons show-desktop-tab" data-how-icons="">
        <div className="c-how__icon" data-icon="" style={{ "--color": "#FFCFB4" } as any}></div>
        <div className="c-how__icon" data-icon="" style={{ "--color": "#99CFFF" } as any}></div>
        <div className="c-how__icon" data-icon="" style={{ "--color": "#A8ECC7" } as any}></div>
        <div className="c-how__icon" data-icon="" style={{ "--color": "#E4CCFF" } as any}></div>
        <div className="c-how__icon" data-icon="" style={{ "--color": "#FFF2BE" } as any}></div>
      </div>

      <div
        className="c-how__content"
        data-how-content=""
        style={{ position: "relative", zIndex: 10 }}
      >
        <div className="c-how__label" data-how-label="" style={{ opacity: 1 }}>
          Study with purpose. <br /> Not endless confusion.
        </div>

        {/* Tablet view */}
        <h2 className="c-how__title show-tablet">
          <span className="line">
            <span>HeyMey lights your</span>
          </span>
          <span className="line line-2">
            <span className="c-how__icon" style={{ "--color": "#FFCFB4" } as any}>
              <img
                src="/icons/syllabus.svg"
                alt="Syllabus curriculum"
                style={{ width: "100%", height: "100%", borderRadius: "50%", display: "block" }}
              />
            </span>
            <span>syllabus,</span>
            <span className="c-how__icon top" style={{ "--color": "#99CFFF" } as any}>
              <img
                src="/icons/spaced-recall.svg"
                alt="Spaced recall flashcards"
                style={{ width: "100%", height: "100%", borderRadius: "50%", display: "block" }}
              />
            </span>
            <span>spaced</span>
          </span>
          <span className="line line-3">
            <span>recall,</span>
            <span className="c-how__icon" style={{ "--color": "#A8ECC7" } as any}>
              <img
                src="/icons/squad-duels.svg"
                alt="Squad duels swords"
                style={{ width: "100%", height: "100%", borderRadius: "50%", display: "block" }}
              />
            </span>
            <span>squad duels,</span>
          </span>
          <span className="line line-4">
            <span>and then builds a</span>
          </span>
          <span className="line line-5">
            <span className="c-how__icon" style={{ "--color": "#E4CCFF" } as any}>
              <img
                src="/icons/rank.svg"
                alt="Rank champion trophy"
                style={{ width: "100%", height: "100%", borderRadius: "50%", display: "block" }}
              />
            </span>
            <span>rank</span>
            <span>for</span>
          </span>
          <span className="line line-6">
            <span>you.</span>
            <span className="c-how__icon" style={{ "--color": "#FFF2BE" } as any}>
              <img
                src="/icons/you.svg"
                alt="HeyMey Sacred Lamp"
                style={{ width: "100%", height: "100%", borderRadius: "50%", display: "block" }}
              />
            </span>
          </span>
        </h2>

        {/* Desktop view */}
        <h2 className="c-how__title show-desktop-tab" data-how-title="">
          <span className="line">
            <span data-line-text="">HeyMey lights your</span>
            <span
              className="c-how__icon"
              data-icon=""
              style={{ "--color": "#FFCFB4" } as any}
            >
              <img
                src="/icons/syllabus.svg"
                alt="Syllabus curriculum"
                style={{ width: "100%", height: "100%", borderRadius: "50%", display: "block" }}
              />
            </span>
            <span data-line-text="">syllabus,</span>
          </span>
          <span className="line line-2">
            <span
              className="c-how__icon top"
              data-icon=""
              style={{ "--color": "#99CFFF", borderRadius: "50%" } as any}
            >
              <img
                src="/icons/spaced-recall.svg"
                alt="Spaced recall flashcards"
                style={{ width: "100%", height: "100%", borderRadius: "50%", display: "block" }}
              />
            </span>
            <span data-line-text="">spaced recall,</span>
            <span
              className="c-how__icon"
              data-icon=""
              style={{ "--color": "#A8ECC7" } as any}
            >
              <img
                src="/icons/squad-duels.svg"
                alt="Squad duels swords"
                style={{ width: "100%", height: "100%", borderRadius: "50%", display: "block" }}
              />
            </span>
            <span data-line-text="">squad duels,</span>
          </span>
          <span className="line line-3">
            <span data-line-text="">and then builds a</span>
            <span
              className="c-how__icon"
              data-icon=""
              style={{ "--color": "#E4CCFF" } as any}
            >
              <img
                src="/icons/rank.svg"
                alt="Rank champion trophy"
                style={{ width: "100%", height: "100%", borderRadius: "50%", display: "block" }}
              />
            </span>
            <span data-line-text="">rank</span>
          </span>
          <span className="line line-4">
            <span data-line-text="">for</span>
            <span
              className="c-how__icon"
              data-icon=""
              style={{ "--color": "#FFF2BE" } as any}
            >
              <img
                src="/icons/you.svg"
                alt="HeyMey Sacred Lamp"
                style={{ width: "100%", height: "100%", borderRadius: "50%", display: "block" }}
              />
            </span>
            <span data-line-text="">you.</span>
          </span>
        </h2>
      </div>
    </section>
  );
}
