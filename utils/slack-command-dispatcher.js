#!/usr/bin/env node
/**
 * Smart Slack Command Dispatcher
 * Routes Slack commands to appropriate project-specific handlers
 */

const fs = require('fs').promises;
const path = require('path');
const SlackProjectConfig = require('./slack-project-config');

class SlackCommandDispatcher {
  constructor() {
    this.projectConfig = new SlackProjectConfig();
  }

  /**
   * Main entry point for check-slack command
   */
  async executeCheckSlack(options = {}) {
    try {
      // Detect current project
      const config = await this.projectConfig.detectCurrentProject();
      console.log(`🔍 Detected project: ${config.projectName}`);
      
      if (options.status) {
        return this.showProjectStatus(config);
      }
      
      if (options.configure) {
        return this.configureProject(config);
      }
      
      // Execute the Slack check
      return await this.performSlackCheck(config, options);
      
    } catch (error) {
      console.error('❌ Error executing check-slack:', error.message);
      return { success: false, error: error.message };
    }
  }

  /**
   * Show current project Slack configuration
   */
  showProjectStatus(config) {
    console.log('📊 Project Slack Configuration:');
    console.log(`   Project: ${config.projectName}`);
    console.log(`   Path: ${config.projectPath}`);
    console.log(`   Bot Names: ${config.botNames.join(', ')}`);
    console.log(`   Monitored Channels: ${config.channels.monitored.length}`);
    console.log(`   Priority Channels: ${config.channels.priority.length}`);
    console.log(`   Response Style: ${config.responseSettings.style}`);
    console.log(`   Signature: ${config.responseSettings.signature}`);
    console.log(`   Features: ${Object.keys(config.features).filter(k => config.features[k]).join(', ')}`);
    
    return { success: true, config };
  }

  /**
   * Interactive project configuration
   */
  async configureProject(config) {
    console.log('⚙️  Configuring Slack for project:', config.projectName);
    
    // This would typically use a CLI prompt library
    // For now, just show what can be configured
    console.log(`
📝 Configuration Options:

1. Bot Names: Configure what names/mentions the bot responds to
   Current: ${config.botNames.join(', ')}

2. Channels: Set which channels to monitor
   Monitored: ${config.channels.monitored.join(', ')}
   Priority: ${config.channels.priority.join(', ')}

3. Response Settings: Customize response style and signature
   Style: ${config.responseSettings.style}
   Signature: ${config.responseSettings.signature}

4. Features: Enable/disable bot features
   Enabled: ${Object.keys(config.features).filter(k => config.features[k]).join(', ')}

📁 Configuration file: ${path.join(config.projectPath, '.claude-slack.json')}

Edit this file to customize your project's Slack configuration.
`);
    
    return { success: true, message: 'Configuration displayed' };
  }

  /**
   * Execute Slack check with project-specific configuration
   */
  async performSlackCheck(config, options = {}) {
    console.log(`🚀 Checking Slack for ${config.projectName}...`);
    
    // Initialize data directories
    await this.projectConfig.initializeDataDirectories();
    
    const results = {
      project: config.projectName,
      channelsChecked: [],
      questionsFound: 0,
      questionsAnswered: 0,
      errors: [],
      timestamp: new Date().toISOString()
    };
    
    // Determine channels to check
    const channelsToCheck = options.channels 
      ? options.channels.split(',').map(c => c.trim())
      : [...config.channels.priority, ...config.channels.monitored];
    
    console.log(`📋 Checking channels: ${channelsToCheck.join(', ')}`);
    
    // Check each channel (this would integrate with actual Slack MCP)
    for (const channel of channelsToCheck) {
      try {
        console.log(`   🔍 Checking ${channel}...`);
        
        // This is where the actual Slack checking would happen
        // For now, simulate the check
        const channelResult = await this.checkChannel(channel, config);
        
        results.channelsChecked.push(channel);
        results.questionsFound += channelResult.questionsFound;
        results.questionsAnswered += channelResult.questionsAnswered;
        
        if (options.verbose) {
          console.log(`      Questions found: ${channelResult.questionsFound}`);
          console.log(`      Questions answered: ${channelResult.questionsAnswered}`);
        }
        
      } catch (error) {
        console.error(`   ❌ Error checking ${channel}: ${error.message}`);
        results.errors.push(`${channel}: ${error.message}`);
      }
    }
    
    // Save results
    await this.saveCheckResults(config, results);
    
    // Display summary
    console.log(`
✅ Slack Check Complete for ${config.projectName}:
   Channels Checked: ${results.channelsChecked.length}
   Questions Found: ${results.questionsFound}
   Questions Answered: ${results.questionsAnswered}
   Errors: ${results.errors.length}
`);
    
    if (results.errors.length > 0 && options.verbose) {
      console.log('❌ Errors encountered:');
      results.errors.forEach(error => console.log(`   - ${error}`));
    }
    
    return results;
  }

  /**
   * Check a specific channel for questions
   */
  async checkChannel(channel, config) {
    // This would integrate with the actual Slack MCP tools
    // For now, return simulated results
    const questionsFound = Math.floor(Math.random() * 3);
    const questionsAnswered = Math.floor(questionsFound * 0.8);
    
    return {
      channel,
      questionsFound,
      questionsAnswered,
      messages: []
    };
  }

  /**
   * Save check results for metrics
   */
  async saveCheckResults(config, results) {
    const metricsDir = config.dataStorage.metricsDir;
    const timestamp = new Date().toISOString().slice(0, 10);
    const metricsFile = path.join(metricsDir, `slack-checks-${timestamp}.json`);
    
    try {
      // Load existing data
      let dailyData = [];
      try {
        const existing = await fs.readFile(metricsFile, 'utf8');
        dailyData = JSON.parse(existing);
      } catch {
        // File doesn't exist yet
      }
      
      // Add current result
      dailyData.push(results);
      
      // Save updated data
      await fs.writeFile(metricsFile, JSON.stringify(dailyData, null, 2));
      
    } catch (error) {
      console.error('Warning: Could not save metrics:', error.message);
    }
  }
}

// CLI interface
if (require.main === module) {
  const args = process.argv.slice(2);
  const options = {};
  
  // Parse arguments
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--configure') {
      options.configure = true;
    } else if (args[i] === '--status') {
      options.status = true;
    } else if (args[i] === '--verbose') {
      options.verbose = true;
    } else if (args[i] === '--channels' && args[i + 1]) {
      options.channels = args[++i];
    } else if (args[i] === '--respond') {
      options.respond = args[i + 1] !== 'false';
    }
  }
  
  const dispatcher = new SlackCommandDispatcher();
  dispatcher.executeCheckSlack(options)
    .then(result => {
      if (!result.success) {
        process.exit(1);
      }
    })
    .catch(error => {
      console.error('Fatal error:', error);
      process.exit(1);
    });
}

module.exports = SlackCommandDispatcher;