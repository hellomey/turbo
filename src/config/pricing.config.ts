export interface PricingConfig {
  cyclePassPrice: number | null;
  cyclePassDuration: string;
  refundWindowDays: number | null;
  currency: string;
}

export const PRICING_CONFIG: PricingConfig = {
  cyclePassPrice: null, // null renders 'Beta pricing announced soon' per spec §6.5
  cyclePassDuration: 'Per Exam Cycle',
  refundWindowDays: null,
  currency: '₹',
};
