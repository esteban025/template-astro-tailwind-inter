import { db } from "@/lib/db";
import { defineAction } from "astro:actions";
import { z } from "astro:schema";

export const getInstruments = defineAction({
  async handler() {
    const query = `SELECT * FROM trading_instruments ORDER BY symbol`;
    const [res] = await db.query(query);
    const data = res as any[];

    return {
      success: true,
      message: "Instruments retrieved successfully",
      data,
    }
  }
})

// este es un ejemplo para cuando queramos obtener un instrumento por su id
export const getInstrumentById = defineAction({
  input: z.object({
    id: z.coerce.string(),
  }),
  async handler({ id }) {
    const query = `SELECT * FROM instruments WHERE id = ?`;
    const [res] = await db.query(query, [id]);
    const data = res as any[];

    if (data.length === 0) {
      return {
        success: false,
        message: "Instrument not found",
      }
    }
    return {
      success: true,
      message: "Instrument retrieved successfully",
      data: data[0],
    }
  }
})
