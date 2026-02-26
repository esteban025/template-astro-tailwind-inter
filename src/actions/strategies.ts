import { db } from "@/lib/db";
import { defineAction } from "astro:actions";
import { z } from "astro:schema";

export const getStrategies = defineAction({
  async handler() {
    const query = `SELECT * FROM trading_strategies ORDER BY name`;
    const [res] = await db.query(query);
    const data = res as any[];

    return {
      success: true,
      message: "Strategies retrieved successfully",
      data,
    };
  },
});

export const getStrategyById = defineAction({
  input: z.object({
    id: z.coerce.string(),
  }),
  async handler({ id }) {
    const query = `SELECT * FROM trading_strategies WHERE id = ?`;
    const [res] = await db.query(query, [id]);
    const data = res as any[];

    if (data.length === 0) {
      return {
        success: false,
        message: "Strategy not found",
      };
    }
    return {
      success: true,
      message: "Strategy retrieved successfully",
      data: data[0],
    };
  },
});

export const createStrategy = defineAction({
  input: z.object({
    name: z.string().min(1, "El nombre es requerido"),
    description: z.string().optional(),
  }),
  async handler({ name, description }) {
    const query = `INSERT INTO trading_strategies (name, description) VALUES (?, ?)`;
    const [result] = await db.query(query, [name, description || null]);
    const insertId = (result as any).insertId;

    return {
      success: true,
      message: "Strategy created successfully",
      data: { id: insertId },
    };
  },
});
