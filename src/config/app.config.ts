export type AppState = 'waitlist' | 'beta' | 'live';
export type ResultToolState = 'coming' | 'live';

export const APP_CONFIG = {
  APP_STATE: 'waitlist' as AppState,
  RESULT_TOOL_STATE: 'coming' as ResultToolState,
  APP_URL: 'https://app.heymey.in',
  DISCLAIMER:
    'HeyMey is an independent product. It is not affiliated with TNPSC or the Government of Tamil Nadu.',
  BRAND_NAME: 'HeyMey',
  BRAND_SYMBOL: '™',
} as const;

export const getBeginJourneyTarget = (state: AppState = APP_CONFIG.APP_STATE) => {
  switch (state) {
    case 'waitlist':
      return { href: '/begin', isExternal: false };
    case 'beta':
    case 'live':
      return { href: `${APP_CONFIG.APP_URL}/signup`, isExternal: true };
  }
};

export const getBeginJourneyHelper = (state: AppState = APP_CONFIG.APP_STATE) => {
  switch (state) {
    case 'waitlist':
      return 'Closed beta opening soon. Join the list.';
    case 'beta':
      return 'Invite-only beta.';
    case 'live':
      return '';
  }
};
