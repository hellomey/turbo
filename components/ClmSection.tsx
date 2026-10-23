"use client";

import React from "react";

export default function ClmSection() {
  return (
    <section className="c-clm" data-clm="">
      {/* 1. Learn */}
      <div className="c-clm__section c-create" data-clm-section="">
        <div className="c-clm__cloud c-clm__cloud--right">
          <svg viewBox="0 0 698 260" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path
              d="M697.221 240.458C697.221 240.458 697.221 240.553 697.221 240.648C697.221 251.006 688.573 259.274 678.214 259.274H19.9335C7.86457 259.274 -1.06837 248.155 1.21238 236.277C15.182 164.528 78.2827 110.36 154.118 110.36C186.333 110.36 216.268 120.148 241.071 136.969C279.749 56.3826 362.046 0.694336 457.362 0.694336C589.74 0.694336 697.126 108.08 697.126 240.458H697.221Z"
              fill="white"
            ></path>
          </svg>
        </div>
        <div className="c-clm__content">
          <div
            className="c-clm__icon"
            style={
              {
                "--right": "28.5rem",
                "--top": "164px",
                "--top-mobile": "32px",
                "--right-mobile": "26px",
                "--rotate": "26deg",
              } as any
            }
          >
            <canvas
              data-clm-canvas=""
              data-artboard="Main - blue genie"
              data-state-machines="SM - Blue genie"
              width="139"
              height="139"
            ></canvas>
          </div>
          <div className="c-clm__title" aria-label="Learn">
            <span>L</span>
            <span>e</span>
            <span>a</span>
            <span>r</span>
            <span>n</span>
          </div>
        </div>
      </div>

      {/* 2. Relight */}
      <div className="c-clm__section c-like" data-clm-section="">
        <div className="c-clm__cloud c-clm__cloud--left">
          <svg viewBox="0 0 698 260" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path
              d="M697.221 240.458C697.221 240.458 697.221 240.553 697.221 240.648C697.221 251.006 688.573 259.274 678.214 259.274H19.9335C7.86457 259.274 -1.06837 248.155 1.21238 236.277C15.182 164.528 78.2827 110.36 154.118 110.36C186.333 110.36 216.268 120.148 241.071 136.969C279.749 56.3826 362.046 0.694336 457.362 0.694336C589.74 0.694336 697.126 108.08 697.126 240.458H697.221Z"
              fill="white"
            ></path>
          </svg>
        </div>
        <div className="c-clm__content">
          <div
            className="c-clm__icon"
            style={
              {
                "--left": "20.9rem",
                "--top": "74px",
                "--top-mobile": "14px",
                "--left-mobile": "34px",
              } as any
            }
          >
            <canvas
              data-clm-canvas=""
              data-artboard="Main - orange genie"
              data-state-machines="SM - Orange genie"
              width="104"
              height="104"
            ></canvas>
          </div>
          <h2 className="c-clm__title" aria-label="Relight">
            <span>R</span>
            <span>e</span>
            <span>l</span>
            <span>i</span>
            <span>g</span>
            <span>h</span>
            <span>t</span>
          </h2>
        </div>
      </div>

      {/* 3. Conquer */}
      <div className="c-clm__section c-magic" data-clm-section="">
        <div className="c-clm__cloud c-clm__cloud--right">
          <svg viewBox="0 0 698 260" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path
              d="M697.221 240.458C697.221 240.458 697.221 240.553 697.221 240.648C697.221 251.006 688.573 259.274 678.214 259.274H19.9335C7.86457 259.274 -1.06837 248.155 1.21238 236.277C15.182 164.528 78.2827 110.36 154.118 110.36C186.333 110.36 216.268 120.148 241.071 136.969C279.749 56.3826 362.046 0.694336 457.362 0.694336C589.74 0.694336 697.126 108.08 697.126 240.458H697.221Z"
              fill="white"
            ></path>
          </svg>
        </div>
        <div className="c-clm__content">
          <div
            className="c-clm__icon"
            style={
              {
                "--left": "16.8rem",
                "--bottom": "136px",
                "--bottom-mobile": "34px",
                "--left-mobile": "28px",
              } as any
            }
          >
            <canvas
              data-clm-canvas=""
              data-artboard="Main - yellow genie"
              data-state-machines="SM - Yellow genie"
              width="104"
              height="104"
            ></canvas>
          </div>
          <div
            className="c-clm__icon"
            style={
              {
                "--right": "22.5rem",
                "--top": "58px",
                "--top-mobile": "12px",
                "--right-mobile": "36px",
              } as any
            }
          >
            <canvas
              data-clm-canvas=""
              data-artboard="Main - purple genie"
              data-state-machines="SM - Purple genie"
              width="104"
              height="104"
            ></canvas>
          </div>
          <h2 className="c-clm__title" aria-label="Conquer">
            <span>C</span>
            <span>o</span>
            <span>n</span>
            <span>q</span>
            <span>u</span>
            <span>e</span>
            <span>r</span>
          </h2>
        </div>
      </div>
    </section>
  );
}
