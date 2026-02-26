import { useState } from "react";

export const Navbar = () => {
  const [active, setActive] = useState(0);
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);

  const items = [
    { name: "Gastos", href: "/" },
    { name: "Trading", href: "/trading" },
  ];

  // Ancho del indicator calculado automáticamente
  const width = "w-[calc(100%/2-4px)]";

  return (
    <nav className="flex items-center justify-center mt-6">
      <ul className="nav-container relative flex p-1 w-fit">
        {
          items.map((item, index) => (
            <li
              className="relative z-10 bg-transparent"
              key={item.name}
              onMouseEnter={() => setHoveredIndex(index)}
              onMouseLeave={() => setHoveredIndex(null)}
            >
              <a
                className={`link-nav ${active === index ? "active" : ""
                  } ${hoveredIndex === index && active !== index ? "hovered" : ""
                  }`}
                href={item.href}
                onClick={() => setActive(index)}
              >
                {item.name}
              </a>
            </li>
          ))
        }
        <li
          id="indicator-nav"
          className={`indicator ${width}`}
          style={{ transform: `translateX(${active * 100}%)` }}
        >
        </li>
      </ul>
    </nav>
  )
}