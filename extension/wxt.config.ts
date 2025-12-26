import { defineConfig } from 'wxt';

// See https://wxt.dev/api/config.html
export default defineConfig({
  modules: ['@wxt-dev/module-react'],
  dev: {
    server: {
      host: '0.0.0.0',
      port: 3000,
    }
  },
  webExt: {
    disabled: true,
  },
  vite: () => ({
    server: {
      host: '0.0.0.0',
      port: 3000,
      strictPort: true,
      hmr: {
        port: 3000,
      }
    }
  }),
  manifest: {
    action: {
      default_title: "TubeShelf",
    },
    web_accessible_resources: [
      {
        matches: ["*://*.youtube.com/*"],
        resources: ["icon/*.png"],
      },
    ],
  },
});
