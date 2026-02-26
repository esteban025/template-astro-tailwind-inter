# Finance Register

Plataforma personal para llevar un registro local de finanzas e ingresos, y operaciones de trading. Sin autenticación ni usuarios — diseñada para uso individual. Todo en **USD**.

**Stack**: Astro 5 + React 19 + Tailwind CSS 4 + MySQL

---

## Esquema de Base de Datos MySQL

### Módulo 1 — Finanzas Personales

#### `finance_categories`

Categorías de gastos e ingresos (ej: Alimentación, Transporte, Salario, Freelance).

| Columna      | Tipo                          | Notas                    |
| ------------ | ----------------------------- | ------------------------ |
| `id`         | INT, PK, AUTO_INCREMENT       |                          |
| `name`       | VARCHAR(100), NOT NULL        |                          |
| `type`       | ENUM('expense', 'income')     | Tipo de categoría        |
| `icon`       | VARCHAR(50), NULL             | Opcional, para la UI     |
| `created_at` | TIMESTAMP, DEFAULT NOW()      |                          |

#### `finance_payment_methods`

Métodos de pago (ej: Efectivo, Tarjeta débito, Tarjeta crédito, Transferencia).

| Columna      | Tipo                          | Notas |
| ------------ | ----------------------------- | ----- |
| `id`         | INT, PK, AUTO_INCREMENT       |       |
| `name`       | VARCHAR(100), NOT NULL        |       |
| `created_at` | TIMESTAMP, DEFAULT NOW()      |       |

#### `finance_accounts`

Cuentas o billeteras donde se lleva el balance (ej: Banco X, Efectivo en casa, PayPal).

| Columna           | Tipo                          | Notas              |
| ----------------- | ----------------------------- | ------------------- |
| `id`              | INT, PK, AUTO_INCREMENT       |                     |
| `name`            | VARCHAR(100), NOT NULL        |                     |
| `initial_balance` | DECIMAL(12,2), DEFAULT 0      | Balance inicial USD |
| `created_at`      | TIMESTAMP, DEFAULT NOW()      |                     |

#### `finance_transactions`

Registro principal de gastos e ingresos.

| Columna              | Tipo                                                            | Notas                               |
| -------------------- | --------------------------------------------------------------- | ----------------------------------- |
| `id`                 | INT, PK, AUTO_INCREMENT                                         |                                     |
| `type`               | ENUM('expense', 'income'), NOT NULL                             |                                     |
| `amount`             | DECIMAL(12,2), NOT NULL                                         | Monto en USD                        |
| `description`        | TEXT, NULL                                                      |                                     |
| `date`               | DATE, NOT NULL                                                  | Fecha de la transacción             |
| `category_id`        | INT, FK → `finance_categories`                                  |                                     |
| `payment_method_id`  | INT, FK → `finance_payment_methods`, NULL                       |                                     |
| `account_id`         | INT, FK → `finance_accounts`, NULL                              |                                     |
| `is_recurring`       | BOOLEAN, DEFAULT FALSE                                          |                                     |
| `recurring_period`   | ENUM('daily','weekly','biweekly','monthly','yearly'), NULL       | Solo si `is_recurring` = true       |
| `created_at`         | TIMESTAMP, DEFAULT NOW()                                        |                                     |
| `updated_at`         | TIMESTAMP, DEFAULT NOW() ON UPDATE                              |                                     |

#### `finance_tags`

Etiquetas libres para clasificación flexible.

| Columna      | Tipo                          | Notas               |
| ------------ | ----------------------------- | -------------------- |
| `id`         | INT, PK, AUTO_INCREMENT       |                      |
| `name`       | VARCHAR(50), NOT NULL         |                      |
| `color`      | VARCHAR(7), NULL              | Color hex (ej: #FF0) |
| `created_at` | TIMESTAMP, DEFAULT NOW()      |                      |

#### `finance_transaction_tags`

Relación muchos-a-muchos entre transacciones y etiquetas.

| Columna          | Tipo                                   | Notas |
| ---------------- | -------------------------------------- | ----- |
| `transaction_id` | INT, FK → `finance_transactions`, PK   |       |
| `tag_id`         | INT, FK → `finance_tags`, PK           |       |

---

### Módulo 2 — Trading

#### `trading_accounts`

Cuentas de broker (ej: FTMO, broker personal, cuenta de fondeo).

| Columna           | Tipo                          | Notas                 |
| ----------------- | ----------------------------- | --------------------- |
| `id`              | INT, PK, AUTO_INCREMENT       |                       |
| `broker_name`     | VARCHAR(100), NOT NULL        |                       |
| `account_number`  | VARCHAR(50), NULL             |                       |
| `initial_balance` | DECIMAL(12,2), DEFAULT 0      | Balance inicial USD   |
| `created_at`      | TIMESTAMP, DEFAULT NOW()      |                       |

#### `trading_strategies`

Estrategias de trading (ej: Breakout, Scalping, Swing Trading).

| Columna       | Tipo                          | Notas |
| ------------- | ----------------------------- | ----- |
| `id`          | INT, PK, AUTO_INCREMENT       |       |
| `name`        | VARCHAR(100), NOT NULL        |       |
| `description` | TEXT, NULL                    |       |
| `created_at`  | TIMESTAMP, DEFAULT NOW()      |       |

#### `trading_instruments`

Activos/pares operados. Mercados soportados: Forex, Acciones, Índices, Futuros, Commodities (sin crypto).

| Columna       | Tipo                                                          | Notas                                  |
| ------------- | ------------------------------------------------------------- | -------------------------------------- |
| `id`          | INT, PK, AUTO_INCREMENT                                       |                                        |
| `symbol`      | VARCHAR(20), NOT NULL                                         | Ej: EUR/USD, AAPL, NQ100              |
| `name`        | VARCHAR(100)                                                  | Nombre legible                         |
| `market_type` | ENUM('forex','stocks','indices','futures','commodities')       | Tipo de mercado                        |
| `created_at`  | TIMESTAMP, DEFAULT NOW()                                      |                                        |

#### `trading_operations`

Registro principal de operaciones de trading.

| Columna          | Tipo                                      | Notas                                                    |
| ---------------- | ----------------------------------------- | -------------------------------------------------------- |
| `id`             | INT, PK, AUTO_INCREMENT                   |                                                          |
| `instrument_id`  | INT, FK → `trading_instruments`, NOT NULL  |                                                          |
| `account_id`     | INT, FK → `trading_accounts`, NULL         |                                                          |
| `strategy_id`    | INT, FK → `trading_strategies`, NULL       |                                                          |
| `direction`      | ENUM('buy', 'sell'), NOT NULL              |                                                          |
| `entry_price`    | DECIMAL(10,5), NOT NULL                   | 5 decimales para pipettes en Forex                       |
| `exit_price`     | DECIMAL(10,5), NULL                       | NULL si la operación está abierta                        |
| `stop_loss`      | DECIMAL(10,5), NULL                       |                                                          |
| `take_profit`    | DECIMAL(10,5), NULL                       |                                                          |
| `position_size`  | DECIMAL(12,4), NOT NULL                   | Lotes, unidades o contratos                              |
| `commission`     | DECIMAL(8,2), DEFAULT 0                   |                                                          |
| `swap`           | DECIMAL(8,2), DEFAULT 0                   | Cobros por mantener posición overnight                   |
| `profit_loss`    | DECIMAL(12,2), NULL                       | Resultado neto en USD (almacenado, no solo calculado)    |
| `status`         | ENUM('open','closed','cancelled'), NOT NULL|                                                          |
| `entry_date`     | DATETIME, NOT NULL                        |                                                          |
| `exit_date`      | DATETIME, NULL                            |                                                          |
| `screenshot_url` | VARCHAR(500), NULL                        | Ruta local a imagen (ej: `/screenshots/op-123.png`)      |
| `notes`          | TEXT, NULL                                |                                                          |
| `created_at`     | TIMESTAMP, DEFAULT NOW()                  |                                                          |
| `updated_at`     | TIMESTAMP, DEFAULT NOW() ON UPDATE        |                                                          |

#### `trading_tags`

Etiquetas para operaciones de trading (ej: "setup A+", "revenge trade", "noticias").

| Columna      | Tipo                          | Notas                |
| ------------ | ----------------------------- | -------------------- |
| `id`         | INT, PK, AUTO_INCREMENT       |                      |
| `name`       | VARCHAR(50), NOT NULL         |                      |
| `color`      | VARCHAR(7), NULL              | Color hex            |
| `created_at` | TIMESTAMP, DEFAULT NOW()      |                      |

#### `trading_operation_tags`

Relación muchos-a-muchos entre operaciones y etiquetas de trading.

| Columna        | Tipo                                    | Notas |
| -------------- | --------------------------------------- | ----- |
| `operation_id` | INT, FK → `trading_operations`, PK      |       |
| `tag_id`       | INT, FK → `trading_tags`, PK            |       |

---

## Diagrama de Relaciones

```
┌─────────────────────────┐     ┌──────────────────────────────┐     ┌───────────────────────────┐
│  finance_categories     │────▶│                              │◀────│  finance_payment_methods  │
└─────────────────────────┘     │                              │     └───────────────────────────┘
                                │    finance_transactions      │
┌─────────────────────────┐     │                              │     ┌───────────────────────────┐
│  finance_accounts       │────▶│                              │◀───▶│ finance_transaction_tags  │
└─────────────────────────┘     └──────────────────────────────┘     └─────────────┬─────────────┘
                                                                                   │
                                                                    ┌──────────────▼──────────────┐
                                                                    │       finance_tags          │
                                                                    └─────────────────────────────┘

┌─────────────────────────┐     ┌──────────────────────────────┐     ┌───────────────────────────┐
│  trading_instruments    │────▶│                              │◀────│  trading_accounts         │
└─────────────────────────┘     │                              │     └───────────────────────────┘
                                │     trading_operations       │
┌─────────────────────────┐     │                              │     ┌───────────────────────────┐
│  trading_strategies     │────▶│                              │◀───▶│  trading_operation_tags   │
└─────────────────────────┘     └──────────────────────────────┘     └─────────────┬─────────────┘
                                                                                   │
                                                                    ┌──────────────▼──────────────┐
                                                                    │       trading_tags          │
                                                                    └─────────────────────────────┘
```

---

## Queries Útiles de Referencia

### Finanzas

```sql
-- Balance actual por cuenta (initial_balance + ingresos - gastos)
SELECT
  a.id, a.name,
  a.initial_balance + COALESCE(SUM(CASE WHEN t.type = 'income' THEN t.amount ELSE -t.amount END), 0) AS current_balance
FROM finance_accounts a
LEFT JOIN finance_transactions t ON t.account_id = a.id
GROUP BY a.id;

-- Gastos por categoría en un mes
SELECT c.name, SUM(t.amount) AS total
FROM finance_transactions t
JOIN finance_categories c ON t.category_id = c.id
WHERE t.type = 'expense' AND YEAR(t.date) = 2026 AND MONTH(t.date) = 2
GROUP BY c.id
ORDER BY total DESC;

-- Resumen mensual (ingresos vs gastos)
SELECT
  DATE_FORMAT(date, '%Y-%m') AS month,
  SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) AS total_income,
  SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) AS total_expenses,
  SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END) AS net
FROM finance_transactions
GROUP BY DATE_FORMAT(date, '%Y-%m')
ORDER BY month DESC;
```

### Trading

```sql
-- Win rate general
SELECT
  COUNT(CASE WHEN profit_loss > 0 THEN 1 END) AS wins,
  COUNT(CASE WHEN profit_loss <= 0 THEN 1 END) AS losses,
  ROUND(COUNT(CASE WHEN profit_loss > 0 THEN 1 END) / COUNT(*) * 100, 2) AS win_rate_pct
FROM trading_operations
WHERE status = 'closed';

-- P&L por instrumento
SELECT i.symbol, i.market_type,
  COUNT(*) AS total_ops,
  SUM(o.profit_loss) AS total_pnl,
  AVG(o.profit_loss) AS avg_pnl
FROM trading_operations o
JOIN trading_instruments i ON o.instrument_id = i.id
WHERE o.status = 'closed'
GROUP BY i.id
ORDER BY total_pnl DESC;

-- P&L por estrategia
SELECT s.name,
  COUNT(*) AS total_ops,
  SUM(o.profit_loss) AS total_pnl,
  ROUND(COUNT(CASE WHEN o.profit_loss > 0 THEN 1 END) / COUNT(*) * 100, 2) AS win_rate_pct
FROM trading_operations o
JOIN trading_strategies s ON o.strategy_id = s.id
WHERE o.status = 'closed'
GROUP BY s.id
ORDER BY total_pnl DESC;

-- Rendimiento mensual de trading
SELECT
  DATE_FORMAT(entry_date, '%Y-%m') AS month,
  COUNT(*) AS total_ops,
  SUM(profit_loss) AS total_pnl,
  SUM(commission + swap) AS total_fees
FROM trading_operations
WHERE status = 'closed'
GROUP BY DATE_FORMAT(entry_date, '%Y-%m')
ORDER BY month DESC;
```

---

## Decisiones de Diseño

| Decisión                        | Razón                                                                                      |
| ------------------------------- | ------------------------------------------------------------------------------------------ |
| Sin tabla de usuarios           | App personal, sin autenticación                                                            |
| Solo USD                        | No se necesita columna de moneda ni tabla de tasas de cambio                                |
| Etiquetas separadas por módulo  | `finance_tags` y `trading_tags` independientes para evitar confusión entre contextos        |
| `profit_loss` almacenado        | El cálculo varía según instrumento (pips, puntos, etc.) — mejor registrar el resultado real |
| `screenshot_url` como ruta      | Las imágenes se guardan en filesystem (`public/screenshots/`), la DB solo guarda la ruta   |
| DECIMAL(10,5) para precios      | 5 decimales necesarios para pipettes en Forex                                              |
| Sin crypto                      | Multi-mercado pero excluye criptomonedas por decisión del usuario                          |
| InnoDB + FK con ON DELETE RESTRICT | Evita borrar categorías/instrumentos que tengan registros asociados                     |
| Charset `utf8mb4`               | Soporte completo de caracteres Unicode                                                     |
