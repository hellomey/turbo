"use client";

import React from "react";

export default function Pricing() {
  return (
    <div className="c-pricing" id="pricing" data-pricing="">
      <canvas
        data-pricing-canvas=""
        data-artboard="Main - Clouds &amp; Stars - Desktop"
        data-state-machines="SM - Clouds"
        className="show-desktop"
        width="1905"
        height="812"
      ></canvas>
      <canvas
        data-pricing-canvas=""
        data-artboard="Main - Clouds &amp; Stars - Mobile"
        data-state-machines="SM - Clouds"
        className="show-mobile"
        width="0"
        height="0"
      ></canvas>

      <div className="c-pricing__top">
        <h2 className="c-pricing__title">One plan perfect for every aspirant</h2>
      </div>

      <div className="c-pricing__bottom">
        <div className="p-card">
          <div className="p-card__genie p-card__genie--left show-desktop-tab">
            <canvas
              data-genie-left=""
              data-pricing-canvas=""
              data-artboard="Purple genie"
              data-state-machines="SM - Purple genie"
              width="200"
              height="448"
            ></canvas>
          </div>
          <div className="p-card__genie p-card__genie--right show-desktop-tab">
            <canvas
              data-genie-right=""
              data-pricing-canvas=""
              data-artboard="Orange genie"
              data-state-machines="SM - Orange genie"
              width="200"
              height="448"
            ></canvas>
          </div>

          <div className="p-card__inner" data-pricing-card="">
            <div className="p-card__left">
              <h3 className="p-card__price">
                <span className="p-card__price__amount">₹499</span>
              </h3>
              <p className="p-card__price__period">per month / aspirant</p>
              <a
                href="#pricing"
                className="c-button c-button--full c-button--small show-desktop-tab"
              >
                <span className="c-button__text">Start Free Trial</span>
              </a>
            </div>

            <div className="p-card__right">
              <div className="p-card__right__title">Plan Includes</div>
              <ul className="p-card__right__list">
                <li className="p-card__right__list__item">
                  <svg viewBox="0 0 21 21" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path
                      d="M10.3627 18.3157C10.089 18.3157 9.83894 18.2024 9.65964 18.0231C9.48033 17.8438 9.36709 17.5937 9.36709 17.32V15.7204C9.36709 14.6918 8.97072 13.6584 8.18272 12.8751C7.39471 12.0919 6.36606 11.6955 5.33741 11.6908H3.73781C3.19045 11.6908 2.74219 11.2472 2.74219 10.6951C2.74219 10.4215 2.85543 10.1714 3.03474 9.99207C3.21404 9.81277 3.45941 9.70424 3.73781 9.69952H5.32797C6.36134 9.69952 7.39471 9.30788 8.18272 8.51988C8.97072 7.73187 9.36708 6.69849 9.36236 5.66512V4.07496C9.36236 3.5276 9.81063 3.07935 10.358 3.07935C10.6317 3.07935 10.8818 3.19259 11.0611 3.3719C11.2404 3.5512 11.3536 3.80128 11.3536 4.07496V5.66512C11.3536 6.69849 11.75 7.73187 12.538 8.51988C13.326 9.30788 14.3593 9.70424 15.3927 9.70424H16.9829C17.5302 9.70424 17.9738 10.1478 17.9785 10.6999C17.9785 10.9735 17.8653 11.2236 17.6859 11.4029C17.5066 11.5822 17.2566 11.6955 16.9829 11.6955H15.3927C14.3593 11.6955 13.326 12.0871 12.538 12.8751C11.75 13.6631 11.3536 14.6965 11.3583 15.7299V17.32C11.3583 17.8674 10.9148 18.3109 10.3674 18.3109L10.3627 18.3157Z"
                      fill="url(#paint0_linear_pricing_1)"
                    ></path>
                    <defs>
                      <linearGradient
                        id="paint0_linear_pricing_1"
                        x1="10.3603"
                        y1="3.07935"
                        x2="10.3603"
                        y2="18.3157"
                        gradientUnits="userSpaceOnUse"
                      >
                        <stop stopColor="#5CBEFF"></stop>
                        <stop offset="1" stopColor="#0099FF"></stop>
                      </linearGradient>
                    </defs>
                  </svg>
                  <span className="p-card__right__list__item__text">
                    Full PYQ Vault (10+ years solved)
                  </span>
                </li>

                <li className="p-card__right__list__item">
                  <svg viewBox="0 0 21 21" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path
                      d="M10.3627 18.3157C10.089 18.3157 9.83894 18.2024 9.65964 18.0231C9.48033 17.8438 9.36709 17.5937 9.36709 17.32V15.7204C9.36709 14.6918 8.97072 13.6584 8.18272 12.8751C7.39471 12.0919 6.36606 11.6955 5.33741 11.6908H3.73781C3.19045 11.6908 2.74219 11.2472 2.74219 10.6951C2.74219 10.4215 2.85543 10.1714 3.03474 9.99207C3.21404 9.81277 3.45941 9.70424 3.73781 9.69952H5.32797C6.36134 9.69952 7.39471 9.30788 8.18272 8.51988C8.97072 7.73187 9.36708 6.69849 9.36236 5.66512V4.07496C9.36236 3.5276 9.81063 3.07935 10.358 3.07935C10.6317 3.07935 10.8818 3.19259 11.0611 3.3719C11.2404 3.5512 11.3536 3.80128 11.3536 4.07496V5.66512C11.3536 6.69849 11.75 7.73187 12.538 8.51988C13.326 9.30788 14.3593 9.70424 15.3927 9.70424H16.9829C17.5302 9.70424 17.9738 10.1478 17.9785 10.6999C17.9785 10.9735 17.8653 11.2236 17.6859 11.4029C17.5066 11.5822 17.2566 11.6955 16.9829 11.6955H15.3927C14.3593 11.6955 13.326 12.0871 12.538 12.8751C11.75 13.6631 11.3536 14.6965 11.3583 15.7299V17.32C11.3583 17.8674 10.9148 18.3109 10.3674 18.3109L10.3627 18.3157Z"
                      fill="url(#paint0_linear_pricing_1)"
                    ></path>
                  </svg>
                  <span className="p-card__right__list__item__text">
                    Unlimited Squad Battles &amp; Duels
                  </span>
                </li>

                <li className="p-card__right__list__item">
                  <svg viewBox="0 0 21 21" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path
                      d="M10.3627 18.3157C10.089 18.3157 9.83894 18.2024 9.65964 18.0231C9.48033 17.8438 9.36709 17.5937 9.36709 17.32V15.7204C9.36709 14.6918 8.97072 13.6584 8.18272 12.8751C7.39471 12.0919 6.36606 11.6955 5.33741 11.6908H3.73781C3.19045 11.6908 2.74219 11.2472 2.74219 10.6951C2.74219 10.4215 2.85543 10.1714 3.03474 9.99207C3.21404 9.81277 3.45941 9.70424 3.73781 9.69952H5.32797C6.36134 9.69952 7.39471 9.30788 8.18272 8.51988C8.97072 7.73187 9.36708 6.69849 9.36236 5.66512V4.07496C9.36236 3.5276 9.81063 3.07935 10.358 3.07935C10.6317 3.07935 10.8818 3.19259 11.0611 3.3719C11.2404 3.5512 11.3536 3.80128 11.3536 4.07496V5.66512C11.3536 6.69849 11.75 7.73187 12.538 8.51988C13.326 9.30788 14.3593 9.70424 15.3927 9.70424H16.9829C17.5302 9.70424 17.9738 10.1478 17.9785 10.6999C17.9785 10.9735 17.8653 11.2236 17.6859 11.4029C17.5066 11.5822 17.2566 11.6955 16.9829 11.6955H15.3927C14.3593 11.6955 13.326 12.0871 12.538 12.8751C11.75 13.6631 11.3536 14.6965 11.3583 15.7299V17.32C11.3583 17.8674 10.9148 18.3109 10.3674 18.3109L10.3627 18.3157Z"
                      fill="url(#paint0_linear_pricing_1)"
                    ></path>
                  </svg>
                  <span className="p-card__right__list__item__text">
                    Spaced recall &amp; Gold Lamp tracking
                  </span>
                </li>

                <li className="p-card__right__list__item">
                  <svg viewBox="0 0 21 21" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path
                      d="M10.3627 18.3157C10.089 18.3157 9.83894 18.2024 9.65964 18.0231C9.48033 17.8438 9.36709 17.5937 9.36709 17.32V15.7204C9.36709 14.6918 8.97072 13.6584 8.18272 12.8751C7.39471 12.0919 6.36606 11.6955 5.33741 11.6908H3.73781C3.19045 11.6908 2.74219 11.2472 2.74219 10.6951C2.74219 10.4215 2.85543 10.1714 3.03474 9.99207C3.21404 9.81277 3.45941 9.70424 3.73781 9.69952H5.32797C6.36134 9.69952 7.39471 9.30788 8.18272 8.51988C8.97072 7.73187 9.36708 6.69849 9.36236 5.66512V4.07496C9.36236 3.5276 9.81063 3.07935 10.358 3.07935C10.6317 3.07935 10.8818 3.19259 11.0611 3.3719C11.2404 3.5512 11.3536 3.80128 11.3536 4.07496V5.66512C11.3536 6.69849 11.75 7.73187 12.538 8.51988C13.326 9.30788 14.3593 9.70424 15.3927 9.70424H16.9829C17.5302 9.70424 17.9738 10.1478 17.9785 10.6999C17.9785 10.9735 17.8653 11.2236 17.6859 11.4029C17.5066 11.5822 17.2566 11.6955 16.9829 11.6955H15.3927C14.3593 11.6955 13.326 12.0871 12.538 12.8751C11.75 13.6631 11.3536 14.6965 11.3583 15.7299V17.32C11.3583 17.8674 10.9148 18.3109 10.3674 18.3109L10.3627 18.3157Z"
                      fill="url(#paint0_linear_pricing_1)"
                    ></path>
                  </svg>
                  <span className="p-card__right__list__item__text">
                    AI Doubt Solver &amp; Revision Shields
                  </span>
                </li>

                <li className="p-card__right__list__item">
                  <svg viewBox="0 0 21 21" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path
                      d="M10.3627 18.3157C10.089 18.3157 9.83894 18.2024 9.65964 18.0231C9.48033 17.8438 9.36709 17.5937 9.36709 17.32V15.7204C9.36709 14.6918 8.97072 13.6584 8.18272 12.8751C7.39471 12.0919 6.36606 11.6955 5.33741 11.6908H3.73781C3.19045 11.6908 2.74219 11.2472 2.74219 10.6951C2.74219 10.4215 2.85543 10.1714 3.03474 9.99207C3.21404 9.81277 3.45941 9.70424 3.73781 9.69952H5.32797C6.36134 9.69952 7.39471 9.30788 8.18272 8.51988C8.97072 7.73187 9.36708 6.69849 9.36236 5.66512V4.07496C9.36236 3.5276 9.81063 3.07935 10.358 3.07935C10.6317 3.07935 10.8818 3.19259 11.0611 3.3719C11.2404 3.5512 11.3536 3.80128 11.3536 4.07496V5.66512C11.3536 6.69849 11.75 7.73187 12.538 8.51988C13.326 9.30788 14.3593 9.70424 15.3927 9.70424H16.9829C17.5302 9.70424 17.9738 10.1478 17.9785 10.6999C17.9785 10.9735 17.8653 11.2236 17.6859 11.4029C17.5066 11.5822 17.2566 11.6955 16.9829 11.6955H15.3927C14.3593 11.6955 13.326 12.0871 12.538 12.8751C11.75 13.6631 11.3536 14.6965 11.3583 15.7299V17.32C11.3583 17.8674 10.9148 18.3109 10.3674 18.3109L10.3627 18.3157Z"
                      fill="url(#paint0_linear_pricing_1)"
                    ></path>
                  </svg>
                  <span className="p-card__right__list__item__text">
                    Real human support &amp; zero ads
                  </span>
                </li>
              </ul>
            </div>

            <a
              href="#pricing"
              className="c-button c-button--full c-button--small show-tablet"
            >
              Start Free Trial
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
