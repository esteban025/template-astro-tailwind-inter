import { links, indicator } from "./Navbar.astro.0.mts";

export const updateIndicator = () => {
  const index = Array.from(links).indexOf(event.target);
  indicator.style.transform = `translateX(${index * 100}%)`;
};
