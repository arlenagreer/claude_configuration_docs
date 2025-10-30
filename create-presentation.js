const pptxgen = require('pptxgenjs');
const html2pptx = require('/Users/arlenagreer/.claude/plugins/marketplaces/anthropic-agent-skills/document-skills/pptx/scripts/html2pptx.js');

async function createPresentation() {
  const pptx = new pptxgen();
  pptx.layout = 'LAYOUT_16x9';
  pptx.author = 'SuperClaude';
  pptx.title = 'AI Agent Workflows Demo';

  // Slide 1: Title
  await html2pptx('slide1.html', pptx);

  // Slide 2: Frontend-QC Demo
  await html2pptx('slide2.html', pptx);

  // Slide 3: After GitHub Issues
  await html2pptx('slide3.html', pptx);

  // Slide 4: SuperClaude Framework
  await html2pptx('slide4.html', pptx);

  // Slide 5: Alternative Frameworks
  await html2pptx('slide5.html', pptx);

  // Slide 6: AWS Implementation
  await html2pptx('slide6.html', pptx);

  // Save presentation
  await pptx.writeFile({ fileName: 'AI-Agent-Workflows.pptx' });
  console.log('Presentation created: AI-Agent-Workflows.pptx');
}

createPresentation().catch(console.error);
