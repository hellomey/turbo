import { Navbar } from './components/Navbar';
import { Hero } from './components/Hero';
import { VideoBackground } from './components/VideoBackground';

export default function App() {
  return (
    <div className="relative min-h-[100dvh] min-h-screen w-full overflow-hidden bg-[#FAF7F2] selection:bg-neutral-900 selection:text-white flex flex-col justify-between">
      {/* Fullscreen responsive background video layer (z-0) */}
      <VideoBackground />

      {/* Navigation bar (z-10) */}
      <Navbar />

      {/* Hero section (z-10) */}
      <main className="relative z-10 flex-1 flex flex-col items-center justify-center sm:justify-start w-full px-2 sm:px-4">
        <Hero />
      </main>
    </div>
  );
}
