"use client";

import React, { useState, useEffect } from "react";

export default function Navbar() {
  const [isOpen, setIsOpen] = useState(false);

  // Close menu on ESC key
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        setIsOpen(false);
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, []);

  // Close on outside tap when open
  useEffect(() => {
    if (!isOpen) return;
    const handleClickOutside = (e: MouseEvent | TouchEvent) => {
      const target = e.target as HTMLElement;
      if (!target.closest("[data-nav]")) {
        setIsOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    document.addEventListener("touchstart", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
      document.removeEventListener("touchstart", handleClickOutside);
    };
  }, [isOpen]);

  return (
    <header className="c-nav" data-nav-container="">
      {/* Desktop Navigation (>= 769px) */}
      <div className="d-nav show-desktop-tab">
        <div className="d-nav__left">
          <a href="#" className="d-nav__logo" aria-label="HeyMey Home">
            <img
              src="/wordmark.svg"
              alt="HeyMey Logo"
              height={32}
              style={{ height: "32px", width: "auto", display: "block" }}
            />
          </a>
        </div>

        <div className="d-nav__center">
          <div className="d-nav__links">
            <a href="#how" className="d-nav__link">
              How it works
            </a>
            <a href="#styles" className="d-nav__link">
              Study Map
            </a>
            <a href="#faq" className="d-nav__link">
              FAQs
            </a>
          </div>
        </div>

        <div className="d-nav__right">
          <a href="#cta" className="c-button--semi">
            <span className="c-button__text">Get App</span>
          </a>
        </div>
      </div>

      {/* Mobile & Tablet Navigation (<= 768px) */}
      <div
        className={`m-nav show-tablet ${isOpen ? "active" : ""}`}
        data-nav=""
      >
        <div className="m-nav__top">
          <div className="m-nav__logo">
            <a href="#" aria-label="HeyMey Home" onClick={() => setIsOpen(false)}>
              <img
                src="/wordmark.svg"
                alt="HeyMey Logo"
                height={24}
                style={{ height: "24px", width: "auto", display: "block" }}
              />
            </a>
          </div>
          <div className="m-nav__right">
            <a
              href="#cta"
              className="m-nav__right__button"
              onClick={() => setIsOpen(false)}
            >
              <span className="c-button--semi">Get App</span>
            </a>
            <button
              className="m-nav__right__ham hamburger-nav__toggle"
              data-nav-toggle=""
              type="button"
              aria-label={isOpen ? "Close Menu" : "Open Menu"}
              aria-expanded={isOpen}
              onClick={() => setIsOpen((prev) => !prev)}
            >
              <div className="hamburger-nav__toggle-bar"></div>
              <div className="hamburger-nav__toggle-bar"></div>
            </button>
          </div>
        </div>
        <div className="m-nav__bottom">
          <a
            href="#how"
            className="m-nav__link"
            onClick={() => setIsOpen(false)}
          >
            <span>How it works</span>
            <svg
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <polyline points="9 18 15 12 9 6"></polyline>
            </svg>
          </a>
          <a
            href="#styles"
            className="m-nav__link"
            onClick={() => setIsOpen(false)}
          >
            <span>Study Map</span>
            <svg
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <polyline points="9 18 15 12 9 6"></polyline>
            </svg>
          </a>
          <a
            href="#faq"
            className="m-nav__link"
            onClick={() => setIsOpen(false)}
          >
            <span>FAQs</span>
            <svg
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <polyline points="9 18 15 12 9 6"></polyline>
            </svg>
          </a>
        </div>
      </div>
    </header>
  );
}
