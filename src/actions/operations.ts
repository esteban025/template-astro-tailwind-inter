import { db } from "@/lib/db";
import { defineAction } from "astro:actions";
import { z } from "astro:schema";

export const createOperation = defineAction({
  input: z.object({
    instrument_id: z.coerce.number(),
    account_id: z.coerce.number().optional(),
    strategy_id: z.coerce.number().optional(),
    direction: z.enum(["buy", "sell"]),
    entry_price: z.coerce.number(),
    stop_loss: z.coerce.number().optional(),
    take_profit: z.coerce.number().optional(),
    position_size: z.coerce.number(),
    commission: z.coerce.number().default(0),
    entry_date: z.string(),
    notes: z.string().optional(),
  }),
  async handler(data) {
    const query = `
      INSERT INTO trading_operations (
        instrument_id, account_id, strategy_id, direction,
        entry_price, stop_loss, take_profit, position_size,
        commission, entry_date, notes, status
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'open')
    `;

    const [result] = await db.query(query, [
      data.instrument_id,
      data.account_id || null,
      data.strategy_id || null,
      data.direction,
      data.entry_price,
      data.stop_loss || null,
      data.take_profit || null,
      data.position_size,
      data.commission,
      data.entry_date,
      data.notes || null,
    ]);

    const insertId = (result as any).insertId;

    return {
      success: true,
      message: "Operación registrada exitosamente",
      data: { id: insertId },
    };
  },
});

export const getActiveOperations = defineAction({
  async handler() {
    const query = `
      SELECT o.*, i.symbol, i.name as instrument_name
      FROM trading_operations o
      JOIN trading_instruments i ON o.instrument_id = i.id
      WHERE o.status = 'open'
      ORDER BY o.entry_date DESC
    `;
    const [res] = await db.query(query);
    const data = res as any[];

    return {
      success: true,
      message: "Active operations retrieved successfully",
      data,
    };
  },
});

export const getClosedOperations = defineAction({
  input: z.object({
    limit: z.coerce.number().default(50),
  }),
  async handler({ limit }) {
    const query = `
      SELECT o.*, i.symbol, i.name as instrument_name
      FROM trading_operations o
      JOIN trading_instruments i ON o.instrument_id = i.id
      WHERE o.status = 'closed'
      ORDER BY o.exit_date DESC
      LIMIT ?
    `;
    const [res] = await db.query(query, [limit]);
    const data = res as any[];

    return {
      success: true,
      message: "Closed operations retrieved successfully",
      data,
    };
  },
});

export const closeOperation = defineAction({
  input: z.object({
    id: z.coerce.number(),
    exit_price: z.coerce.number(),
    exit_date: z.string(),
    profit_loss: z.coerce.number(),
    swap: z.coerce.number().default(0),
  }),
  async handler({ id, exit_price, exit_date, profit_loss, swap }) {
    const query = `
      UPDATE trading_operations
      SET exit_price = ?, exit_date = ?, profit_loss = ?, swap = ?, status = 'closed'
      WHERE id = ?
    `;

    await db.query(query, [exit_price, exit_date, profit_loss, swap, id]);

    return {
      success: true,
      message: "Operación cerrada exitosamente",
    };
  },
});

export const getOperationsStats = defineAction({
  async handler() {
    const query = `
      SELECT 
        COUNT(*) as total_operations,
        SUM(CASE WHEN profit_loss > 0 THEN 1 ELSE 0 END) as total_wins,
        SUM(CASE WHEN profit_loss <= 0 THEN 1 ELSE 0 END) as total_losses,
        ROUND(SUM(CASE WHEN profit_loss > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as win_rate,
        COALESCE(SUM(profit_loss), 0) as total_pnl
      FROM trading_operations
      WHERE status = 'closed'
    `;

    const [rows] = await db.query(query);
    const stats = (rows as any[])[0];

    const [activeRows] = await db.query(
      "SELECT COUNT(*) as active FROM trading_operations WHERE status = 'open'"
    );
    const active = (activeRows as any[])[0];

    return {
      success: true,
      message: "Statistics retrieved successfully",
      data: {
        total_operations: parseInt(stats.total_operations) || 0,
        total_wins: parseInt(stats.total_wins) || 0,
        total_losses: parseInt(stats.total_losses) || 0,
        win_rate: parseFloat(stats.win_rate) || 0,
        total_pnl: parseFloat(stats.total_pnl) || 0,
        active_operations: parseInt(active.active) || 0,
      },
    };
  },
});
