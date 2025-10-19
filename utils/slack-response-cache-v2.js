/**
 * Slack Response Cache System V2 - Multi-Project Support
 * Caches common question responses with project isolation
 */

const fs = require('fs').promises;
const path = require('path');
const SlackProjectConfig = require('./slack-project-config');

class SlackResponseCacheV2 {
  constructor(options = {}) {
    this.projectConfig = options.projectConfig || new SlackProjectConfig();
    this.cache = new Map();
    this.maxCacheSize = options.maxCacheSize || 100;
    this.ttl = options.ttl || 3600000; // 1 hour default
    this.hitCount = new Map();
    this.projectId = null;
    this.storagePath = null;
    this.initialized = false;
  }

  /**
   * Initialize cache for current project
   */
  async initialize() {
    if (this.initialized) return;
    
    // Detect current project
    await this.projectConfig.detectCurrentProject();
    this.projectId = this.projectConfig.currentProject.projectId;
    
    // Set storage path based on project
    this.storagePath = path.join(
      this.projectConfig.getDataDirectory('cache'),
      'response-cache.json'
    );
    
    // Ensure directory exists
    await fs.mkdir(path.dirname(this.storagePath), { recursive: true });
    
    // Load existing cache for this project
    await this.loadCache();
    
    // Initialize common patterns with project-specific bot names
    this.commonPatterns = this.initializeCommonPatterns();
    
    this.initialized = true;
  }

  /**
   * Initialize common question patterns for current project
   */
  initializeCommonPatterns() {
    const projectName = this.projectConfig.getConfig('projectName');
    const botNames = this.projectConfig.getConfig('botNames') || ['@Claude'];
    
    // Create patterns for each bot name
    const patterns = [];
    
    // Generic patterns that work for any bot
    const genericTemplates = [
      { template: 'what\\s+(is|does)\\s+{project}', key: 'project_overview', category: 'product_info' },
      { template: 'how\\s+(do|does)\\s+{feature}\\s+work', key: 'feature_explanation', category: 'features' },
      { template: 'help\\s+with\\s+{topic}', key: 'help_topic', category: 'support' },
      { template: '{error}\\s+(error|problem|issue|failing)', key: 'error_troubleshooting', category: 'troubleshooting' }
    ];
    
    // Add project-specific patterns
    patterns.push({
      pattern: new RegExp(`what\\s+(is|does)\\s+${projectName}`, 'i'),
      key: `${projectName.toLowerCase()}_overview`,
      category: 'product_info'
    });
    
    // Add bot-specific patterns
    for (const botName of botNames) {
      const cleanName = botName.replace('@', '');
      patterns.push({
        pattern: new RegExp(`${botName}\\s+help`, 'i'),
        key: `${cleanName.toLowerCase()}_help`,
        category: 'help'
      });
    }
    
    // Add common technical patterns
    patterns.push(
      {
        pattern: /deploy|build|ci[\/\s-]?cd|pipeline/i,
        key: 'deployment_help',
        category: 'deployment'
      },
      {
        pattern: /test|spec|coverage|tdd/i,
        key: 'testing_help',
        category: 'testing'
      },
      {
        pattern: /api|endpoint|rest|graphql/i,
        key: 'api_help',
        category: 'api'
      }
    );
    
    return patterns;
  }

  /**
   * Load cache from project-specific storage
   */
  async loadCache() {
    try {
      const data = await fs.readFile(this.storagePath, 'utf8');
      const cacheData = JSON.parse(data);
      
      // Only load cache entries for current project
      if (cacheData.projectId === this.projectId) {
        this.cache = new Map(cacheData.entries);
        this.hitCount = new Map(cacheData.hitCount);
      }
    } catch (error) {
      // No existing cache, start fresh
      this.cache = new Map();
      this.hitCount = new Map();
    }
  }

  /**
   * Save cache to project-specific storage
   */
  async saveCache() {
    const cacheData = {
      projectId: this.projectId,
      projectName: this.projectConfig.getConfig('projectName'),
      entries: Array.from(this.cache.entries()),
      hitCount: Array.from(this.hitCount.entries()),
      saved: new Date().toISOString()
    };
    
    try {
      await fs.writeFile(this.storagePath, JSON.stringify(cacheData, null, 2));
    } catch (error) {
      console.error('Failed to save cache:', error);
    }
  }

  /**
   * Generate cache key from message with project context
   */
  generateCacheKey(message) {
    if (!this.initialized) {
      throw new Error('Cache not initialized. Call initialize() first.');
    }
    
    // Check for exact pattern matches first
    for (const pattern of this.commonPatterns) {
      if (pattern.pattern.test(message)) {
        return `${this.projectId}_${pattern.key}`;
      }
    }
    
    // Generate hash-based key with project prefix
    const normalized = message.toLowerCase()
      .replace(/[^a-z0-9\s]/g, '')
      .replace(/\s+/g, ' ')
      .trim();
    
    return `${this.projectId}_${this.simpleHash(normalized)}`;
  }

  /**
   * Simple hash function for cache keys
   */
  simpleHash(str) {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return `msg_${Math.abs(hash)}`;
  }

  /**
   * Get cached response if available
   */
  async get(message, context = {}) {
    if (!this.initialized) {
      await this.initialize();
    }
    
    const key = this.generateCacheKey(message);
    const cached = this.cache.get(key);
    
    if (!cached) {
      return null;
    }
    
    // Check if expired
    if (Date.now() - cached.timestamp > this.ttl) {
      this.cache.delete(key);
      await this.saveCache();
      return null;
    }
    
    // Check context match
    if (cached.contextSensitive && !this.contextMatches(cached.context, context)) {
      return null;
    }
    
    // Track cache hit
    this.hitCount.set(key, (this.hitCount.get(key) || 0) + 1);
    
    // Return with project-specific signature if configured
    const signature = this.projectConfig.getConfig('responseSettings.signature');
    const response = cached.response + (signature ? `\n\n${signature}` : '');
    
    return {
      response,
      cached: true,
      cacheAge: Date.now() - cached.timestamp,
      hitCount: this.hitCount.get(key),
      projectId: this.projectId
    };
  }

  /**
   * Store response in cache
   */
  async set(message, response, context = {}, options = {}) {
    if (!this.initialized) {
      await this.initialize();
    }
    
    const key = this.generateCacheKey(message);
    
    // Implement LRU eviction if cache is full
    if (this.cache.size >= this.maxCacheSize) {
      this.evictLeastUsed();
    }
    
    this.cache.set(key, {
      response,
      timestamp: Date.now(),
      context,
      contextSensitive: options.contextSensitive || false,
      category: this.detectCategory(message),
      projectId: this.projectId,
      metadata: {
        messageLength: message.length,
        responseLength: response.length,
        hasCode: response.includes('```'),
        hasLinks: response.includes('http')
      }
    });
    
    await this.saveCache();
  }

  /**
   * Check if contexts match
   */
  contextMatches(cached, current) {
    // Channel must match for context-sensitive responses
    if (cached.channel && cached.channel !== current.channel) {
      return false;
    }
    
    // Project must match
    if (cached.projectId && cached.projectId !== this.projectId) {
      return false;
    }
    
    // User-specific responses
    if (cached.userSpecific && cached.user !== current.user) {
      return false;
    }
    
    return true;
  }

  /**
   * Detect category of message
   */
  detectCategory(message) {
    for (const pattern of this.commonPatterns) {
      if (pattern.pattern.test(message)) {
        return pattern.category;
      }
    }
    return 'general';
  }

  /**
   * Evict least recently used items
   */
  evictLeastUsed() {
    const entries = Array.from(this.cache.entries()).map(([key, value]) => ({
      key,
      value,
      score: (this.hitCount.get(key) || 0) * 1000 + (Date.now() - value.timestamp)
    }));
    
    entries.sort((a, b) => a.score - b.score);
    
    // Remove bottom 10%
    const toRemove = Math.ceil(this.maxCacheSize * 0.1);
    for (let i = 0; i < toRemove; i++) {
      this.cache.delete(entries[i].key);
      this.hitCount.delete(entries[i].key);
    }
  }

  /**
   * Clear expired entries
   */
  async cleanup() {
    const now = Date.now();
    let changed = false;
    
    for (const [key, value] of this.cache.entries()) {
      if (now - value.timestamp > this.ttl) {
        this.cache.delete(key);
        this.hitCount.delete(key);
        changed = true;
      }
    }
    
    if (changed) {
      await this.saveCache();
    }
  }

  /**
   * Get cache statistics for current project
   */
  getStats() {
    const categories = {};
    for (const value of this.cache.values()) {
      categories[value.category] = (categories[value.category] || 0) + 1;
    }
    
    return {
      projectId: this.projectId,
      projectName: this.projectConfig.getConfig('projectName'),
      size: this.cache.size,
      maxSize: this.maxCacheSize,
      totalHits: Array.from(this.hitCount.values()).reduce((a, b) => a + b, 0),
      categories,
      oldestEntry: this.cache.size > 0 
        ? new Date(Math.min(...Array.from(this.cache.values()).map(v => v.timestamp)))
        : null,
      averageResponseLength: this.cache.size > 0
        ? Array.from(this.cache.values())
            .reduce((sum, v) => sum + v.metadata.responseLength, 0) / this.cache.size
        : 0
    };
  }

  /**
   * Clear cache for current project
   */
  async clear() {
    this.cache.clear();
    this.hitCount.clear();
    await this.saveCache();
  }

  /**
   * Export cache for current project
   */
  async export() {
    return {
      projectId: this.projectId,
      projectName: this.projectConfig.getConfig('projectName'),
      cache: Array.from(this.cache.entries()),
      hitCount: Array.from(this.hitCount.entries()),
      timestamp: Date.now()
    };
  }

  /**
   * Import cache for current project
   */
  async import(data) {
    if (data.projectId !== this.projectId) {
      throw new Error('Cannot import cache from different project');
    }
    
    if (data.cache) {
      this.cache = new Map(data.cache);
    }
    if (data.hitCount) {
      this.hitCount = new Map(data.hitCount);
    }
    
    await this.saveCache();
    this.cleanup();
  }
}

module.exports = SlackResponseCacheV2;