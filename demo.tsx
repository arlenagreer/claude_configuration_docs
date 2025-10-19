import React from 'react';
import GitHubIssueForm from './GitHubIssueForm';

/**
 * Demo page showcasing the GitHub Issue Form component
 * This demonstrates how to integrate the component into a Next.js application
 */
const DemoPage: React.FC = () => {
  const handleFormSubmit = (data: any) => {
    console.log('Form submitted with data:', data);
    
    // In a real application, you would submit this data to GitHub's API
    // Example API call:
    /*
    const submitToGitHub = async (issueData) => {
      try {
        const response = await fetch('/api/github/issues', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `token ${process.env.GITHUB_TOKEN}`,
          },
          body: JSON.stringify({
            title: issueData.title,
            body: issueData.description,
            labels: issueData.labels,
            assignees: issueData.assignees,
          }),
        });
        
        if (response.ok) {
          const issue = await response.json();
          console.log('Issue created:', issue);
          return issue;
        } else {
          throw new Error('Failed to create issue');
        }
      } catch (error) {
        console.error('Error creating issue:', error);
        throw error;
      }
    };
    */
  };

  return (
    <div className="min-h-screen">
      <GitHubIssueForm onSubmit={handleFormSubmit} />
      
      {/* Optional: Add a header or footer */}
      <div className="fixed top-4 left-4 z-10 text-white/60 text-sm">
        <p>Demo: Advanced GitHub Issue Form</p>
        <p>Built with React, TypeScript & Framer Motion</p>
      </div>
    </div>
  );
};

export default DemoPage;

// Example usage in a Next.js page
/*
// pages/index.tsx or app/page.tsx
import DemoPage from '../components/demo';

export default function HomePage() {
  return <DemoPage />;
}
*/

// Example API route for GitHub integration
/*
// pages/api/github/issues.ts or app/api/github/issues/route.ts
import { NextApiRequest, NextApiResponse } from 'next';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Method not allowed' });
  }

  try {
    const { title, body, labels, assignees } = req.body;
    
    const response = await fetch(`https://api.github.com/repos/{owner}/{repo}/issues`, {
      method: 'POST',
      headers: {
        'Authorization': `token ${process.env.GITHUB_TOKEN}`,
        'Content-Type': 'application/json',
        'Accept': 'application/vnd.github.v3+json',
      },
      body: JSON.stringify({
        title,
        body,
        labels,
        assignees,
      }),
    });

    if (response.ok) {
      const issue = await response.json();
      res.status(201).json(issue);
    } else {
      const error = await response.json();
      res.status(response.status).json(error);
    }
  } catch (error) {
    console.error('Error creating GitHub issue:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
}
*/