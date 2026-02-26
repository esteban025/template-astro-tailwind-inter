import { getInstruments, getInstrumentById } from "./instruments";
import { getStrategies, getStrategyById, createStrategy } from "./strategies";
import { getAccounts, getAccountById, createAccount } from "./accounts";
import {
  createOperation,
  getActiveOperations,
  getClosedOperations,
  closeOperation,
  getOperationsStats,
} from "./operations";

export const server = {
  // Instruments
  getInstruments,
  getInstrumentById,

  // Strategies
  getStrategies,
  getStrategyById,
  createStrategy,

  // Accounts
  getAccounts,
  getAccountById,
  createAccount,

  // Operations
  createOperation,
  getActiveOperations,
  getClosedOperations,
  closeOperation,
  getOperationsStats,
};