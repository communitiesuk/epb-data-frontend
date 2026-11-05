function cookieConsent(tagId, _, gtag, resolvers) {
  _.dataLayer = _.dataLayer || [];

  const cookies = {
    initialize: () => {
      if (!tagId) return;

      const location = window.location;

      if (location.search.indexOf('cookies-setting=false') !== -1) return;

      const cookieValue = cookies.read('cookie_consent');

      const onCookiePage = location.pathname.indexOf('/cookies') === 0;

      cookies.signalGtmConsent(cookieValue === 'true');

      if (cookieValue === null && !onCookiePage) {
        cookies.displayCookieBanner();
      }

      if (onCookiePage) {
        cookies.cookieFormHandler();
      }
    },

    displayCookieBanner: () => {
      cookies.showCookieBanner();

      const acceptButton = resolvers.acceptButton();
      acceptButton.addEventListener('click', () => {
        cookies.grantCookieConsent();

        cookies.hideCookieQuestion();

        cookies.displayConfirmation(true);
      });

      const rejectButton = resolvers.rejectButton();
      rejectButton.addEventListener('click', () => {
        cookies.rejectCookieConsent();

        cookies.hideCookieQuestion();

        cookies.displayConfirmation(false);
      });

      const hideCookieMessageButton = resolvers.hideCookieMessageButton();
      hideCookieMessageButton.addEventListener('click', () => {
        cookies.hideCookieBanner();
      });
    },

    showCookieBanner: () => {
      const cookieBanner = resolvers.cookieBanner();
      cookieBanner.hidden = false;
      const cookieMessage = resolvers.cookieMessage();
      cookieMessage.hidden = false;
    },

    hideCookieQuestion: () => {
      const cookieMessage = resolvers.cookieMessage();
      cookieMessage.hidden = true;
    },

    displayConfirmation: (consent) => {
      const cookieConfirmation = resolvers.cookieConfirmation();
      cookieConfirmation.hidden = false;

      const messageResolver =
        consent === true ? resolvers.acceptedConfirmationMessage : resolvers.rejectedConfirmationMessage;

      const cookieConfirmationMessage = messageResolver();
      cookieConfirmationMessage.hidden = false;
    },

    hideCookieBanner: () => {
      const cookieBanner = resolvers.cookieBanner();
      cookieBanner.hidden = true;
    },

    grantCookieConsent: () => {
      cookies.create('cookie_consent', 'true');

      cookies.enableAnalytics();
    },

    rejectCookieConsent: () => {
      cookies.erase();

      cookies.create('cookie_consent', 'false');

      cookies.signalGtmConsent(false);
    },

    enableAnalytics: () => {
      cookies.updateGtmConsent(true);
    },

    signalGtmConsent: (isGranted = false) => {
      gtag('consent', 'default', {
        ad_storage: 'denied',
        analytics_storage: isGranted ? 'granted' : 'denied',
      });

      _.dataLayer.push({ event: 'default_consent' });
    },

    updateGtmConsent: (isGranted = false) => {
      gtag('consent', 'update', { analytics_storage: isGranted ? 'granted' : 'denied' });
    },

    create: (name, value) => {
      const yearInMilliseconds = 365 * 24 * 60 * 60 * 1000;
      const date = new Date();
      date.setTime(date.getTime() + yearInMilliseconds);
      const expires = `; expires=${date.toUTCString()}`;

      document.cookie = `${name}=${value}${expires}; path=/ ; SameSite=Strict;`;
    },

    read: (name) => {
      const nameEQ = `${name}=`;
      const ca = document.cookie.split(';');
      for (let i = 0; i < ca.length; i++) {
        let c = ca[i];
        while (c.charAt(0) === ' ') c = c.substring(1, c.length);
        if (c.indexOf(nameEQ) === 0) return c.substring(nameEQ.length, c.length);
      }
      return null;
    },

    erase: () => {
      const cookies = document.cookie.split('; ');

      for (let i = 0; i < cookies.length; i++) {
        if (cookies[i].startsWith('_ga')) {
          const expDate = new Date();
          const name = `${cookies[i].split('=')[0]}=`;
          const value = `${cookies[i].split('=')[1]};`;

          const expires = ` expires=${expDate.toUTCString()};`;
          const path = ' path=/;';
          let domain;
          if (window.location.hostname.includes('communities')) {
            domain = ` domain=${window.location.hostname.split('.').slice(-3).join('.')};`;
          } else {
            domain = ` domain=.${window.location.hostname};`;
          }
          document.cookie = name + value + expires + path + domain;
        }
      }
    },

    cookieFormHandler: () => {
      document.getElementById('cookies-consent-form').addEventListener('submit', cookies.cookieFormOnSubmit);
    },

    cookieFormOnSubmit: () => {
      if (document.getElementById('cookies-setting').checked === true) {
        cookies.create('cookie_consent', 'true');
      } else {
        cookies.rejectCookieConsent();
      }
      return true;
    },
  };

  cookies.initialize();
}

cookieConsent(
  window.GOOGLE_PROPERTY,
  window,
  window.gtag ||
    ((...args) => {
      window.dataLayer = window.dataLayer || [];
      window.dataLayer.push(args);
    }),
  {
    cookieBanner: () => document.getElementsByClassName('govuk-cookie-banner')[0],
    cookieMessage: () => document.getElementsByClassName('govuk-cookie-banner__message')[0],
    cookieConfirmation: () => document.getElementById('cookie-confirmation'),
    acceptButton: () => document.getElementById('accept-button'),
    rejectButton: () => document.getElementById('reject-button'),
    hideCookieMessageButton: () => document.getElementById('hide-cookie-message'),
    acceptedConfirmationMessage: () => document.getElementById('accepted-confirmation'),
    rejectedConfirmationMessage: () => document.getElementById('rejected-confirmation'),
  },
);
