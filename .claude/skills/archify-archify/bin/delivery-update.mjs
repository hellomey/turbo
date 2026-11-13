// HeyMey: upstream update check removed (network call + home-dir cache). Always reports disabled.
export function startDeliveryUpdateCheck() {
  return Promise.resolve({ status: 'unavailable', installedVersion: null, availableVersion: null,
    releaseNotes: null, checkedAt: null, source: null, noticeRequired: false, noticeText: null,
    reason: 'disabled' });
}
