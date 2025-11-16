#!/usr/bin/env python3
"""
Base Extension Interface for Task Wrap-Up Skill

Defines the common interface that all extensions must implement.
"""

from typing import Dict, List, Any
from abc import ABC, abstractmethod


class Extension(ABC):
    """Base class for task-wrapup extensions."""

    def __init__(self, config: Dict[str, Any]):
        """Initialize extension with configuration.

        Args:
            config: Full configuration dictionary
        """
        self.config = config
        self.enabled = False

    @abstractmethod
    def validate_config(self) -> tuple[bool, List[str]]:
        """Validate extension configuration.

        Returns:
            Tuple of (is_valid, error_messages)
        """
        pass

    @abstractmethod
    def execute(self, summary: Dict[str, Any]) -> Dict[str, Any]:
        """Execute extension action.

        Args:
            summary: Generated summary with full_summary, concise_summary, etc.

        Returns:
            Dictionary with:
            - status: "success" | "error" | "skipped"
            - message: Description of result
            - details: Extension-specific details (optional)
        """
        pass

    @abstractmethod
    def get_name(self) -> str:
        """Return extension name for display."""
        pass

    @abstractmethod
    def get_description(self) -> str:
        """Return extension description."""
        pass

    def is_enabled(self) -> bool:
        """Check if extension is enabled."""
        return self.enabled
