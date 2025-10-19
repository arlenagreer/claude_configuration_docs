/**
 * Slack Project Configuration Manager
 * Handles per-directory configuration and data isolation
 */

const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');

class SlackProjectConfig {
  constructor() {
    this.globalConfigPath = path.join(process.env.HOME, '.claude', 'config', 'slack-projects.json');
    this.currentProject = null;
    this.projectConfigs = new Map();
    this.loadConfigs();
  }

  /**
   * Load all project configurations
   */
  async loadConfigs() {
    try {
      const data = await fs.readFile(this.globalConfigPath, 'utf8');
      const configs = JSON.parse(data);
      
      for (const [projectId, config] of Object.entries(configs)) {
        this.projectConfigs.set(projectId, config);
      }
    } catch (error) {
      // Initialize with empty configs if file doesn't exist
      this.projectConfigs = new Map();
    }
  }

  /**
   * Save configurations to disk
   */
  async saveConfigs() {
    const configs = {};
    for (const [projectId, config] of this.projectConfigs) {
      configs[projectId] = config;
    }
    
    const dir = path.dirname(this.globalConfigPath);
    await fs.mkdir(dir, { recursive: true });
    await fs.writeFile(this.globalConfigPath, JSON.stringify(configs, null, 2));
  }

  /**
   * Get project ID from directory path
   */
  getProjectId(directory) {
    // Create a hash of the directory path for consistent project ID
    return crypto.createHash('md5').update(directory).digest('hex').substring(0, 8);
  }

  /**
   * Detect current project from working directory
   */
  async detectCurrentProject() {
    const cwd = process.cwd();
    const projectId = this.getProjectId(cwd);
    
    // Check if we have a local .claude-slack.json config
    const localConfigPath = path.join(cwd, '.claude-slack.json');
    
    try {
      const localConfig = await fs.readFile(localConfigPath, 'utf8');
      const config = JSON.parse(localConfig);
      
      // Merge with stored config
      const existingConfig = this.projectConfigs.get(projectId) || {};
      const mergedConfig = {
        ...existingConfig,
        ...config,
        projectPath: cwd,
        projectId,
        lastUpdated: new Date().toISOString()
      };
      
      this.projectConfigs.set(projectId, mergedConfig);
      this.currentProject = mergedConfig;
      await this.saveConfigs();
      
      return mergedConfig;
    } catch (error) {
      // No local config, check stored configs
      if (this.projectConfigs.has(projectId)) {
        this.currentProject = this.projectConfigs.get(projectId);
        return this.currentProject;
      }
      
      // Create default config for new project
      return this.createDefaultConfig(cwd);
    }
  }

  /**
   * Create default configuration for a new project
   */
  async createDefaultConfig(projectPath) {
    const projectName = path.basename(projectPath);
    const projectId = this.getProjectId(projectPath);
    
    const config = {
      projectId,
      projectPath,
      projectName,
      botNames: ['@Claude', `@${projectName}-bot`, '@Assistant'],
      botPatterns: [
        /@Claude\b/i,
        new RegExp(`@${projectName}-bot\\b`, 'i'),
        /@Assistant\b/i,
        /hey claude/i,
        /claude[,:]?\s+/i
      ],
      slackWorkspace: null,
      channels: {
        monitored: [],
        ignored: [],
        priority: []
      },
      responseSettings: {
        style: 'professional',
        personality: 'helpful',
        signatureEnabled: true,
        signature: `- Claude (${projectName} Assistant)`
      },
      dataStorage: {
        cacheDir: path.join(projectPath, '.claude', 'cache', 'slack'),
        metricsDir: path.join(projectPath, '.claude', 'metrics', 'slack'),
        learningDir: path.join(projectPath, '.claude', 'learning', 'slack'),
        logsDir: path.join(projectPath, '.claude', 'logs', 'slack')
      },
      features: {
        caching: true,
        learning: true,
        escalation: true,
        rateLimiting: true,
        metrics: true,
        autoScheduling: false
      },
      escalationTeam: this.getDefaultEscalationTeam(projectName),
      created: new Date().toISOString(),
      lastUpdated: new Date().toISOString()
    };
    
    // Save the config
    this.projectConfigs.set(projectId, config);
    this.currentProject = config;
    await this.saveConfigs();
    
    // Create local config file
    await this.createLocalConfig(projectPath, config);
    
    return config;
  }

  /**
   * Create local configuration file in project
   */
  async createLocalConfig(projectPath, config) {
    const localConfigPath = path.join(projectPath, '.claude-slack.json');
    
    // Create a subset of config for local storage
    const localConfig = {
      projectName: config.projectName,
      botNames: config.botNames,
      botPatterns: config.botPatterns.map(p => p.toString()),
      channels: config.channels,
      responseSettings: config.responseSettings,
      features: config.features
    };
    
    try {
      await fs.writeFile(localConfigPath, JSON.stringify(localConfig, null, 2));
      console.log(`Created local Slack config at ${localConfigPath}`);
    } catch (error) {
      console.error('Failed to create local config:', error);
    }
  }

  /**
   * Get default escalation team based on project
   */
  getDefaultEscalationTeam(projectName) {
    // Different default teams for different projects
    const teams = {
      'SoftTrak': {
        technical_lead: { id: 'U09DG14100L', name: 'Arlen' },
        qa_lead: { id: 'U09CZRG55AT', name: 'Ed' }
      },
      'default': {
        technical_lead: { id: null, name: 'Tech Lead' },
        qa_lead: { id: null, name: 'QA Lead' },
        product_manager: { id: null, name: 'Product Manager' }
      }
    };
    
    return teams[projectName] || teams.default;
  }

  /**
   * Update bot names for current project
   */
  async updateBotNames(botNames) {
    if (!this.currentProject) {
      await this.detectCurrentProject();
    }
    
    this.currentProject.botNames = botNames;
    this.currentProject.botPatterns = botNames.map(name => 
      new RegExp(name.replace('@', '@?'), 'i')
    );
    this.currentProject.lastUpdated = new Date().toISOString();
    
    await this.saveConfigs();
    await this.createLocalConfig(this.currentProject.projectPath, this.currentProject);
    
    return this.currentProject;
  }

  /**
   * Get data directory for current project
   */
  getDataDirectory(dataType) {
    if (!this.currentProject) {
      throw new Error('No project detected. Call detectCurrentProject() first.');
    }
    
    const dataTypes = {
      cache: this.currentProject.dataStorage.cacheDir,
      metrics: this.currentProject.dataStorage.metricsDir,
      learning: this.currentProject.dataStorage.learningDir,
      logs: this.currentProject.dataStorage.logsDir
    };
    
    return dataTypes[dataType] || this.currentProject.dataStorage.cacheDir;
  }

  /**
   * Check if a message mentions the bot
   */
  isBotMentioned(message) {
    if (!this.currentProject) {
      return false;
    }
    
    // Check bot patterns
    for (const pattern of this.currentProject.botPatterns) {
      const regex = typeof pattern === 'string' ? new RegExp(pattern) : pattern;
      if (regex.test(message)) {
        return true;
      }
    }
    
    // Check bot names (exact match)
    for (const name of this.currentProject.botNames) {
      if (message.includes(name)) {
        return true;
      }
    }
    
    return false;
  }

  /**
   * Get project-specific configuration
   */
  getConfig(key) {
    if (!this.currentProject) {
      return null;
    }
    
    const keys = key.split('.');
    let value = this.currentProject;
    
    for (const k of keys) {
      value = value[k];
      if (value === undefined) {
        return null;
      }
    }
    
    return value;
  }

  /**
   * Set project-specific configuration
   */
  async setConfig(key, value) {
    if (!this.currentProject) {
      await this.detectCurrentProject();
    }
    
    const keys = key.split('.');
    let obj = this.currentProject;
    
    for (let i = 0; i < keys.length - 1; i++) {
      if (!obj[keys[i]]) {
        obj[keys[i]] = {};
      }
      obj = obj[keys[i]];
    }
    
    obj[keys[keys.length - 1]] = value;
    this.currentProject.lastUpdated = new Date().toISOString();
    
    await this.saveConfigs();
    await this.createLocalConfig(this.currentProject.projectPath, this.currentProject);
    
    return this.currentProject;
  }

  /**
   * List all configured projects
   */
  listProjects() {
    const projects = [];
    
    for (const [projectId, config] of this.projectConfigs) {
      projects.push({
        projectId,
        projectName: config.projectName,
        projectPath: config.projectPath,
        botNames: config.botNames,
        created: config.created,
        lastUpdated: config.lastUpdated
      });
    }
    
    return projects;
  }

  /**
   * Export configuration for current project
   */
  exportConfig() {
    if (!this.currentProject) {
      return null;
    }
    
    return {
      ...this.currentProject,
      exported: new Date().toISOString()
    };
  }

  /**
   * Import configuration for a project
   */
  async importConfig(projectPath, configData) {
    const projectId = this.getProjectId(projectPath);
    
    const config = {
      ...configData,
      projectId,
      projectPath,
      imported: new Date().toISOString(),
      lastUpdated: new Date().toISOString()
    };
    
    this.projectConfigs.set(projectId, config);
    await this.saveConfigs();
    await this.createLocalConfig(projectPath, config);
    
    return config;
  }

  /**
   * Initialize data directories for current project
   */
  async initializeDataDirectories() {
    if (!this.currentProject) {
      await this.detectCurrentProject();
    }
    
    const dirs = Object.values(this.currentProject.dataStorage);
    
    for (const dir of dirs) {
      try {
        await fs.mkdir(dir, { recursive: true });
      } catch (error) {
        console.error(`Failed to create directory ${dir}:`, error);
      }
    }
    
    return this.currentProject.dataStorage;
  }
}

module.exports = SlackProjectConfig;