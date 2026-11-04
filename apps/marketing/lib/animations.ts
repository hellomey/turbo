import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { Flip } from "gsap/Flip";
import { CustomEase } from "gsap/CustomEase";
import Lenis from "lenis";

// Register GSAP plugins
if (typeof window !== "undefined") {
  gsap.registerPlugin(ScrollTrigger, Flip, CustomEase);
  CustomEase.create("switch-texts", ".31, .31, .1, 1.12");
  gsap.defaults({ ease: "expo.out", duration: 1.2 });
}

export interface ElementRect {
  bottom: number;
  height: number;
  left: number;
  right: number;
  top: number;
  width: number;
}

export interface FlipCoords {
  x: number;
  y: number;
  scale: number;
  w1: number;
  w2: number;
  h1: number;
  h2: number;
}

// Coordinate & layout helpers
export const kl = (el: HTMLElement | null, offset = 0): ElementRect => {
  if (!el) return { bottom: 0, height: 0, left: 0, right: 0, top: 0, width: 0 };
  const rect = el.getBoundingClientRect();
  return {
    bottom: rect.bottom,
    height: rect.height,
    left: rect.left,
    right: rect.right,
    top: rect.top + offset,
    width: rect.width,
  };
};

export const Qo = (fromEl: HTMLElement | null, toEl: HTMLElement | null): FlipCoords => {
  if (!fromEl || !toEl) return { x: 0, y: 0, scale: 1, w1: 0, w2: 0, h1: 0, h2: 0 };
  const fromRect = kl(fromEl);
  const toRect = kl(toEl);
  return {
    x: toRect.left - fromRect.left,
    y: toRect.top - fromRect.top,
    scale: fromRect.width ? toRect.width / fromRect.width : 1,
    w1: fromRect.width,
    w2: toRect.width,
    h1: fromRect.height,
    h2: toRect.height,
  };
};

export function splitTextWords(el: HTMLElement) {
  const walk = (node: Node) => {
    if (node.nodeType === Node.TEXT_NODE) {
      const text = node.textContent || "";
      if (!text.trim()) return;
      const frag = document.createDocumentFragment();
      const parts = text.split(/(\s+)/);
      parts.forEach((part) => {
        if (/^\s+$/.test(part)) {
          frag.appendChild(document.createTextNode(part));
        } else if (part.length > 0) {
          const span = document.createElement("span");
          span.className = "w";
          span.textContent = part;
          frag.appendChild(span);
        }
      });
      node.parentNode?.replaceChild(frag, node);
    } else if (node.nodeType === Node.ELEMENT_NODE) {
      if ((node as HTMLElement).tagName.toLowerCase() === "br") return;
      Array.from(node.childNodes).forEach(walk);
    }
  };
  Array.from(el.childNodes).forEach(walk);
}

export const Ji = (riveInstance: any, smName: string, inputName: string) => {
  if (!riveInstance || !riveInstance.stateMachineInputs) return null;
  const inputs = riveInstance.stateMachineInputs(smName);
  return inputs ? inputs.find((i: any) => i.name === inputName) : null;
};

// Auto-bind helper
export function autoBind(instance: any) {
  const proto = Object.getPrototypeOf(instance);
  Object.getOwnPropertyNames(proto).forEach((prop) => {
    if (prop !== "constructor" && typeof instance[prop] === "function") {
      instance[prop] = instance[prop].bind(instance);
    }
  });
}

// Window resize watcher
export class WindowWidthWatcher {
  windowWidth: number;
  callbacks: Set<(w: number) => void>;

  constructor() {
    this.windowWidth = typeof window !== "undefined" ? window.innerWidth : 1200;
    this.callbacks = new Set();
    if (typeof window !== "undefined") {
      window.addEventListener("resize", this.handleResize.bind(this));
    }
  }

  handleResize() {
    if (typeof window === "undefined") return;
    if (window.innerWidth !== this.windowWidth) {
      this.windowWidth = window.innerWidth;
      this.callbacks.forEach((cb) => cb(this.windowWidth));
    }
  }

  onWidthChange(cb: (w: number) => void) {
    this.callbacks.add(cb);
    return () => this.callbacks.delete(cb);
  }
}

export const windowWatcher = new WindowWidthWatcher();

export interface RiveInstanceRecord {
  rive: any;
  canvas: HTMLCanvasElement;
  stateMachines: string;
}

// Bump this whenever the images in public/rive/create_with_one_click/ are replaced —
// that folder is served with a year-long immutable Cache-Control, so same-name file
// swaps won't be picked up by returning visitors without a cache-busting query.
const RIVE_ASSET_VERSION = 2;

// Rive text ships with a trial font that is missing glyphs; swap in free Geist (OFL)
const fontBytesCache = new Map<string, Promise<Uint8Array>>();

function geistUrlFor(name: string) {
  const n = (name || "").toLowerCase();
  if (/bold|semi|heavy|black/.test(n)) return "/fonts/Geist-SemiBold.ttf";
  if (/regular|book|light|normal/.test(n)) return "/fonts/Geist-Regular.ttf";
  return "/fonts/Geist-Medium.ttf";
}

export async function setRiveFallbackFont(asset: any, decodeFont: (bytes: Uint8Array) => Promise<any>) {
  const url = geistUrlFor(asset.name);
  if (!fontBytesCache.has(url)) {
    fontBytesCache.set(
      url,
      fetch(url).then((r) => r.arrayBuffer()).then((b) => new Uint8Array(b))
    );
  }
  try {
    const font = await decodeFont(await fontBytesCache.get(url)!);
    asset.setFont(font);
    font.unref?.();
  } catch (e) {
    console.warn("Failed to load fallback font for Rive asset:", asset.name, e);
  }
}

export function riveFontLoader(riveModule: any) {
  const { decodeFont } = (riveModule as any).default || riveModule;
  return (asset: any) => {
    if (!asset.isFont) return false;
    setRiveFallbackFont(asset, decodeFont);
    return true;
  };
}

// Rive manager
export class RiveComponentManager {
  instances: RiveInstanceRecord[] = [];

  constructor() {
    this.instances = [];
    if (typeof window !== "undefined") {
      window.addEventListener("resize", () => {
        this.instances.forEach((e) => {
          e.rive?.resizeDrawingSurfaceToCanvas();
        });
      });
    }
  }

  setupRiveInstance(config: any, totalCount: number, autoObserve = true, RiveClass: any) {
    try {
      const riveInst = new RiveClass({
        ...config,
        onLoad: () => {
          try {
            riveInst.resizeDrawingSurfaceToCanvas();
          } catch (_) {}
          this.instances.push({
            rive: riveInst,
            canvas: config.canvas,
            stateMachines: config.stateMachines,
          });
          if (config.onLoad) config.onLoad();
          if (totalCount === this.instances.length && autoObserve) {
            this.observeInstances();
          }
        },
      });
      return riveInst;
    } catch (err) {
      console.warn("Rive setup error:", err);
      return null;
    }
  }

  observeInstances() {
    this.instances.forEach((e) => {
      if (!e.canvas) return;
      new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
          try {
            if (entry.isIntersecting) {
              if (e.rive?.isPaused) e.rive.play();
            } else {
              if (e.rive?.isPlaying) e.rive.pause();
            }
          } catch (_) {}
        });
      }).observe(e.canvas);
    });
  }
}

export interface BaseComponentConfig {
  element: string | HTMLElement;
  elements: Record<string, any>;
}

// Base Component class
export class BaseComponent {
  selector: string | HTMLElement;
  selectorChildren: Record<string, any>;
  element: HTMLElement | null = null;
  elements: Record<string, any> = {};

  constructor({ element, elements }: BaseComponentConfig) {
    autoBind(this);
    this.selector = element;
    this.selectorChildren = { ...elements };
    this.create();
  }

  create() {
    if (typeof document === "undefined") return;
    this.element =
      this.selector instanceof HTMLElement
        ? this.selector
        : (document.querySelector(this.selector) as HTMLElement | null);
    if (!this.element) return;
    this.elements = {};
    Object.keys(this.selectorChildren).forEach((key) => {
      const sel = this.selectorChildren[key];
      if (
        sel instanceof HTMLElement ||
        sel instanceof NodeList ||
        Array.isArray(sel)
      ) {
        this.elements[key] = sel;
      } else {
        const found = this.element!.querySelectorAll(sel);
        if (found.length === 0) this.elements[key] = null;
        else if (found.length === 1) this.elements[key] = found[0];
        else this.elements[key] = Array.from(found);
      }
    });
  }
}

// 1. Hero Animation (Cherry Blossom Theme)
export class HeroAnimation extends BaseComponent {
  constructor() {
    super({
      element: "#hero",
      elements: {
        title: "#heroTitle",
        glass: "#heroGlass",
        nav: ".hero .nav",
        clouds: ".cloud",
        media: ".hero-media",
      },
    });
    if (!this.element) return;
    this.initHero();
  }

  initHero() {
    const isMobile = typeof window !== "undefined" && window.innerWidth <= 760;
    const prefersReducedMotion =
      typeof window !== "undefined" &&
      window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    // 1. Split words for #heroTitle
    const titleEl = document.getElementById("heroTitle");
    if (titleEl) {
      splitTextWords(titleEl);
      const words = titleEl.querySelectorAll(".w");
      gsap.set(words, { opacity: 0, y: 24, filter: "blur(10px)" });
      gsap.to(words, {
        opacity: 1,
        y: 0,
        filter: "blur(0px)",
        duration: 1.0,
        stagger: 0.07,
        ease: "power3.out",
        delay: 0.25,
      });
    }

    // Subtitle reveal
    const subEl = this.element.querySelector(".hero-sub");
    if (subEl) {
      gsap.fromTo(
        subEl,
        { opacity: 0, y: 16 },
        { opacity: 1, y: 0, duration: 0.9, ease: "power3.out", delay: 0.55 }
      );
    }

    // Nav entrance
    const navEl = this.element.querySelector(".nav");
    if (navEl) {
      gsap.fromTo(
        navEl,
        { opacity: 0, y: -16 },
        { opacity: 1, y: 0, duration: 0.8, ease: "power3.out", delay: 0.1 }
      );
    }

    // Clouds entrance
    const cloudL = this.element.querySelector(".cloud-l");
    const cloudR = this.element.querySelector(".cloud-r");
    if (cloudL) {
      gsap.fromTo(
        cloudL,
        { x: -80, opacity: 0 },
        {
          x: 0,
          opacity: 1,
          duration: 1.4,
          ease: "power3.out",
          delay: 0.15,
          onComplete: () => {
            gsap.set(cloudL, { clearProps: "x" });
          },
        }
      );
    }
    if (cloudR) {
      gsap.fromTo(
        cloudR,
        { x: 80, opacity: 0 },
        {
          x: 0,
          opacity: 1,
          duration: 1.4,
          ease: "power3.out",
          delay: 0.15,
          onComplete: () => {
            gsap.set(cloudR, { clearProps: "x" });
          },
        }
      );
    }

    // 2. Frosted glass squares at [x%, y%]
    const glassContainer = document.getElementById("heroGlass");
    if (glassContainer) {
      glassContainer.innerHTML = "";
      const coords = [
        [3, 64], [3, 71], [6.5, 71], [10, 71], [3, 78], [-1, 70],
        [45.5, 76], [49, 80], [49, 76], [52.5, 76],
        [86, 58], [86, 67], [82, 76], [89.5, 76], [86, 84],
      ];

      coords.forEach(([x, y], idx) => {
        if (isMobile && idx % 2 !== 0) return;
        const sq = document.createElement("div");
        sq.className = "glass";
        sq.style.left = x + "%";
        sq.style.top = y + "%";
        if (x > 40 && x < 60) {
          sq.style.width = "clamp(28px, 3.4vw, 44px)";
          sq.style.height = "clamp(28px, 3.4vw, 44px)";
        } else {
          sq.style.width = "clamp(36px, 5.4vw, 74px)";
          sq.style.height = "clamp(36px, 5.4vw, 74px)";
        }
        glassContainer.appendChild(sq);

        gsap.fromTo(
          sq,
          { opacity: 0, scale: 0.6 },
          {
            opacity: 1,
            scale: 1,
            duration: 0.6,
            ease: "back.out(2)",
            delay: 0.35 + Math.random() * 0.3,
          }
        );

        if (!prefersReducedMotion) {
          gsap.to(sq, {
            opacity: 0.15,
            duration: 0.9,
            yoyo: true,
            repeat: -1,
            ease: "sine.inOut",
            delay: Math.random() * 3,
            repeatDelay: 1 + Math.random() * 3,
          });
        }
      });
    }

    // 3. Parallax on Scroll (top top -> bottom top, scrub)
    if (titleEl) {
      gsap.to(titleEl, {
        yPercent: -60,
        ease: "none",
        scrollTrigger: {
          trigger: this.element,
          start: "top top",
          end: "bottom top",
          scrub: true,
        },
      });
    }

    const parClouds = this.element.querySelectorAll("[data-par]");
    parClouds.forEach((c) => {
      const par = parseFloat(c.getAttribute("data-par") || "0");
      gsap.to(c, {
        y: par * 2,
        ease: "none",
        scrollTrigger: {
          trigger: this.element,
          start: "top top",
          end: "bottom top",
          scrub: true,
        },
      });
    });

    const mediaEl = this.element.querySelector(".hero-media");
    if (mediaEl) {
      gsap.to(mediaEl, {
        yPercent: 8,
        ease: "none",
        scrollTrigger: {
          trigger: this.element,
          start: "top top",
          end: "bottom top",
          scrub: true,
        },
      });
    }

    // Sticky nav toggle helper
    ScrollTrigger.create({
      trigger: this.element,
      start: "bottom top",
      onEnter: () => document.body.classList.add("scrolled-down"),
      onLeaveBack: () => document.body.classList.remove("scrolled-down"),
    });
  }
}

// 2. How It Works Animation (Tm)
export class HowAnimation extends BaseComponent {
  flipData: FlipCoords[] = [];
  centerFlipData: FlipCoords[] = [];
  

  constructor() {
    super({
      element: "[data-how]",
      elements: {
        iconsContainer: "[data-how-icons]",
        icons: "[data-how-icons] [data-icon]",
        contentContainer: "[data-how-content]",
        titleIcons: "[data-how-title] [data-icon]",
        titleLines: "[data-how-title] [data-line-text]",
        label: "[data-how-label]",
        mockup: "[data-how-artboard]",
        
      },
    });
    if (!this.element) return;
    const mm = gsap.matchMedia();
    mm.add("(min-width: 769px)", () => {
      this.initTextIcons();
      this.createTimeline();
    });
    mm.add("(max-width: 768px)", () => {
      this.resetTextIcons();
    });
    
  }

  initTextIcons() {
    const tIcons = (
      Array.isArray(this.elements.titleIcons)
        ? this.elements.titleIcons
        : [this.elements.titleIcons]
    ).filter(Boolean) as HTMLElement[];
    const icons = (
      Array.isArray(this.elements.icons)
        ? this.elements.icons
        : [this.elements.icons]
    ).filter(Boolean) as HTMLElement[];
    if (!tIcons.length || !icons.length) return;

    this.flipData = [];
    this.centerFlipData = [];
    tIcons.forEach((t, i) => {
      if (i === 1) return;
      const r = Qo(t, icons[2]);
      this.centerFlipData.push(r);
    });
    tIcons.forEach((t, i) => {
      if (i !== 1) return;
      const r = Qo(t, icons[2]);
      this.centerFlipData.push(r);
    });
    tIcons.forEach((t, i) => {
      const targetIcon = icons[i] || icons[0];
      const r = Qo(t, targetIcon);
      this.flipData.push(r);
      t.style.transform = `translate(${r.x}px, ${r.y}px)`;
      t.style.opacity = "1";
    });
  }

  resetTextIcons() {
    const tIcons = (
      Array.isArray(this.elements.titleIcons)
        ? this.elements.titleIcons
        : [this.elements.titleIcons]
    ).filter(Boolean) as HTMLElement[];
    tIcons.forEach((n) => {
      n.style.transform = "none";
      n.style.opacity = "0";
    });
  }

  createTimeline() {
    const e = this.elements.label as HTMLElement;
    const n = (
      Array.isArray(this.elements.titleLines)
        ? this.elements.titleLines
        : [this.elements.titleLines]
    ).filter(Boolean) as HTMLElement[];
    const t = (
      Array.isArray(this.elements.titleIcons)
        ? this.elements.titleIcons
        : [this.elements.titleIcons]
    ).filter(Boolean) as HTMLElement[];
    const i = this.elements.mockup as HTMLElement;

    if (!t.length || !n.length || !this.flipData || this.flipData.length < 5) return;

    const r = gsap.timeline({
      scrollTrigger: {
        trigger: this.element,
        start: "top top",
        end: "+=1200",
        pin: true,
        scrub: 1,
      },
    });

    const o = gsap.timeline({ defaults: { duration: 0.15, ease: "none" } });
    o.to(t[0], { y: 0 })
      .to(t[0], { x: 0 })
      .set(n[1], { opacity: 1 }, "<100%")
      .from(n[1], { duration: 0.05, x: -30 }, "<")
      .set(n[0], { opacity: 1 }, "<100%")
      .from(n[0], { duration: 0.05, x: -20 }, "<")
      .to([t[1], t[2]], { y: 0 }, "<-500%")
      .to(t[3], { y: 0 }, "<50%")
      .to(t[4], { y: this.flipData[4].y + this.flipData[4].h2 * 0.58 }, "<")
      .to(t[1], { x: 0 }, "<50%")
      .to(t[2], { x: 0 }, "<20%")
      .set(n[2], { opacity: 1 }, "<+60%")
      .from(n[2], { duration: 0.05, x: 30 }, "<")
      .set(n[3], { opacity: 1 }, "<70%")
      .from(n[3], { duration: 0.05, x: 15 }, "<")
      .to(t[4], { y: 0 }, "<-200%")
      .to(t[3], { x: 0 }, "<50%")
      .set(n[4], { opacity: 1 }, "<50%")
      .from(n[4], { duration: 0.05, x: -15 }, "<")
      .set(n[5], { opacity: 1 }, "<70%")
      .from(n[5], { duration: 0.05, x: 15 }, "<")
      .to(t[4], { x: 0 }, "<-60%")
      .set(n[6], { opacity: 1 }, "<70%")
      .from(n[6], { duration: 0.05, x: 10 }, "<")
      .set(n[7], { opacity: 1 }, "<70%")
      .from(n[7], { duration: 0.05, x: 10 }, "<");

    const u = gsap.timeline({ defaults: { duration: 0.15, ease: "none" } });
    u.to([e, n], { opacity: 0, delay: 0.35, duration: 0.25 })
      .to(t[1], {
        x: this.centerFlipData[4]?.x || 0,
        y: this.centerFlipData[4]?.y || 0,
        scale: 1.5,
        duration: 0.4,
        borderRadius: "2.4rem",
      })
      .to(
        [t[0], t[2], t[3], t[4]],
        {
          duration: 0.5,
          x: (d: number) => this.centerFlipData[d]?.x || 0,
          y: (d: number) => this.centerFlipData[d]?.y || 0,
        },
        "<"
      )
      .to([t[0], t[2], t[3], t[4]], { opacity: 0 })
      .to(t[1], { opacity: 0 })
      .to(i, { opacity: 1, duration: 0.2 }, "<")
      .to(i, { duration: 0.05, opacity: 1 });

    r.add(o);
    r.add(u);
  }
}

// 3. Mockup 3D Animation (Sm)
export class MockupAnimation extends BaseComponent {
  howMockup: HTMLElement | null = null;

  constructor() {
    super({
      element: "[data-mockup]",
      elements: {
        ill: "[data-mockup-ill]",
        artboard: "[data-mockup-ill-artboard]",
      },
    });
    if (!this.element) return;
    this.howMockup = document.querySelector("[data-how-artboard]");
    const mm = gsap.matchMedia();
    mm.add("(min-width: 768px)", () => {
      this.createTimeline();
    });
  }

  createTimeline() {
    const e = this.elements.ill as HTMLElement;
    const n = this.elements.artboard as HTMLElement;
    if (!e || !n || !this.howMockup) return;

    const t = Qo(this.howMockup, n);
    gsap.set(this.howMockup, { scale: 1.5 });
    gsap.set(e, { rotate: -15, rotateY: 28, rotateX: 45 });

    // Infinite card switcher
    gsap
      .timeline({
        repeat: -1,
        repeatDelay: 3,
        repeatRefresh: true,
        defaults: { ease: "power1.out", duration: 1 },
      })
      .to("#ill-images-group", { xPercent: -49 })
      .to("#ill-indicator-active", { scale: 24 / 32, transformOrigin: "center center" }, "<")
      .to("#ill-indicator-inactive", { scale: 32 / 24, transformOrigin: "center center" }, "<")
      .to("#ill-images-group", { delay: 3, xPercent: 0 })
      .to("#ill-indicator-active", { scale: 1, transformOrigin: "center center", duration: 0.5 }, "<")
      .to("#ill-indicator-inactive", { scale: 1, transformOrigin: "center center", duration: 0.5 }, "<");

    // Scroll trigger entry
    gsap
      .timeline({
        scrollTrigger: {
          trigger: this.element,
          start: "top bottom",
          end: "50% 50%",
          scrub: 1,
        },
        defaults: { ease: "none" },
      })
      .to(this.howMockup, { x: t.x, y: t.y, scale: 1, duration: 0.8 })
      .to(e, { rotate: 0, rotateY: 0, rotateX: 0, scale: 1, duration: 0.5 }, "<")
      .from("#ill-nav-item", { xPercent: -20, duration: 0.5, stagger: 0.1 }, "<");
  }
}

// 4. One Click Section (Om)
export const Vr = { maxState: 220, reverseState: 200, minState: 100, autoPlayState: 201 };
export class OneClickAnimation extends BaseComponent {
  riveComponent: RiveComponentManager | null = null;
  scrollTrigger: ScrollTrigger | null = null;
  secScrollTrigger: ScrollTrigger | null = null;
  initialScrollTrigger: ScrollTrigger | null = null;

  constructor() {
    super({
      element: "[data-click]",
      elements: {
        inner: "[data-click-inner]",
        allCanvas: "[data-click-canvas]",
      },
    });
    if (!this.element) return;
    this.initBgRive();
    this.addScrollListeners();
  }

  async loadImage(asset: any, decodeImage: (bytes: Uint8Array) => Promise<any>) {
    try {
      const base = "/rive/create_with_one_click/";
      const encodedName = encodeURIComponent(asset.name);
      // Cache-busted: /rive/:path* is served as immutable for a year (next.config.mjs),
      // so bump RIVE_ASSET_VERSION whenever these image files are replaced.
      let res = await fetch(`${base}${encodedName}.webp?v=${RIVE_ASSET_VERSION}`);
      if (!res.ok) {
        res = await fetch(`${base}${encodedName}.png?v=${RIVE_ASSET_VERSION}`);
      }
      if (res.ok) {
        const buf = await res.arrayBuffer();
        const renderImg = await decodeImage(new Uint8Array(buf));
        asset.setRenderImage(renderImg);
      }
    } catch (e) {
      console.warn("Failed to load Rive image asset:", asset.name, e);
    }
  }

  async loadFont(asset: any, decodeFont: (bytes: Uint8Array) => Promise<any>) {
    await setRiveFallbackFont(asset, decodeFont);
  }

  async initBgRive() {
    try {
      const riveMod = await import("@rive-app/canvas");
      const RivePkg = (riveMod as any).default || riveMod;
      const { Rive, RiveFile, Layout, Fit, decodeImage, decodeFont } = RivePkg;
      const canvases = (
        Array.isArray(this.elements.allCanvas)
          ? this.elements.allCanvas
          : [this.elements.allCanvas]
      ).filter(Boolean) as HTMLCanvasElement[];
      if (canvases.length === 0) return;

      this.riveComponent = new RiveComponentManager();
      const riveFile = new RiveFile({
        src: "/rive/create_with_one_click/create_with_one_click.riv?v=5",
        assetLoader: (asset: any) => {
          if (asset.isImage) {
            this.loadImage(asset, decodeImage);
            return true;
          }
          if (asset.isFont) {
            this.loadFont(asset, decodeFont);
            return true;
          }
          return false;
        },
        onLoad: () => {
          canvases.forEach((c) => {
            const artboard = c.getAttribute("data-artboard") || undefined;
            const sm = c.getAttribute("data-state-machines") || undefined;
            this.riveComponent!.setupRiveInstance(
              {
                riveFile,
                canvas: c,
                stateMachines: sm,
                artboard,
                layout: new Layout({ fit: Fit.Cover }),
              },
              canvases.length,
              true,
              Rive
            );
          });
        },
        onLoadError: () => console.log("OneClick Rive load notice"),
      });
      await riveFile.init();
      this.initialScrollTrigger?.refresh();
      this.scrollTrigger?.refresh();
      this.secScrollTrigger?.refresh();
    } catch (err) {
      console.error("OneClick initBgRive notice:", err);
    }
  }

  setScrollPct(val: number) {
    this.riveComponent?.instances.forEach((n) => {
      const t = Ji(n.rive, n.stateMachines, "Scrll Pct");
      if (t) t.value = val;
    });
  }

  addScrollListeners() {
    const e = this.elements.inner as HTMLElement;
    if (!e) return;
    const n = Vr.minState;
    let t = Vr.maxState;

    this.scrollTrigger = ScrollTrigger.create({
      trigger: e,
      start: "top top",
      end: "+=200%",
      pin: true,
      scrub: true,
      onUpdate: (i) => {
        const r = t - n;
        const o = i.progress * r + n;
        this.setScrollPct(o);
      },
    });

    this.secScrollTrigger = ScrollTrigger.create({
      trigger: e,
      start: "top top",
      end: "+=220%",
      onEnter: () => {
        t = Vr.maxState;
      },
      onLeave: () => {
        this.setScrollPct(Vr.maxState);
      },
      onEnterBack: () => {
        this.setScrollPct(Vr.reverseState);
        t = Vr.autoPlayState;
      },
    });

    this.initialScrollTrigger = ScrollTrigger.create({
      trigger: e,
      start: "-20% bottom",
      end: "top top",
      scrub: true,
      onUpdate: (i) => {
        this.setScrollPct(i.progress * n);
      },
    });
  }
}

// 5. Create / Like / Magic (Rm) -> Learn / Relight / Conquer
export class ClmAnimation extends BaseComponent {
  riveComponent: RiveComponentManager | null = null;

  constructor() {
    super({
      element: "[data-clm]",
      elements: {
        sections: "[data-clm-section]",
        allCanvas: "[data-clm-canvas]",
      },
    });
    if (!this.element) return;
    this.init();
    this.observeLoadRive();
  }

  init() {
    const sections = (
      Array.isArray(this.elements.sections)
        ? this.elements.sections
        : [this.elements.sections]
    ).filter(Boolean) as HTMLElement[];
    sections.forEach((sec, idx) => {
      this.createScrollAnim(sec, idx);
    });
  }

  isEven(idx: number): boolean {
    return idx % 2 === 0;
  }

  createScrollAnim(sec: HTMLElement, idx: number) {
    const isEv = this.isEven(idx);
    const cloud = sec.querySelector(".c-clm__cloud");
    const content = sec.querySelector(".c-clm__content");
    const spans = sec.querySelectorAll(".c-clm__title span");
    const u = { trigger: sec, start: "top 90%", end: "bottom top", scrub: 1 };

    if (cloud) {
      gsap.from(cloud, {
        xPercent: isEv ? 100 : -100,
        duration: 2,
        ease: "power2.out",
        scrollTrigger: { trigger: sec, start: "top 60%", end: "bottom top" },
      });
    }
    if (content) {
      gsap.from(content, {
        xPercent: isEv ? 100 : -100,
        scrollTrigger: { ...u },
      });
    }
    if (spans && spans.length) {
      gsap.from(spans, {
        yPercent: gsap.utils.wrap([-30, 30]),
        stagger: 0.15,
        scrollTrigger: { ...u },
      });
    }
  }

  observeLoadRive() {
    if (!this.element) return;
    const obs = new IntersectionObserver((entries) => {
      entries.forEach((t) => {
        if (t.isIntersecting) {
          this.initBgRive();
          obs.disconnect();
        }
      });
    });
    obs.observe(this.element);
  }

  async initBgRive() {
    try {
      const riveModule = await import("@rive-app/canvas");
      const { Rive, RiveFile, Layout, Fit } = riveModule;
      const canvases = (
        Array.isArray(this.elements.allCanvas)
          ? this.elements.allCanvas
          : [this.elements.allCanvas]
      ).filter(Boolean) as HTMLCanvasElement[];
      if (canvases.length === 0) return;

      this.riveComponent = new RiveComponentManager();
      const riveFile = new RiveFile({
        src: "/rive/create_like_magic.riv",
        assetLoader: riveFontLoader(riveModule),
        onLoad: () => {
          canvases.forEach((c) => {
            const artboard = c.getAttribute("data-artboard") || undefined;
            const sm = c.getAttribute("data-state-machines") || undefined;
            this.riveComponent!.setupRiveInstance(
              {
                riveFile,
                canvas: c,
                stateMachines: sm,
                artboard,
                layout: new Layout({ fit: Fit.FitWidth }),
              },
              canvases.length,
              true,
              Rive
            );
          });
        },
      });
      await riveFile.init();
    } catch (_) {}
  }
}

// 6. Circular 3D Style Gallery (Am)
export const Ol = 768;
export const stylesData = [
  { title: "Study Map", desc: "Syllabus lamps: Lit → Steady → Gold", image: "/images/styles/1.webp" },
  { title: "Career Ladder", desc: "Climb from Aspirant to Chief Secretary", image: "/images/styles/2.webp" },
  { title: "Squad Battles", desc: "Bi-weekly real exam battles with peers", image: "/images/styles/3.webp" },
  { title: "District Quest", desc: "Monopoly board game across 38 TN districts", image: "/images/styles/4.webp" },
  { title: "PYQ Vault", desc: "10+ years of previous questions with deep stats", image: "/images/styles/5.webp" },
  { title: "Clue Poker", desc: "Strategic elimination game on exam facts", image: "/images/styles/6.webp" },
  { title: "Confidence Duel", desc: "Head-to-head live wager duels on exam recall", image: "/images/styles/7.webp" },
  { title: "Lucky Slot & Spin", desc: "Free daily study habit rewards", image: "/images/styles/8.webp" },
  { title: "Exam Hall", desc: "Full-length timed state-level mock tests", image: "/images/styles/9.webp" },
  { title: "Listen Mode", desc: "Audio recall for your daily commute", image: "/images/styles/10.webp" },
];

export const galleryDeck: typeof stylesData = [];
for (let i = 0; i < 24; i++) {
  galleryDeck.push(stylesData[i % stylesData.length]);
}

export const Ct = {
  imageCount: galleryDeck.length,
  radius: typeof window !== "undefined" ? window.innerWidth * 0.7 : 800,
  sensitivity: 700,
  effectFalloff: 500,
  cardMoveAmount: 50,
  lerpFactor: 0.1,
  isMobile: typeof window !== "undefined" ? window.innerWidth < 1000 : false,
  timeout: 300,
};

export class GalleryAnimation extends BaseComponent {
  parallaxState = { targetX: 0, targetY: 0, targetZ: 0, currentX: 0, currentY: 0, currentZ: 0 };
  cards: HTMLElement[] = [];
  transformState: any[] = [];
  isAnimating = false;
  progress = 0;
  hoverInTimeout: any = null;
  hoverOutTimeout: any = null;

  constructor() {
    super({
      element: "[data-gallery]",
      elements: {
        inner: "[data-gallery-inner]",
      },
    });
    if (!this.element) return;
    this.elements.styles = document.querySelector("[data-styles]");
    this.elements.stylesDetails = document.querySelector("[data-styles-details]");
    this.elements.stylesDetailsMobile = document.querySelector("[data-styles-details-mobile]");
    this.elements.stylesDetailsTitleMobile = document.querySelector("[data-details-title-mobile]");
    this.elements.stylesDetailsDescMobile = document.querySelector("[data-details-desc-mobile]");

    this.createImages();
    this.addEventListeners();
    this.animate();
    this.createScrollAnim();
  }

  isDetailsActive() {
    return this.elements.stylesDetails?.classList.contains("active");
  }

  createScrollAnim() {
    const e = this.elements.styles;
    const n = this.elements.inner;
    const t = this.elements.stylesDetails;
    const i = this.elements.stylesDetailsTitleMobile;
    const r = this.elements.stylesDetailsDescMobile;
    if (!e || !n) return;

    const mm = gsap.matchMedia();
    mm.add(
      {
        isDesktop: `(min-width: ${Ol}px)`,
        isMobile: `(max-width: ${Ol - 1}px)`,
      },
      (ctx) => {
        const { isDesktop: h } = ctx.conditions as any;
        gsap
          .timeline({
            scrollTrigger: {
              trigger: e,
              start: "top top",
              end: "bottom top",
              pin: true,
              scrub: 1,
              onUpdate: (_) => {
                this.progress = _.progress;
                if (t) {
                  this.progress > 0.5 ? t.classList.add("active") : t.classList.remove("active");
                }
              },
            },
          })
          .fromTo(
            n,
            { ease: "none", y: h ? "-102vh" : "-50vh", scale: h ? 0.3 : 1.3 },
            { y: 0, scale: h ? 1 : 2 }
          );
      }
    );

    const u = { trigger: this.element, start: "top 90%" };
    gsap.from(
      n,
      {
        rotation: -90,
        ease: "none",
        scrollTrigger: { ...u, scrub: 1 },
        onUpdate: function (this: any) {
          const d = Math.round(gsap.getProperty(this.targets()[0], "rotation") as number);
          const h = Math.abs(Math.round(d / -15));
          const g = gsap.utils.mapRange(0, 6, 18, 24, h);
          const idx = Math.floor(g === 24 ? 0 : g);
          const w = galleryDeck[idx % galleryDeck.length];
          if (i && w) i.textContent = w.title;
          if (r && w) r.textContent = w.desc;
        },
      }
    );

    gsap.from(this.cards, {
      opacity: 0,
      duration: 1,
      delay: (d: number) => (Number(this.cards[d]?.dataset.delay) || 0) * 0.1,
      ease: "none",
      scrollTrigger: u,
    });
  }

  createImages() {
    const existing = this.elements.inner ? Array.from(this.elements.inner.querySelectorAll(".c-gallery__image")) as HTMLElement[] : [];
    if (existing.length === Ct.imageCount) {
      this.cards = existing;
      this.transformState = [];
      this.cards.forEach((cardEl, idx) => {
        cardEl.style.opacity = "1";
        this.transformState.push({
          currentRotation: 0,
          targetRotation: 0,
          currentX: 0,
          targetX: 0,
          currentY: 0,
          targetY: 0,
          currentScale: 1,
          targetScale: 1,
          angle: 0,
        });
        this.setupCardHover(cardEl, idx);
      });
    } else {
      this.elements.inner.innerHTML = "";
      this.cards = [];
      this.transformState = [];
      for (let i = 0; i < Ct.imageCount; i++) {
        this.createImageCard(i);
      }
    }
    this.positionAllCards();
  }

  setupCardHover(cardEl: HTMLElement, idx: number) {
    cardEl.addEventListener("mouseenter", () => {
      if (!this.isDetailsActive()) return;
      if (this.hoverInTimeout) {
        clearTimeout(this.hoverOutTimeout);
        clearTimeout(this.hoverInTimeout);
      }
      const item = galleryDeck[idx];
      const titleWrapper = this.elements.stylesDetails?.querySelector("[data-details-title]");
      const descWrapper = this.elements.stylesDetails?.querySelector("[data-details-desc]");
      const titleText = this.elements.stylesDetails?.querySelector("[data-details-title-text]");
      const descText = this.elements.stylesDetails?.querySelector("[data-details-desc-text]");

      titleWrapper?.classList.add("hidden");
      descWrapper?.classList.add("hidden");

      this.hoverInTimeout = setTimeout(() => {
        if (titleText) titleText.textContent = item.title;
        if (descText) descText.textContent = item.desc;
        descWrapper?.classList.remove("hidden");
        titleWrapper?.classList.remove("hidden");
      }, Ct.timeout);
    });

    cardEl.addEventListener("mouseleave", () => {
      if (!this.isDetailsActive()) return;
      const titleWrapper = this.elements.stylesDetails?.querySelector("[data-details-title]");
      const descWrapper = this.elements.stylesDetails?.querySelector("[data-details-desc]");
      const titleText = this.elements.stylesDetails?.querySelector("[data-details-title-text]");
      const descText = this.elements.stylesDetails?.querySelector("[data-details-desc-text]");

      titleWrapper?.classList.add("hidden");
      descWrapper?.classList.add("hidden");

      this.hoverOutTimeout = setTimeout(() => {
        if (descText) descText.textContent = "Hover to reveal more information";
        if (titleText) titleText.textContent = "";
        descWrapper?.classList.remove("hidden");
      }, Ct.timeout);
    });
  }

  createImageCard(idx: number) {
    const half = Ct.imageCount / 2;
    const i = idx % half;
    const cardEl = document.createElement("div");
    cardEl.className = "c-gallery__image";
    cardEl.dataset.index = String(idx);
    cardEl.dataset.delay = String(idx < half ? i : half - i);

    const img = document.createElement("img");
    img.loading = "lazy";
    img.src = galleryDeck[idx].image;
    img.alt = galleryDeck[idx].title;
    cardEl.appendChild(img);

    this.elements.inner.appendChild(cardEl);
    this.cards.push(cardEl);
    this.transformState.push({
      currentRotation: 0,
      targetRotation: 0,
      currentX: 0,
      targetX: 0,
      currentY: 0,
      targetY: 0,
      currentScale: 1,
      targetScale: 1,
      angle: 0,
    });

    this.setupCardHover(cardEl, idx);
  }

  positionImageCard(el: HTMLElement, idx: number) {
    const angle = (idx / Ct.imageCount) * Math.PI * 2;
    Ct.radius = window.innerWidth * 0.7;
    const x = Ct.radius * Math.cos(angle);
    const y = Ct.radius * Math.sin(angle);
    gsap.set(el, {
      x,
      y,
      rotation: (angle * 180) / Math.PI + 90,
      transformPerspective: 800,
      transformOrigin: "center center",
    });
    if (this.transformState[idx]) {
      this.transformState[idx].angle = angle;
    }
  }

  positionAllCards() {
    this.cards.forEach((el, idx) => {
      this.positionImageCard(el, idx);
    });
  }

  addEventListeners() {
    document.addEventListener("mousemove", (e) => {
      if (Ct.isMobile || this.isAnimating) return;
      const halfW = window.innerWidth / 2;
      const halfH = window.innerHeight / 2;
      const normX = (e.clientX - halfW) / halfW;
      const normY = (e.clientY - halfH) / halfH;

      this.parallaxState.targetY = normX * 10;
      this.parallaxState.targetX = -normY * 10;
      this.parallaxState.targetZ = (normX + normY) * 4;

      this.cards.forEach((card, idx) => {
        const rect = card.getBoundingClientRect();
        const diffX = e.clientX - (rect.left + rect.width / 2);
        const diffY = e.clientY - (rect.top + rect.height / 2);
        const dist = Math.sqrt(diffX * diffX + diffY * diffY);

        if (dist < Ct.sensitivity && !Ct.isMobile) {
          const w = Math.max(0, 1 - dist / Ct.effectFalloff);
          const p = this.transformState[idx].angle;
          const amt = Ct.cardMoveAmount * w;
          this.transformState[idx].targetRotation = 180 * w;
          this.transformState[idx].targetScale = 1 + 0.15 * w;
          this.transformState[idx].targetX = amt * Math.cos(p);
          this.transformState[idx].targetY = amt * Math.sin(p);
        } else {
          this.transformState[idx].targetRotation = 0;
          this.transformState[idx].targetScale = 1;
          this.transformState[idx].targetX = 0;
          this.transformState[idx].targetY = 0;
        }
      });
    });

    document.addEventListener("mouseout", (e: MouseEvent) => {
      const rel = e.relatedTarget as HTMLElement | null;
      if ((rel === null || rel.nodeName === "HTML") && !Ct.isMobile && !this.isAnimating) {
        this.transformState.forEach((n) => {
          n.targetRotation = 0;
          n.targetScale = 1;
          n.targetX = 0;
          n.targetY = 0;
        });
        this.parallaxState.targetX = 0;
        this.parallaxState.targetY = 0;
        this.parallaxState.targetZ = 0;
      }
    });

    windowWatcher.onWidthChange(() => {
      this.positionAllCards();
    });
  }

  animate() {
    if (!Ct.isMobile && !this.isAnimating) {
      this.parallaxState.currentX += (this.parallaxState.targetX - this.parallaxState.currentX) * Ct.lerpFactor;
      this.parallaxState.currentY += (this.parallaxState.targetY - this.parallaxState.currentY) * Ct.lerpFactor;
      this.parallaxState.currentZ += (this.parallaxState.targetZ - this.parallaxState.currentZ) * Ct.lerpFactor;

      gsap.set(this.element, {
        rotateX: this.parallaxState.currentX,
        rotateY: this.parallaxState.currentY,
        rotation: this.parallaxState.currentZ,
        transformOrigin: "center center",
      });

      this.cards.forEach((card, idx) => {
        const t = this.transformState[idx];
        if (!t) return;
        t.currentRotation += (t.targetRotation - t.currentRotation) * Ct.lerpFactor;
        t.currentScale += (t.targetScale - t.currentScale) * Ct.lerpFactor;
        t.currentX += (t.targetX - t.currentX) * Ct.lerpFactor;
        t.currentY += (t.targetY - t.currentY) * Ct.lerpFactor;

        const i = t.angle;
        const r = Ct.radius * Math.cos(i);
        const o = Ct.radius * Math.sin(i);
        const u = gsap.utils.mapRange(0, 0.5, t.currentRotation, 0, this.progress);

        gsap.set(card, {
          x: r + t.currentX,
          y: o + t.currentY,
          rotationY: Math.max(0, u),
          scale: t.currentScale,
          rotation: (i * 180) / Math.PI + 90,
          transformOrigin: "center center",
          transformPerspective: 3000,
        });
      });
    }
    requestAnimationFrame(this.animate.bind(this));
  }
}

// 7. Features Cards (Pm)
export class FeaturesAnimation extends BaseComponent {
  hasEnhanced = false;
  inViewClasses = "in-view";

  constructor() {
    super({
      element: "[data-features]",
      elements: {
        cards: "[data-card]",
        createCard: "[data-card='create']",
        enhanceCard: "[data-card='enhance']",
        baseTextsCon: "[data-base-texts]",
        enhancedTextsCon: "[data-enhanced-texts]",
        mainTexts: "[data-flip-id]:not(.enhanced)",
        enhancedTexts: "[data-flip-id].enhanced",
        rightItem: "[data-card='create'] [data-item='right']",
        bottomCon: "[data-bottom-con]",
        topCon: "[data-top-con]",
      },
    });
    if (!this.element) return;
    this.observeCards();
    this.setHeight();
    this.addEventListeners();
  }

  get isMobile(): boolean {
    return typeof window !== "undefined" && window.matchMedia(`(max-width: ${Ol}px)`).matches;
  }

  setHeight() {
    const e = this.elements.baseTextsCon as HTMLElement;
    const n = this.elements.enhancedTextsCon as HTMLElement;
    const t = this.elements.bottomCon as HTMLElement;
    if (!t) return;
    if (this.hasEnhanced && n) {
      t.style.height = `${n.clientHeight}px`;
      t.style.transition = "height 0.3s 0s ease";
    } else if (e) {
      t.style.height = `${e.clientHeight}px`;
      t.style.transition = "height 0.2s 0.2s ease";
    }
  }

  observeCards() {
    const cards = (
      Array.isArray(this.elements.cards)
        ? this.elements.cards
        : [this.elements.cards]
    ).filter(Boolean) as HTMLElement[];
    cards.forEach((c) => {
      const th = Number(c.dataset.threshold) || 0;
      this.observeCard(c, th);
    });
  }

  observeCard(card: HTMLElement, threshold: number) {
    const obs = new IntersectionObserver(
      (entries) => {
        entries.forEach((r) => {
          if (r.isIntersecting) {
            r.target.classList.add(this.inViewClasses);
            if (this.isMobile && (r.target as HTMLElement).dataset.card === "enhance") {
              this.flipTexts();
            }
            obs.disconnect();
          }
        });
      },
      { threshold }
    );
    obs.observe(card);
  }

  async flipTexts() {
    await gsap.delayedCall(this.isMobile || this.hasEnhanced ? 0.1 : 0.2, () => {});
    const e = (
      Array.isArray(this.elements.mainTexts)
        ? this.elements.mainTexts
        : [this.elements.mainTexts]
    ).filter(Boolean) as HTMLElement[];
    const n = (
      Array.isArray(this.elements.enhancedTexts)
        ? this.elements.enhancedTexts
        : [this.elements.enhancedTexts]
    ).filter(Boolean) as HTMLElement[];
    const t = this.elements.baseTextsCon as HTMLElement;
    const i = this.elements.enhancedTextsCon as HTMLElement;
    const r = this.elements.topCon as HTMLElement;

    e.forEach((o) => {
      const u = n.find((d) => d.dataset.flipId === o.dataset.flipId);
      if (u) {
        let state: any;
        if (this.hasEnhanced) {
          state = Flip.getState([u, o]);
        } else {
          state = Flip.getState([o, u]);
        }
        o.classList.toggle("inactive");
        u.classList.toggle("inactive");
        Flip.from(state, { duration: 0.5, ease: "power1.inOut" });
      }
    });

    this.hasEnhanced = !this.hasEnhanced;
    t?.classList.toggle("active");
    i?.classList.toggle("active");
    r?.classList.toggle("active");
    this.setHeight();
  }

  addEventListeners() {
    const e = this.elements.rightItem as HTMLElement;
    const n = this.elements.createCard as HTMLElement;
    const t = this.elements.enhanceCard as HTMLElement;

    if (e && n) {
      e.addEventListener("transitionend", () => {
        n.classList.add("done");
      });
    }
    if (t) {
      t.addEventListener("mouseenter", () => {
        if (!this.isMobile) this.flipTexts();
      });
      t.addEventListener("mouseleave", () => {
        if (!this.isMobile) this.flipTexts();
      });
    }
    windowWatcher.onWidthChange(() => {
      this.setHeight();
    });
  }
}

// 9. FAQ Mouse Trail Animation (Mm)
export const Gn = {
  imageCount: 35,
  imageLifespan: 750,
  removalDelay: 50,
  mouseThreshold: 35,
  scrollThreshold: 50,
  inDuration: 750,
  outDuration: 1000,
  inEasing: "cubic-bezier(.07,.5,.5,1)",
  outEasing: "cubic-bezier(.87, 0, .13, 1)",
};

export class FaqAnimation extends BaseComponent {
  images: string[] = [];
  trail: Array<{ element: HTMLElement; rotation: number; removeTime: number }> = [];
  mouse = { x: 0, y: 0, lastX: 0, lastY: 0 };
  moveTimeout: any = null;
  scrollTimeout: any = null;
  checks = {
    isMouseMoving: false,
    isCursorInContainer: 0,
    lastRemovalTime: 0,
    lastSteadyImageTime: 0,
    lastScrollTime: 0,
    isScrolling: false,
    scrollTicking: false,
  };

  constructor() {
    super({
      element: "[data-faq]",
      elements: {
        trailContainer: "[data-trail]",
      },
    });
    if (!this.element) return;
    const e = 7;
    this.images = Array.from({ length: Gn.imageCount }, (_, t) => `/images/faq/${(t % e) + 1}.svg`);
    this.trail = [];
    this.addEventListeners();
    this.animate();
  }

  isInContainer(x: number, y: number): boolean {
    const t = this.elements.trailContainer as HTMLElement;
    if (!t) return false;
    const rect = t.getBoundingClientRect();
    return x >= rect.left && x <= rect.right && y >= rect.top && y <= rect.bottom;
  }

  setInitialMousePos(e: MouseEvent) {
    this.mouse.x = e.clientX;
    this.mouse.y = e.clientY;
    this.mouse.lastX = this.mouse.x;
    this.mouse.lastY = this.mouse.y;
    this.checks.isCursorInContainer = this.isInContainer(this.mouse.x, this.mouse.y) ? 1 : 0;
    document.removeEventListener("mouseover", this.setInitialMousePos as any, false);
  }

  hasMovedEnough(): boolean {
    return (
      Math.sqrt(
        Math.pow(this.mouse.x - this.mouse.lastX, 2) + Math.pow(this.mouse.y - this.mouse.lastY, 2)
      ) > Gn.mouseThreshold
    );
  }

  createTrailImage() {
    if (this.checks.isCursorInContainer && this.checks.isMouseMoving && this.hasMovedEnough()) {
      this.mouse.lastX = this.mouse.x;
      this.mouse.lastY = this.mouse.y;
      this.createImage();
    }
  }

  createImage() {
    const t = this.elements.trailContainer as HTMLElement;
    if (!t) return;
    const e = document.createElement("img");
    e.classList.add("c-faq__trail__img");
    const n = Math.floor(Math.random() * this.images.length);
    const rot = (Math.random() - 0.5) * 50;
    e.src = this.images[n];
    const i = t.getBoundingClientRect();
    const r = this.mouse.x - i.left;
    const o = this.mouse.y - i.top;
    e.style.left = `${r}px`;
    e.style.top = `${o}px`;
    e.style.transform = `translate(-50%, -50%) rotate(${rot}deg) scale(0)`;
    e.style.transition = `transform ${Gn.inDuration}ms ${Gn.inEasing}`;
    t.appendChild(e);

    setTimeout(() => {
      e.style.transform = `translate(-50%, -50%) rotate(${rot}deg) scale(1)`;
    }, 10);

    this.trail.push({ element: e, rotation: rot, removeTime: Date.now() + Gn.imageLifespan });
  }

  createScrollTrailImage() {
    if (this.checks.isCursorInContainer) {
      this.mouse.lastX += (Gn.mouseThreshold + 10) * (Math.random() > 0.5 ? 1 : -1);
      this.mouse.lastY += (Gn.mouseThreshold + 10) * (Math.random() > 0.5 ? 1 : -1);
      this.createImage();
      this.mouse.lastX = this.mouse.x;
      this.mouse.lastY = this.mouse.y;
    }
  }

  removeOldImages() {
    const e = Date.now();
    if (e - this.checks.lastRemovalTime < Gn.removalDelay || this.trail.length === 0) return;
    const n = this.trail[0];
    if (e >= n.removeTime) {
      const t = this.trail.shift();
      if (!t) return;
      t.element.style.transition = `transform ${Gn.outDuration}ms ${Gn.outEasing}`;
      t.element.style.transform = `translate(-50%, -50%) rotate(${t.rotation}deg) scale(0)`;
      this.checks.lastRemovalTime = e;
      setTimeout(() => {
        t.element.parentNode && t.element.parentNode.removeChild(t.element);
      }, Gn.outDuration);
    }
  }

  addEventListeners() {
    document.addEventListener("mouseover", this.setInitialMousePos.bind(this) as any, false);
    document.addEventListener("mousemove", (e: MouseEvent) => {
      this.mouse.x = e.clientX;
      this.mouse.y = e.clientY;
      this.checks.isCursorInContainer = this.isInContainer(this.mouse.x, this.mouse.y) ? 1 : 0;
      if (this.checks.isCursorInContainer) {
        this.checks.isMouseMoving = true;
        clearTimeout(this.moveTimeout);
        this.moveTimeout = setTimeout(() => {
          this.checks.isMouseMoving = false;
        }, 100);
      }
    });

    window.addEventListener(
      "scroll",
      () => {
        this.checks.isCursorInContainer = this.isInContainer(this.mouse.x, this.mouse.y) ? 1 : 0;
        if (this.checks.isCursorInContainer) {
          this.checks.isMouseMoving = true;
          this.mouse.lastX += (Math.random() - 0.5) * 10;
          clearTimeout(this.scrollTimeout);
          this.scrollTimeout = setTimeout(() => {
            this.checks.isMouseMoving = false;
          }, 100);
        }
      },
      { passive: true }
    );

    window.addEventListener(
      "scroll",
      () => {
        const e = Date.now();
        this.checks.isScrolling = true;
        if (!(e - this.checks.lastScrollTime < Gn.scrollThreshold)) {
          this.checks.lastScrollTime = e;
          if (!this.checks.scrollTicking) {
            requestAnimationFrame(() => {
              if (this.checks.isScrolling) {
                this.createScrollTrailImage();
                this.checks.isScrolling = false;
              }
              this.checks.scrollTicking = false;
            });
            this.checks.scrollTicking = true;
          }
        }
      },
      { passive: true }
    );
  }

  animate() {
    this.createTrailImage();
    this.removeOldImages();
    requestAnimationFrame(this.animate.bind(this));
  }
}

// 10. Nav Scroll and Drawer Animation (Im)
function toggleNavMenu(
  e: Event,
  toggleSel: string,
  menuEl: HTMLElement,
  navSel: string,
  activeClass: string,
  closeFn: () => void
) {
  e.stopPropagation();
  if (e.target instanceof HTMLElement && e.target.closest(toggleSel)) {
    menuEl.classList.toggle(activeClass);
  } else if (e.target instanceof HTMLElement && !e.target.closest(navSel)) {
    closeFn();
  }
  if (menuEl.classList.contains(activeClass)) {
    document.addEventListener("click", (o: Event) =>
      toggleNavMenu(o, toggleSel, menuEl, navSel, activeClass, closeFn)
    );
  } else {
    document.removeEventListener("click", (o: Event) =>
      toggleNavMenu(o, toggleSel, menuEl, navSel, activeClass, closeFn)
    );
  }
}

export class NavAnimation extends BaseComponent {
  lenis: Lenis | null = null;
  hiddenClass = "hidden";
  activeClass = "active";

  constructor(lenis: Lenis | null) {
    super({
      element: "[data-nav]",
      elements: {
        toggle: "[data-nav-toggle]",
      },
    });
    if (!this.element) return;
    this.lenis = lenis;
    this.elements.container = document.querySelector("[data-nav-container]") as HTMLElement | null;
    (this.elements.container as HTMLElement)?.classList.remove(this.hiddenClass);
    this.addEventListeners();
  }

  addEventListeners() {
    if (this.lenis) {
      this.lenis.on("scroll", (e: any) => {
        const scr = this.lenis!.scroll;
        const container = this.elements.container as HTMLElement;
        const isMenuOpen = this.element?.classList.contains(this.activeClass);
        if (isMenuOpen) {
          container?.classList.remove(this.hiddenClass);
          return;
        }
        if (e.direction === 1 && scr > 100) {
          container?.classList.add(this.hiddenClass);
        } else {
          container?.classList.remove(this.hiddenClass);
        }
      });
    }
  }
}

// 11. Footer Animation (CTA + Lime Footer)
export class FooterAnimation extends BaseComponent {
  constructor() {
    super({
      element: "#footer",
      elements: {
        cta: "#cta",
        fLogo: ".f-logo",
      },
    });
    this.initCta();
    this.initFooterLogo();
  }

  initCta() {
    const ctaSection = document.getElementById("cta");
    if (!ctaSection) return;

    // 1. Grid sq-field
    const sqField = ctaSection.querySelector(".sq-field");
    if (sqField && sqField.children.length === 0) {
      const count = parseInt(sqField.getAttribute("data-count") || "16", 10);
      for (let i = 0; i < count; i++) {
        const col = Math.floor(Math.random() * 30);
        const row = Math.floor(Math.random() * 6);
        const sq = document.createElement("div");
        sq.className = "grid-sq";
        sq.style.width = "46px";
        sq.style.height = "46px";
        sq.style.left = (col * 48 - 10) + "px";
        sq.style.top = (row * 48 + 6) + "px";
        sqField.appendChild(sq);

        gsap.to(sq, {
          opacity: 1,
          duration: 1.2,
          yoyo: true,
          repeat: -1,
          ease: "sine.inOut",
          delay: Math.random() * 4,
          repeatDelay: Math.random() * 3,
        });
      }
    }

    // 2. Petals generator
    const petalsContainer = document.getElementById("petals");
    if (petalsContainer && petalsContainer.children.length === 0) {
      for (let i = 0; i < 18; i++) {
        const petal = document.createElement("span");
        petal.className = "petal";
        const left = Math.random() * 100;
        const dx = -80 + Math.random() * 160;
        const dur = 9 + Math.random() * 9;
        const del = -(Math.random() * 15);
        const scale = 0.6 + Math.random() * 0.8;
        petal.style.left = left + "%";
        petal.style.setProperty("--dx", dx + "px");
        petal.style.animationDuration = dur + "s";
        petal.style.animationDelay = del + "s";
        petal.style.transform = "scale(" + scale + ")";
        petalsContainer.appendChild(petal);
      }
    }

    // 3. CTA image parallax
    const ctaImg = document.getElementById("ctaImg");
    if (ctaImg) {
      gsap.fromTo(
        ctaImg,
        { yPercent: -12 },
        {
          yPercent: 0,
          ease: "none",
          scrollTrigger: {
            trigger: ctaSection,
            start: "top bottom",
            end: "bottom bottom",
            scrub: true,
          },
        }
      );
    }

    // 4. CTA Card animation
    const ctaCard = document.getElementById("ctaCard");
    if (ctaCard) {
      const splitEl = ctaCard.querySelector(".split") as HTMLElement | null;
      if (splitEl) splitTextWords(splitEl);

      gsap.fromTo(
        ctaCard,
        { y: 80, scale: 0.94, opacity: 0, filter: "blur(10px)" },
        {
          y: 0,
          scale: 1,
          opacity: 1,
          filter: "blur(0px)",
          duration: 1.2,
          ease: "power3.out",
          scrollTrigger: {
            trigger: ctaSection,
            start: "top 60%",
          },
        }
      );
    }
  }

  initFooterLogo() {
    const footerEl = document.getElementById("footer");
    if (!footerEl) return;

    const fRing = footerEl.querySelector("#fRing");
    const fMark = footerEl.querySelector("#fMark");
    const fDots = footerEl.querySelectorAll(".fdot");

    if (!fRing || !fMark || fDots.length < 3) return;

    const tl = gsap.timeline({
      scrollTrigger: {
        trigger: footerEl,
        start: "top 92%",
        toggleActions: "play none none none",
      },
    });

    // dots bounce y -8 (.25s, stagger .08, yoyo, repeat 3, sine.inOut)
    tl.to(fDots, {
      y: -8,
      duration: 0.25,
      stagger: 0.08,
      yoyo: true,
      repeat: 3,
      ease: "sine.inOut",
    })
      // all dots move to cx 27 cy 50 (.45s power3.inOut)
      .to(fDots, {
        attr: { cx: 27, cy: 50 },
        duration: 0.45,
        ease: "power3.inOut",
      })
      // dots 2 and 3 fade out (.1s)
      .to([fDots[1], fDots[2]], {
        opacity: 0,
        duration: 0.1,
      })
      // #fMark strokeDashoffset 0 (.6s power3.out, "-=.05") with dot 1 r -> 5.5 (back.out(3), "<")
      .to(
        fMark,
        {
          strokeDashoffset: 0,
          duration: 0.6,
          ease: "power3.out",
        },
        "-=0.05"
      )
      .to(
        fDots[0],
        {
          attr: { r: 5.5 },
          duration: 0.6,
          ease: "back.out(3)",
        },
        "<"
      )
      // #fRing strokeDashoffset 0 (.9s power2.inOut, "-=.3")
      .to(
        fRing,
        {
          strokeDashoffset: 0,
          duration: 0.9,
          ease: "power2.inOut",
        },
        "-=0.3"
      );
  }
}

// Master init function
export function initAllAnimations(): Lenis | undefined {
  if (typeof window === "undefined") return;

  // Initialize Lenis smooth scroll
  let lenis: Lenis | undefined;
  try {
    lenis = new Lenis({
      lerp: 0.1,
      smoothWheel: true,
      touchMultiplier: 2,
    });

    lenis.on("scroll", ScrollTrigger.update);
    gsap.ticker.add((time: number) => {
      lenis?.raf(time * 1000);
    });
    gsap.ticker.lagSmoothing(0);
  } catch (err) {
    console.warn("Lenis init notice:", err);
  }

  // Safe executor so any section issue never halts the others
  const safeInit = (name: string, fn: () => void) => {
    try {
      fn();
    } catch (e) {
      console.warn(`Init animation warning for ${name}:`, e);
    }
  };

  safeInit("Hero", () => new HeroAnimation());
  safeInit("How", () => new HowAnimation());
  safeInit("Mockup", () => new MockupAnimation());
  safeInit("OneClick", () => new OneClickAnimation());
  safeInit("Clm", () => new ClmAnimation());
  safeInit("Gallery", () => new GalleryAnimation());
  safeInit("Features", () => new FeaturesAnimation());
  safeInit("Nav", () => new NavAnimation(lenis || null));
  safeInit("Footer", () => new FooterAnimation());
  safeInit("Faq", () => new FaqAnimation());

  // Refresh ScrollTrigger after render settles
  setTimeout(() => {
    ScrollTrigger.refresh();
  }, 350);

  return lenis;
}
