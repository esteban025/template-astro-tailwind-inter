import { useState } from "react";

export const Navbar = () => {
  const [active, setActive] = useState(0);
  const items = [
    { name: "Gastos", href: "/" },
    { name: "Trading", href: "/trading" },
  ];

  // por ahora el ancho del indicator sera ingresado manualmente
  const width = "w-[calc(100%/2-2px)]";

  return (
    <nav className="flex items-center justify-center mt-6">
      <ul className="relative flex bg-neutral-700 p-0.5 rounded-full w-fit shadow-[0_0_20px_0_rgba(255,255,255,0.1)] border-2 border-neutral-900">
        {
          items.map((item, index) => (
            <li className={`relative z-10 bg-transparent`} key={item.name}>
              <a
                className={`p-2 px-5 block link-nav transition-colors duration-300 ${active === index ? "active" : ""}`}
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
          className={`absolute top-0.5 left-0.5 bottom-0.5 rounded-full bg-violet-600 border border-purple-800 ${width}`}
          style={{ transform: `translateX(${active * 100}%)` }}
        >
        </li>
      </ul>
    </nav>
  )
}