"use client";

import React from "react";

export default function Hero() {
  return (
    <section className="c-hero" data-hero="">
      <div className="c-hero__inner" style={{ position: "relative", zIndex: 10 }}>
        <div
          className="c-hero__content"
          data-hero-content=""
          style={{ position: "relative", zIndex: 10, opacity: 1, visibility: "inherit" }}
        >
          <div
            className="c-hero__text__icons show-tablet"
            data-mobile-hero-icons=""
            style={{ marginLeft: 24, marginRight: -80 }}
          >
            <div className="c-hero__text__icon">
              <canvas
                data-hero-canvas=""
                data-artboard="Main - Icon 1"
                data-state-machines="State Machine 1"
                width="0"
                height="0"
              ></canvas>
            </div>
            <div className="c-hero__text__icon">
              <canvas
                data-hero-canvas=""
                data-artboard="Main - Icon 2"
                data-state-machines="State Machine 1"
                width="0"
                height="0"
              ></canvas>
            </div>
            <div className="c-hero__text__icon">
              <canvas
                data-hero-canvas=""
                data-artboard="Main - Icon 3"
                data-state-machines="State Machine 1"
                width="0"
                height="0"
              ></canvas>
            </div>
          </div>

          <h1
            className="c-hero__title"
            data-hero-title=""
            aria-label="Aspirants don’t have to start from scratch"
          >
            <span className="line" style={{ opacity: 1 }}>
              <div data-switch-texts="" style={{ minWidth: 220 }}>
                <span style={{ opacity: 1, pointerEvents: "auto" }}>Aspirants</span>
                <span style={{ opacity: 0, pointerEvents: "none" }}>Dreamers</span>
                <span style={{ opacity: 0, pointerEvents: "none" }}>Rankers</span>
              </div>
              <div
                className="c-hero__text__icons show-desktop-tab"
                data-desktop-hero-icons=""
                style={{ marginLeft: "-2.4rem", marginRight: "-80px" }}
              >
                <div className="c-hero__text__icon">
                  <canvas
                    data-hero-canvas=""
                    data-artboard="Main - Icon 1"
                    data-state-machines="State Machine 1"
                    width="80"
                    height="80"
                  ></canvas>
                </div>
                <div className="c-hero__text__icon">
                  <canvas
                    data-hero-canvas=""
                    data-artboard="Main - Icon 2"
                    data-state-machines="State Machine 1"
                    width="80"
                    height="80"
                  ></canvas>
                </div>
                <div className="c-hero__text__icon">
                  <canvas
                    data-hero-canvas=""
                    data-artboard="Main - Icon 3"
                    data-state-machines="State Machine 1"
                    width="80"
                    height="80"
                  ></canvas>
                </div>
              </div>
              <span>don’t have</span>
            </span>
            <span className="line line-2">
              <span>to start</span>
              <span>from scratch</span>
            </span>
          </h1>

          <p className="c-hero__desc" data-hero-desc="">
            Turn your 1–3 year government-exam prep into a game you love to play.
          </p>

          <a href="#pricing" className="c-button" data-hero-button="">
            <span className="c-button__text">Start Free</span>
          </a>
        </div>
      </div>

      <canvas
        data-hero-canvas=""
        data-artboard="Main - Foreground - Desktop"
        data-state-machines="SM - All motion"
        className="show-desktop"
        width="1905"
        height="917"
      ></canvas>
      <canvas
        data-hero-canvas=""
        data-artboard="Main - Big clouds - Desktop"
        data-state-machines="SM - Clouds motion"
        className="show-desktop"
        width="1905"
        height="917"
      ></canvas>
      <canvas
        data-hero-canvas=""
        data-artboard="Main - Mobile"
        data-state-machines="SM - All motion"
        className="show-mobile"
        width="0"
        height="0"
      ></canvas>
    </section>
  );
}
