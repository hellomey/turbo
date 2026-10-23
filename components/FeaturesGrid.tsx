"use client";

import React from "react";

export default function FeaturesGrid() {
  return (
    <section className="c-features" data-features="">
      <div className="c-features__top">
        <h3 className="c-styles__title">There’s more</h3>
        <p className="c-styles__desc">
          Everything you need to turn preparation into real exam readiness.
        </p>
      </div>

      <div className="c-features__cards">
        {/* Card 1: Study Map Folder */}
        <div
          className="c-features__card c-create"
          data-card="create"
          data-threshold="0.7"
        >
          <div className="c-features__card__titles">
            <h1 className="c-features__card__title">
              Master syllabus <br /> on the fly
            </h1>
            <div className="c-features__card__title alt">
              ...and share with <br /> your squad
            </div>
          </div>

          <div className="c-create__folder">
            <div className="c-folder__back">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 302 270"
              >
                <path
                  fill="#0069E0"
                  stroke="#0069E0"
                  d="M83.657.5a40.5 40.5 0 0 1 21.754 6.339l27.165 17.298a39.502 39.502 0 0 0 21.217 6.182H277c13.531 0 24.5 10.97 24.5 24.5V245c0 13.531-10.969 24.5-24.5 24.5H25C11.469 269.5.5 258.531.5 245V25C.5 11.469 11.469.5 25 .5h58.657Z"
                ></path>
              </svg>
            </div>

            <div className="c-folder__items">
              <div className="c-item yellow peek">
                <div className="c-item__icon">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 69 69"
                  >
                    <path
                      fill="currentColor"
                      d="M34.5 15l5 12 13 1-10 9 3 13-11-7-11 7 3-13-10-9 13-1z"
                    ></path>
                  </svg>
                </div>
              </div>
              <div className="c-item purple center">
                <div className="c-item__icon">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 69 69"
                  >
                    <path
                      fill="currentColor"
                      d="M20 20h29v8H20zm0 12h29v8H20zm0 12h20v8H20z"
                    ></path>
                  </svg>
                </div>
              </div>
              <div className="c-item blue left">
                <div className="c-item__icon">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 69 69"
                  >
                    <path
                      fill="currentColor"
                      d="M34.5 10a24.5 24.5 0 100 49 24.5 24.5 0 000-49zm-2 12h4v16h-4zm0 20h4v4h-4z"
                    ></path>
                  </svg>
                </div>
              </div>
              <div className="c-item orange right" data-item="right">
                <div className="c-item__icon">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 69 69"
                  >
                    <path
                      fill="currentColor"
                      d="M34.5 15C22 15 15 28 15 34.5S22 54 34.5 54 54 41 54 34.5 47 15 34.5 15zm0 30a9 9 0 110-18 9 9 0 010 18z"
                    ></path>
                  </svg>
                </div>
              </div>
            </div>

            <div className="c-folder__front">
              <div className="c-folder__front__label">TNPSC General Studies</div>
              <div className="c-folder__front__count">142 lamps</div>
            </div>
          </div>
        </div>

        {/* Card 2: Collaborate with Squad */}
        <div
          className="c-features__card c-collaborate"
          data-card="collaborate"
          data-threshold="0.6"
        >
          <div className="c-features__card__titles">
            <h1 className="c-features__card__title">
              Collaborate with <br /> squad members
            </h1>
            <div className="c-features__card__title alt">
              Challenge peers with <br /> real-time duels
            </div>
          </div>

          <div className="c-collaborate__content">
            <div className="c-collaborate__top">
              <div className="c-collaborate__top__left">
                <div className="c-avatars">
                  <div className="c-avatar">
                    <img loading="lazy" src="/images/2.svg" alt="Avatar" />
                  </div>
                  <div className="c-avatar">
                    <img loading="lazy" src="/images/4.svg" alt="Avatar" />
                  </div>
                  <div className="c-avatar">
                    <img loading="lazy" src="/images/7.svg" alt="Avatar" />
                  </div>
                  <div className="c-avatar c-avatar--num">
                    +<span>4</span>
                  </div>
                </div>
                <div className="c-avatars__label">Squad</div>
              </div>
              <div className="c-collaborate__top__right">
                <div className="c-button c-button--med">
                  <div className="c-button__icon">
                    <svg
                      width="18"
                      height="18"
                      viewBox="0 0 18 18"
                      fill="none"
                      xmlns="http://www.w3.org/2000/svg"
                    >
                      <path
                        d="M2.25 9H15.75"
                        stroke="white"
                        strokeWidth="1.6875"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      ></path>
                      <path
                        d="M9 15.75C12.7279 15.75 15.75 12.7279 15.75 9C15.75 5.27208 12.7279 2.25 9 2.25C5.27208 2.25 2.25 5.27208 2.25 9C2.25 12.7279 5.27208 15.75 9 15.75Z"
                        stroke="white"
                        strokeWidth="1.6875"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      ></path>
                    </svg>
                  </div>
                  <span>Invite</span>
                </div>
              </div>
            </div>

            <div className="c-collaborate__bottom c-chat">
              <div className="c-chat__top">
                <div className="c-chat__avatar">
                  <img loading="lazy" src="/images/4.svg" alt="Captain" />
                </div>
                <div className="c-chat__top__right">
                  <div className="c-chat__name">Captain Kavi</div>
                  <div className="c-chat__lines">
                    <div className="c-chat__line"></div>
                    <div className="c-chat__line"></div>
                  </div>
                </div>
              </div>

              <div className="c-chat__bottom">
                <div className="c-chat__bottom__left">
                  <div className="c-chat__name">You</div>
                  <div className="c-chat__bubbles">
                    <div className="c-chat__bubble"></div>
                    <div className="c-chat__bubble"></div>
                    <div className="c-chat__bubble"></div>
                  </div>
                </div>
                <div className="c-chat__avatar">
                  <img loading="lazy" src="/images/3.svg" alt="You" />
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Card 3: Enhance Recall (Flip Animation) */}
        <div
          className="c-features__card c-enhance"
          data-card="enhance"
          data-threshold="0.6"
        >
          <div className="c-features__card__titles">
            <h1 className="c-features__card__title">
              Enhance recall for <br /> even better results
            </h1>
            <div className="c-features__card__title alt">
              Spaced revision for sharper, <br /> permanent memory
            </div>
          </div>

          <div className="c-enhance__content e-content">
            <div className="e-content__top" data-top-con="">
              <div className="e-content__label">
                <div className="e-content__label__icon spin">
                  <svg
                    width="20"
                    height="20"
                    viewBox="0 0 20 20"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      d="M10.0035 17C9.72967 17 9.47945 16.8959 9.30004 16.7312C9.12064 16.5664 9.00734 16.3366 9.00734 16.0852V14.6154C9.00734 13.6702 8.61076 12.7207 7.82234 12.0009C7.03391 11.2812 6.00471 10.917 4.97551 10.9127H3.37506C2.82741 10.9127 2.37891 10.5051 2.37891 9.99782C2.37891 9.74635 2.49221 9.51656 2.67161 9.35181C2.85101 9.18705 3.09651 9.08733 3.37506 9.083H4.96607C5.99999 9.083 7.03391 8.72313 7.82234 7.99907C8.61076 7.27501 9.00733 6.32548 9.00261 5.37596V3.91483C9.00261 3.41189 9.45112 3 9.99877 3C10.2726 3 10.5228 3.10405 10.7022 3.26881C10.8816 3.43357 10.9949 3.66336 10.9949 3.91483V5.37596C10.9949 6.32548 11.3915 7.27501 12.1799 7.99907C12.9683 8.72313 14.0023 9.08734 15.0362 9.08734H16.6272C17.1748 9.08734 17.6186 9.49489 17.6234 10.0022C17.6234 10.2536 17.51 10.4834 17.3306 10.6482C17.1512 10.8129 16.901 10.917 16.6272 10.917H15.0362C14.0023 10.917 12.9683 11.2769 12.1799 12.0009C11.3915 12.725 10.9949 13.6745 10.9996 14.624V16.0852C10.9996 16.5881 10.5559 16.9957 10.0082 16.9957L10.0035 17Z"
                      fill="#CED1D4"
                    ></path>
                  </svg>
                </div>
                <div className="e-content__label__text">Relighting topic...</div>
              </div>
              <div className="e-content__label enhanced">
                <div className="e-content__label__icon scale">
                  <svg
                    width="20"
                    height="20"
                    viewBox="0 0 20 20"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      d="M10 1.875C8.39303 1.875 6.82214 2.35152 5.486 3.24431C4.14985 4.1371 3.10844 5.40605 2.49348 6.8907C1.87852 8.37535 1.71762 10.009 2.03112 11.5851C2.34463 13.1612 3.11846 14.6089 4.25476 15.7452C5.39106 16.8815 6.8388 17.6554 8.41489 17.9689C9.99099 18.2824 11.6247 18.1215 13.1093 17.5065C14.594 16.8916 15.8629 15.8502 16.7557 14.514C17.6485 13.1779 18.125 11.607 18.125 10C18.1227 7.84581 17.266 5.78051 15.7427 4.25727C14.2195 2.73403 12.1542 1.87727 10 1.875ZM13.5672 8.56719L9.19219 12.9422C9.13414 13.0003 9.06521 13.0464 8.98934 13.0778C8.91347 13.1093 8.83214 13.1255 8.75 13.1255C8.66787 13.1255 8.58654 13.1093 8.51067 13.0778C8.43479 13.0464 8.36586 13.0003 8.30782 12.9422L6.43282 11.0672C6.31554 10.9499 6.24966 10.7909 6.24966 10.625C6.24966 10.4591 6.31554 10.3001 6.43282 10.1828C6.55009 10.0655 6.70915 9.99965 6.875 9.99965C7.04086 9.99965 7.19992 10.0655 7.31719 10.1828L8.75 11.6164L12.6828 7.68281C12.7409 7.62474 12.8098 7.57868 12.8857 7.54725C12.9616 7.51583 13.0429 7.49965 13.125 7.49965C13.2071 7.49965 13.2884 7.51583 13.3643 7.54725C13.4402 7.57868 13.5091 7.62474 13.5672 7.68281C13.6253 7.74088 13.6713 7.80982 13.7027 7.88569C13.7342 7.96156 13.7504 8.04288 13.7504 8.125C13.7504 8.20712 13.7342 8.28844 13.7027 8.36431C13.6713 8.44018 13.6253 8.50912 13.5672 8.56719Z"
                      fill="url(#paint0_linear_4825_32404)"
                    ></path>
                    <defs>
                      <linearGradient
                        id="paint0_linear_4825_32404"
                        x1="10"
                        y1="1.875"
                        x2="10"
                        y2="18.125"
                        gradientUnits="userSpaceOnUse"
                      >
                        <stop stopColor="#36E287"></stop>
                        <stop offset="1" stopColor="#19B361"></stop>
                      </linearGradient>
                    </defs>
                  </svg>
                </div>
                <div className="e-content__label__text">Gold Lamp Ready</div>
              </div>
            </div>

            <div
              className="e-content__bottom"
              data-bottom-con=""
              style={{ height: 36, transition: "height 0.2s 0.2s" }}
            >
              <div className="e-content__texts base active" data-base-texts="">
                <span className="e-content__text">
                  <span data-flip-id="A">A</span>
                </span>
                <span className="e-content__text">
                  <span data-flip-id="coin">topic</span>
                </span>
                <span className="e-content__text">
                  <span data-flip-id="floating">fading</span>
                </span>
                <span className="e-content__text">
                  <span data-flip-id="around">over</span>
                </span>
                <span className="e-content__text">
                  <span data-flip-id="bank">time</span>
                </span>
                <span className="e-content__text">
                  <span data-flip-id="notes">unrevised</span>
                </span>
              </div>

              <div className="e-content__texts enhanced" data-enhanced-texts="">
                <span className="e-content__text">
                  <span data-flip-id="A" className="enhanced inactive">
                    A
                  </span>
                </span>
                <span className="e-content__text enhanced">
                  <span>golden</span>
                </span>
                <span className="e-content__text">
                  <span data-flip-id="coin" className="enhanced inactive">
                    lamp
                  </span>
                  &nbsp;
                  <span data-flip-id="floating" className="enhanced inactive">
                    burning
                  </span>
                </span>
                <span className="e-content__text enhanced">
                  <span>steady</span>
                </span>
                <span className="e-content__text enhanced">
                  <span>after 21 days</span>
                </span>
                <span className="e-content__text">
                  <span data-flip-id="around" className="enhanced inactive">
                    spaced
                  </span>
                </span>
                <span className="e-content__text enhanced">
                  <span>recall</span>
                </span>
                <span className="e-content__text enhanced">
                  <span>check</span>
                </span>
                <span className="e-content__text">
                  <span data-flip-id="bank" className="enhanced inactive">
                    passed
                  </span>
                  &nbsp;
                  <span data-flip-id="notes" className="enhanced inactive">
                    cleanly
                  </span>
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
