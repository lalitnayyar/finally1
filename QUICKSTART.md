# FinAlly Project - Quick Start

## Overview
FinAlly is a comprehensive financial analysis platform with:
- **Backend**: Python-based market data processing
- **Workflow**: Automated GitHub PR management  
- **Documentation**: Complete project planning and reviews

## Quick Commands

### Git Workflow
```bash
# Create new feature PR
pr-workflow.bat create

# Check repository status
pr-workflow.bat status  

# Merge approved PR
pr-workflow.bat merge

# Get help
pr-workflow.bat help
```

### Backend Development
```bash
cd backend
python -m pytest tests/    # Run tests
python market_data_demo.py # Run demo
```

## Project Structure
- `backend/` - Python market data processing
- `planning/` - Project documentation 
- `scripts/` - GitHub workflow automation
- `pr-workflow.bat` - Main workflow interface

## Documentation
- [Setup Complete](SETUP_COMPLETE.md) - Recent setup summary
- [GitHub Workflow](GITHUB_WORKFLOW.md) - Detailed workflow guide  
- [Project Plan](planning/PLAN.md) - Development roadmap

---
*Generated: $(Get-Date)*