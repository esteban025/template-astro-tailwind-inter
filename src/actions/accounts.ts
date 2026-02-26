import { db } from "@/lib/db";
import { defineAction } from "astro:actions";
import { z } from "astro:schema";

export const getAccounts = defineAction({
  async handler() {
    const query = `SELECT * FROM trading_accounts ORDER BY broker_name`;
    const [res] = await db.query(query);
    const data = res as any[];

    return {
      success: true,
      message: "Accounts retrieved successfully",
      data,
    };
  },
});

export const getAccountById = defineAction({
  input: z.object({
    id: z.coerce.string(),
  }),
  async handler({ id }) {
    const query = `SELECT * FROM trading_accounts WHERE id = ?`;
    const [res] = await db.query(query, [id]);
    const data = res as any[];

    if (data.length === 0) {
      return {
        success: false,
        message: "Account not found",
      };
    }
    return {
      success: true,
      message: "Account retrieved successfully",
      data: data[0],
    };
  },
});

export const createAccount = defineAction({
  input: z.object({
    broker_name: z.string().min(1, "El nombre del broker es requerido"),
    account_number: z.string().optional(),
    initial_balance: z.coerce.number().default(0),
  }),
  async handler({ broker_name, account_number, initial_balance }) {
    const query = `INSERT INTO trading_accounts (broker_name, account_number, initial_balance) VALUES (?, ?, ?)`;
    const [result] = await db.query(query, [
      broker_name,
      account_number || null,
      initial_balance,
    ]);
    const insertId = (result as any).insertId;

    return {
      success: true,
      message: "Account created successfully",
      data: { id: insertId },
    };
  },
});
