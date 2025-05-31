# DRAXUI Changelog

## [1.1.0] - Executor Compatibility Update

### Added
- Compatibility with multiple Roblox executors (Xeno, AWP, Synapse X, KRNL, ScriptWare, etc.)
- Automatic executor detection system
- Protected GUI handling for different exploit environments
- Loadstring support for easy implementation in exploit scripts
- Global instance access for exploit scripts
- New ExecutorInfo property to check current environment
- Example exploit script demonstrating usage in executor environments

## Version 1.1.0 (Feature Update)

### Added
- New UI components:
  - InputBox for text entry with focus effects and validation
  - Accordion for collapsible sections with animated transitions
  - GridLayout for organizing elements in customizable columns
  - SearchBar with dynamic filtering and results display
- Visual enhancements:
  - Gradient backgrounds for UI elements
  - Drop shadows for depth effect
  - Ripple effects for interactive elements
  - Watermark display with customization options
  - Blur effect for improved focus on active windows
  - Enhanced particle system with varied sizes, colors, and pulsing animations
- Window improvements:
  - Close and minimize buttons with hover effects
  - Smooth animations for opening/closing windows
  - Theme presets (Dark, Light, Neon) with easy switching
  - Improved window dragging with position memory
- Sound effects for interactions:
  - Click, hover, toggle, notification, and error sounds
  - Volume and playback speed control
  - Option to disable sounds

### Changed
- Enhanced window management system
- Improved theme system with gradient support and additional colors
- Better handling of user settings with deep merging
- More natural and varied particle movement
- Optimized rendering performance for complex UIs
- Increased default particle count for better visual effect
- Changed default font to GothamSemibold for better readability

### Fixed
- Z-index issues with multiple windows
- Animation timing inconsistencies
- Element positioning in complex layouts
- Window dragging behavior at screen edges
- Particle rendering optimization

## Version 1.0.0 (Initial Release)

### Added
- Initial release of DRAXUI Library
- Core UI components:
  - Windows with draggable title bars
  - Tabs for organized content
  - Buttons with hover effects
  - Toggles for boolean settings
  - Dropdowns for selection menus
  - Sliders for numeric input
  - Keybinds for custom shortcuts
- New components:
  - Text Labels for displaying information
  - Separators for visual organization
  - Tooltips for additional information on hover
  - Notifications system with different types (info, success, warning, error)
  - Color Picker for selecting colors
  - Progress Bars for displaying progress
- Animated background particles
- Customizable themes and appearance
- Immediate-mode GUI paradigm
- Comprehensive documentation and examples

### Changed
- Renamed from ShiUI to DRAXUI
- Improved code organization and structure
- Enhanced theme system with additional colors (error, success, warning)

### Fixed
- Various minor bugs and issues

## Future Plans

### Planned for Version 1.2.0
- Data visualization components (charts, graphs)
- Table component with sorting and filtering
- Context menus and right-click functionality
- Drag and drop between elements
- Responsive design for different screen sizes
- Performance optimizations for large UIs
- Advanced animation system with custom easing
- Localization support for multiple languages
