'use strict';

/**
 * Runs at most `limit` tasks at once; further ones wait in line (up to
 * `maxQueue`, beyond that they are refused). Used where a burst of requests
 * (a map with thirty tiles) must be served, not dropped, without hammering the
 * upstream provider.
 */
class Limiter {
  constructor(limit, maxQueue = 256) {
    this.limit = limit;
    this.maxQueue = maxQueue;
    this.active = 0;
    this.queue = [];
  }

  async run(task) {
    if (this.active >= this.limit) {
      if (this.queue.length >= this.maxQueue) throw new Error('Too many queued requests');
      await new Promise((resolve) => { this.queue.push(resolve); });
    } else {
      this.active += 1;
    }
    try {
      return await task();
    } finally {
      const next = this.queue.shift();
      if (next) next(); // hand the slot over without releasing it
      else this.active -= 1;
    }
  }
}

module.exports = { Limiter };
