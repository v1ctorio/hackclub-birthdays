export const absolute_url = path => new URL(path, globalThis.location.origin).href;
