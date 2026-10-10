import { useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate, useLocation, useNavigate } from 'react-router-dom';
import { Home } from './pages/Home';
import { Studio } from './pages/Studio';
import { Exams } from './pages/Exams';
import { ExamDetailGroup4 } from './pages/ExamDetailGroup4';
import { ResultDay } from './pages/ResultDay';
import { Pricing } from './pages/Pricing';
import { About } from './pages/About';
import { Trust } from './pages/Trust';
import { Faq } from './pages/Faq';
import { JournalIndex } from './pages/JournalIndex';
import { JournalArticle } from './pages/JournalArticle';
import { Contact } from './pages/Contact';
import { Institutions } from './pages/Institutions';
import { Begin } from './pages/Begin';
import {
  LegalPrivacy,
  LegalTerms,
  LegalRefunds,
  LegalGrievance,
} from './pages/LegalPages';
import { NotFound } from './pages/NotFound';

// Redirect handler for legacy hash paths (#studio -> /studio) per spec §1
function HashRedirectHandler() {
  const location = useLocation();
  const navigate = useNavigate();

  useEffect(() => {
    const hash = window.location.hash;
    if (hash && (hash.startsWith('#studio') || hash.startsWith('#about') || hash.startsWith('#journal') || hash.startsWith('#reach-us') || hash.startsWith('#contact'))) {
      const cleanPath = hash.replace('#reach-us', 'contact').replace('#', '/');
      navigate(cleanPath, { replace: true });
    }
  }, [location, navigate]);

  return null;
}

// Redirect external helper
function ExternalRedirect({ to }: { to: string }) {
  useEffect(() => {
    window.location.href = to;
  }, [to]);
  return null;
}

export default function App() {
  return (
    <BrowserRouter>
      <HashRedirectHandler />
      <Routes>
        {/* Phase 1 Core Routes per spec §2.1 */}
        <Route path="/" element={<Home />} />
        <Route path="/studio" element={<Studio />} />
        <Route path="/exams" element={<Exams />} />
        <Route path="/exams/tnpsc-group-4" element={<ExamDetailGroup4 />} />
        <Route path="/result-day" element={<ResultDay />} />
        <Route path="/pricing" element={<Pricing />} />
        <Route path="/about" element={<About />} />
        <Route path="/trust" element={<Trust />} />
        <Route path="/faq" element={<Faq />} />
        <Route path="/journal" element={<JournalIndex />} />
        <Route path="/journal/:slug" element={<JournalArticle />} />
        <Route path="/contact" element={<Contact />} />
        <Route path="/institutions" element={<Institutions />} />
        <Route path="/begin" element={<Begin />} />
        <Route path="/legal/privacy" element={<LegalPrivacy />} />
        <Route path="/legal/terms" element={<LegalTerms />} />
        <Route path="/legal/refunds" element={<LegalRefunds />} />
        <Route path="/legal/grievance" element={<LegalGrievance />} />

        {/* Redirects per spec §2.1 */}
        <Route path="/blog" element={<Navigate to="/journal" replace />} />
        <Route path="/pro" element={<Navigate to="/pricing" replace />} />
        <Route path="/signup" element={<ExternalRedirect to="https://app.heymey.in/signup" />} />
        <Route path="/login" element={<ExternalRedirect to="https://app.heymey.in/login" />} />
        <Route path="/app" element={<ExternalRedirect to="https://app.heymey.in" />} />

        {/* 404 Fallback */}
        <Route path="*" element={<NotFound />} />
      </Routes>
    </BrowserRouter>
  );
}
