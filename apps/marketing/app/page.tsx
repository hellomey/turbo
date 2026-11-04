"use client";

import React, { useEffect } from "react";
import Navbar from "../components/Navbar";
import Hero from "../components/Hero";
import HowItWorks from "../components/HowItWorks";
import MockupDashboard from "../components/MockupDashboard";
import OneClickSection from "../components/OneClickSection";
import ClmSection from "../components/ClmSection";
import StylesGallery from "../components/StylesGallery";
import FeaturesGrid from "../components/FeaturesGrid";
import Testimonials from "../components/Testimonials";
import Faq from "../components/Faq";
import Footer from "../components/Footer";
import { initAllAnimations } from "../lib/animations";

export default function Home() {
  useEffect(() => {
    let lenisInstance: any = null;
    const timer = setTimeout(() => {
      lenisInstance = initAllAnimations();
    }, 50);

    return () => {
      clearTimeout(timer);
      if (lenisInstance && typeof lenisInstance.destroy === "function") {
        lenisInstance.destroy();
      }
    };
  }, []);

  return (
    <main>
      <Navbar />
      <Hero />
      <HowItWorks />
      <MockupDashboard />
      <OneClickSection />
      <ClmSection />
      <StylesGallery />
      <FeaturesGrid />
      <Testimonials />
      <Faq />
      <Footer />
    </main>
  );
}
