"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;
var cookieConsent = function cookieConsent(tagId, _, gtag, resolvers) {
  _.dataLayer = _.dataLayer || [];
  var cookies = {
    initialize: function initialize() {
      if (!tagId) return;
      var location = window.location;
      if (location.search.indexOf('cookies-setting=false') !== -1) return;
      var cookieValue = cookies.read('cookie_consent');
      var onCookiePage = location.pathname.indexOf('/cookies') === 0;
      cookies.signalGtmConsent(cookieValue === 'true');
      if (cookieValue === null && !onCookiePage) {
        cookies.displayCookieBanner();
      }
      if (onCookiePage) {
        document.getElementById('cookies-setting' + (cookieValue === 'true' ? '' : '-false')).checked = true;
        cookies.cookieFormHandler();
      }
    },
    displayCookieBanner: function displayCookieBanner() {
      cookies.showCookieBanner();
      var acceptButton = resolvers.acceptButton();
      acceptButton.addEventListener('click', function () {
        cookies.grantCookieConsent();
        cookies.hideCookieQuestion();
        cookies.displayConfirmation(true);
      });
      var rejectButton = resolvers.rejectButton();
      rejectButton.addEventListener('click', function () {
        cookies.rejectCookieConsent();
        cookies.hideCookieQuestion();
        cookies.displayConfirmation(false);
      });
      var hideCookieMessageButton = resolvers.hideCookieMessageButton();
      hideCookieMessageButton.addEventListener('click', function () {
        cookies.hideCookieBanner();
      });
    },
    showCookieBanner: function showCookieBanner() {
      var cookieBanner = resolvers.cookieBanner();
      cookieBanner.hidden = false;
      var cookieMessage = resolvers.cookieMessage();
      cookieMessage.hidden = false;
    },
    hideCookieQuestion: function hideCookieQuestion() {
      var cookieMessage = resolvers.cookieMessage();
      cookieMessage.hidden = true;
    },
    displayConfirmation: function displayConfirmation(consent) {
      var cookieConfirmation = resolvers.cookieConfirmation();
      cookieConfirmation.hidden = false;
      var messageResolver = consent === true ? resolvers.acceptedConfirmationMessage : resolvers.rejectedConfirmationMessage;
      var cookieConfirmationMessage = messageResolver();
      cookieConfirmationMessage.hidden = false;
    },
    hideCookieBanner: function hideCookieBanner() {
      var cookieBanner = resolvers.cookieBanner();
      cookieBanner.hidden = true;
    },
    grantCookieConsent: function grantCookieConsent() {
      cookies.create('cookie_consent', 'true');
      cookies.enableAnalytics();
    },
    rejectCookieConsent: function rejectCookieConsent() {
      cookies.erase();
      cookies.create('cookie_consent', 'false');
      cookies.signalGtmConsent(false);
    },
    enableAnalytics: function enableAnalytics() {
      cookies.updateGtmConsent(true);
    },
    signalGtmConsent: function signalGtmConsent() {
      var isGranted = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : false;
      gtag('consent', 'default', {
        ad_storage: 'denied',
        analytics_storage: isGranted ? 'granted' : 'denied'
      });
      _.dataLayer.push({
        event: 'default_consent'
      });
    },
    updateGtmConsent: function updateGtmConsent() {
      var isGranted = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : false;
      gtag('consent', 'update', {
        analytics_storage: isGranted ? 'granted' : 'denied'
      });
    },
    create: function create(name, value) {
      var yearInMilliseconds = 365 * 24 * 60 * 60 * 1000;
      var date = new Date();
      date.setTime(date.getTime() + yearInMilliseconds);
      var expires = '; expires=' + date.toUTCString();
      document.cookie = name + '=' + value + expires + '; path=/ ; SameSite=Strict; ';
    },
    read: function read(name) {
      var nameEQ = name + '=';
      var ca = document.cookie.split(';');
      for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) === ' ') c = c.substring(1, c.length);
        if (c.indexOf(nameEQ) === 0) return c.substring(nameEQ.length, c.length);
      }
      return null;
    },
    erase: function erase() {
      var cookies = document.cookie.split('; ');
      for (var i = 0; i < cookies.length; i++) {
        if (cookies[i].startsWith('_ga')) {
          var expDate = new Date();
          var name = cookies[i].split('=')[0] + '=';
          var value = cookies[i].split('=')[1] + ';';
          var expires = ' expires=' + expDate.toUTCString() + ';';
          var path = ' path=/;';
          var domain = void 0;
          if (document.domain.includes('communities')) {
            domain = ' domain=' + document.domain.split('.').slice(-3).join('.') + ';';
          } else {
            domain = ' domain=' + '.' + document.domain + ';';
          }
          document.cookie = name + value + expires + path + domain;
        }
      }
    },
    eraseOnPageChange: function eraseOnPageChange() {
      document.addEventListener('visibilitychange', function () {
        if (document.visibilityState === 'hidden') {
          cookies.erase();
        }
      });
    },
    cookieFormHandler: function cookieFormHandler() {
      document.getElementById('cookies-consent-form').addEventListener('submit', cookies.cookieFormOnSubmit);
    },
    cookieFormOnSubmit: function cookieFormOnSubmit() {
      if (document.getElementById('cookies-setting').checked === true) {
        cookies.create('cookie_consent', 'true');
      } else {
        cookies.rejectCookieConsent();
      }
      return true;
    }
  };
  _.onload = cookies.initialize;
  return cookies;
};
var _default = exports.default = cookieConsent;
if (typeof window !== 'undefined') {
  window.cookies = cookieConsent(window.GOOGLE_PROPERTY, window, window.gtag || function () {
    window.dataLayer = window.dataLayer || [];
    for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
      args[_key] = arguments[_key];
    }
    window.dataLayer.push(args);
  }, typeof resolvers !== 'undefined' ? resolvers : {
    cookieBanner: function cookieBanner() {
      return document.getElementsByClassName('govuk-cookie-banner')[0];
    },
    cookieMessage: function cookieMessage() {
      return document.getElementsByClassName('govuk-cookie-banner__message')[0];
    },
    cookieConfirmation: function cookieConfirmation() {
      return document.getElementById('confirmation');
    },
    acceptButton: function acceptButton() {
      return document.getElementById('accept-button');
    },
    rejectButton: function rejectButton() {
      return document.getElementById('reject-button');
    },
    hideCookieMessageButton: function hideCookieMessageButton() {
      return document.getElementById('hide-cookie-message');
    },
    acceptedConfirmationMessage: function acceptedConfirmationMessage() {
      return document.getElementById('accepted-confirmation');
    },
    rejectedConfirmationMessage: function rejectedConfirmationMessage() {
      return document.getElementById('rejected-confirmation');
    }
  });
}