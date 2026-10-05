export default {
  injectGlobals: false,
  restoreMocks: true,
  testEnvironment: "jsdom",
  testPathIgnorePatterns: [
    '/node_modules/',
    // Ignore built assets
    '/public/',
    // CI installs gems to /vendor/bundle/, which may contain tests
    '/vendor/',
  ],
  transform: {},
};
