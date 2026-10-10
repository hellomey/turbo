import { Scene } from '../components/Scene';
import { Hero } from '../components/Hero';

export const Home = () => {
  return (
    <Scene panelCount={1} currentPanel={0}>
      <Hero />
    </Scene>
  );
};
