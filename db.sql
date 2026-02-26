-- ============================================================
-- Finance Register - Database Schema
-- MySQL 5.7+ / MariaDB 10.2+
-- Charset: utf8mb4, Engine: InnoDB
-- ============================================================

-- Eliminar base de datos si existe (CUIDADO: borra todos los datos)
-- DROP DATABASE IF EXISTS finance_register;

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS finance_register
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE finance_register;

-- ============================================================
-- MÓDULO 1: FINANZAS PERSONALES
-- ============================================================

-- Tabla: finance_categories
-- Categorías de gastos e ingresos
CREATE TABLE finance_categories (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  type ENUM('expense', 'income') NOT NULL,
  icon VARCHAR(50) NULL COMMENT 'Icono para la UI (opcional)',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: finance_payment_methods
-- Métodos de pago
CREATE TABLE finance_payment_methods (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: finance_accounts
-- Cuentas o billeteras donde se lleva el balance
CREATE TABLE finance_accounts (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  initial_balance DECIMAL(12,2) DEFAULT 0.00 COMMENT 'Balance inicial en USD',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: finance_transactions
-- Registro principal de gastos e ingresos
CREATE TABLE finance_transactions (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  type ENUM('expense', 'income') NOT NULL,
  amount DECIMAL(12,2) NOT NULL COMMENT 'Monto en USD',
  description TEXT NULL,
  date DATE NOT NULL COMMENT 'Fecha de la transacción',
  category_id INT UNSIGNED NOT NULL,
  payment_method_id INT UNSIGNED NULL,
  account_id INT UNSIGNED NULL,
  is_recurring BOOLEAN DEFAULT FALSE,
  recurring_period ENUM('daily', 'weekly', 'biweekly', 'monthly', 'yearly') NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_type (type),
  INDEX idx_date (date),
  INDEX idx_category (category_id),
  INDEX idx_account (account_id),
  INDEX idx_type_date (type, date),
  
  CONSTRAINT fk_transaction_category
    FOREIGN KEY (category_id) REFERENCES finance_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  
  CONSTRAINT fk_transaction_payment_method
    FOREIGN KEY (payment_method_id) REFERENCES finance_payment_methods(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  
  CONSTRAINT fk_transaction_account
    FOREIGN KEY (account_id) REFERENCES finance_accounts(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: finance_tags
-- Etiquetas libres para clasificación flexible
CREATE TABLE finance_tags (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  color VARCHAR(7) NULL COMMENT 'Color en formato hex (ej: #FF5733)',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: finance_transaction_tags
-- Relación muchos-a-muchos entre transacciones y etiquetas
CREATE TABLE finance_transaction_tags (
  transaction_id INT UNSIGNED NOT NULL,
  tag_id INT UNSIGNED NOT NULL,
  
  PRIMARY KEY (transaction_id, tag_id),
  
  CONSTRAINT fk_trans_tag_transaction
    FOREIGN KEY (transaction_id) REFERENCES finance_transactions(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  
  CONSTRAINT fk_trans_tag_tag
    FOREIGN KEY (tag_id) REFERENCES finance_tags(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- MÓDULO 2: TRADING
-- ============================================================

-- Tabla: trading_accounts
-- Cuentas de broker
CREATE TABLE trading_accounts (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  broker_name VARCHAR(100) NOT NULL,
  account_number VARCHAR(50) NULL,
  initial_balance DECIMAL(12,2) DEFAULT 0.00 COMMENT 'Balance inicial en USD',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: trading_strategies
-- Estrategias de trading
CREATE TABLE trading_strategies (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: trading_instruments
-- Activos/pares operados (Forex, Acciones, Índices, Futuros, Commodities)
CREATE TABLE trading_instruments (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  symbol VARCHAR(20) NOT NULL UNIQUE COMMENT 'Ej: EUR/USD, AAPL, NQ100',
  name VARCHAR(100) NULL COMMENT 'Nombre legible del instrumento',
  market_type ENUM('forex', 'stocks', 'indices', 'futures', 'commodities') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_market_type (market_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: trading_operations
-- Registro principal de operaciones de trading
CREATE TABLE trading_operations (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  instrument_id INT UNSIGNED NOT NULL,
  account_id INT UNSIGNED NULL,
  strategy_id INT UNSIGNED NULL,
  direction ENUM('buy', 'sell') NOT NULL,
  entry_price DECIMAL(10,5) NOT NULL COMMENT '5 decimales para pipettes en Forex',
  exit_price DECIMAL(10,5) NULL COMMENT 'NULL si la operación está abierta',
  stop_loss DECIMAL(10,5) NULL,
  take_profit DECIMAL(10,5) NULL,
  position_size DECIMAL(12,4) NOT NULL COMMENT 'Lotes, unidades o contratos',
  commission DECIMAL(8,2) DEFAULT 0.00,
  swap DECIMAL(8,2) DEFAULT 0.00 COMMENT 'Cobros por mantener posición overnight',
  profit_loss DECIMAL(12,2) NULL COMMENT 'Resultado neto en USD',
  status ENUM('open', 'closed', 'cancelled') NOT NULL DEFAULT 'open',
  entry_date DATETIME NOT NULL,
  exit_date DATETIME NULL,
  screenshot_url VARCHAR(500) NULL COMMENT 'Ruta local a imagen',
  notes TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_instrument (instrument_id),
  INDEX idx_account (account_id),
  INDEX idx_status (status),
  INDEX idx_entry_date (entry_date),
  INDEX idx_status_entry_date (status, entry_date),
  
  CONSTRAINT fk_operation_instrument
    FOREIGN KEY (instrument_id) REFERENCES trading_instruments(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  
  CONSTRAINT fk_operation_account
    FOREIGN KEY (account_id) REFERENCES trading_accounts(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  
  CONSTRAINT fk_operation_strategy
    FOREIGN KEY (strategy_id) REFERENCES trading_strategies(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: trading_tags
-- Etiquetas para operaciones de trading
CREATE TABLE trading_tags (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  color VARCHAR(7) NULL COMMENT 'Color en formato hex (ej: #3B82F6)',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: trading_operation_tags
-- Relación muchos-a-muchos entre operaciones y etiquetas de trading
CREATE TABLE trading_operation_tags (
  operation_id INT UNSIGNED NOT NULL,
  tag_id INT UNSIGNED NOT NULL,
  
  PRIMARY KEY (operation_id, tag_id),
  
  CONSTRAINT fk_op_tag_operation
    FOREIGN KEY (operation_id) REFERENCES trading_operations(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  
  CONSTRAINT fk_op_tag_tag
    FOREIGN KEY (tag_id) REFERENCES trading_tags(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- DATOS INICIALES (SEED)
-- ============================================================

-- Categorías de GASTOS
INSERT INTO finance_categories (name, type, icon) VALUES
('Alimentación', 'expense', '🍽️'),
('Transporte', 'expense', '🚗'),
('Vivienda', 'expense', '🏠'),
('Entretenimiento', 'expense', '🎮'),
('Salud', 'expense', '🏥'),
('Educación', 'expense', '📚'),
('Suscripciones', 'expense', '📱'),
('Ropa y Calzado', 'expense', '👕'),
('Servicios', 'expense', '💡'),
('Otros Gastos', 'expense', '📦');

-- Categorías de INGRESOS
INSERT INTO finance_categories (name, type, icon) VALUES
('Salario', 'income', '💼'),
('Freelance', 'income', '💻'),
('Inversiones', 'income', '📈'),
('Trading', 'income', '💹'),
('Otros Ingresos', 'income', '💰');

-- Métodos de Pago
INSERT INTO finance_payment_methods (name) VALUES
('Efectivo'),
('Tarjeta de Débito'),
('Tarjeta de Crédito'),
('Transferencia Bancaria'),
('PayPal'),
('Otro');

-- Estrategias de Trading
INSERT INTO trading_strategies (name, description) VALUES
('Scalping', 'Operaciones muy cortas, aprovechando pequeños movimientos del precio'),
('Day Trading', 'Abrir y cerrar posiciones dentro del mismo día'),
('Swing Trading', 'Mantener posiciones por varios días o semanas'),
('Breakout', 'Operar rupturas de niveles clave de soporte/resistencia'),
('Price Action', 'Decisiones basadas en la acción del precio sin indicadores'),
('Tendencia', 'Seguir la dirección predominante del mercado');

-- Instrumentos de Trading - FOREX
INSERT INTO trading_instruments (symbol, name, market_type) VALUES
('EUR/USD', 'Euro vs Dólar Estadounidense', 'forex'),
('GBP/USD', 'Libra Esterlina vs Dólar Estadounidense', 'forex'),
('USD/JPY', 'Dólar Estadounidense vs Yen Japonés', 'forex'),
('USD/CHF', 'Dólar Estadounidense vs Franco Suizo', 'forex'),
('AUD/USD', 'Dólar Australiano vs Dólar Estadounidense', 'forex'),
('USD/CAD', 'Dólar Estadounidense vs Dólar Canadiense', 'forex'),
('NZD/USD', 'Dólar Neozelandés vs Dólar Estadounidense', 'forex');

-- Instrumentos de Trading - ACCIONES
INSERT INTO trading_instruments (symbol, name, market_type) VALUES
('AAPL', 'Apple Inc.', 'stocks'),
('MSFT', 'Microsoft Corporation', 'stocks'),
('GOOGL', 'Alphabet Inc.', 'stocks'),
('AMZN', 'Amazon.com Inc.', 'stocks'),
('TSLA', 'Tesla Inc.', 'stocks'),
('NVDA', 'NVIDIA Corporation', 'stocks');

-- Instrumentos de Trading - ÍNDICES
INSERT INTO trading_instruments (symbol, name, market_type) VALUES
('SPX500', 'S&P 500', 'indices'),
('NQ100', 'NASDAQ 100', 'indices'),
('US30', 'Dow Jones Industrial Average', 'indices'),
('GER40', 'DAX 40', 'indices'),
('UK100', 'FTSE 100', 'indices');

-- Instrumentos de Trading - COMMODITIES
INSERT INTO trading_instruments (symbol, name, market_type) VALUES
('XAUUSD', 'Oro vs Dólar (Gold)', 'commodities'),
('XAGUSD', 'Plata vs Dólar (Silver)', 'commodities'),
('USOIL', 'Petróleo Crudo WTI', 'commodities'),
('UKOIL', 'Petróleo Crudo Brent', 'commodities');

-- Instrumentos de Trading - FUTUROS
INSERT INTO trading_instruments (symbol, name, market_type) VALUES
('ES', 'E-mini S&P 500 Futures', 'futures'),
('NQ', 'E-mini NASDAQ 100 Futures', 'futures'),
('YM', 'E-mini Dow Futures', 'futures');

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
