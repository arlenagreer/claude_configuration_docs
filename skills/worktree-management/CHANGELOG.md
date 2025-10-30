# Worktree Management Skill - Changelog

## 2025-10-23 - CORS Auto-Configuration

### Enhancement: Automatic CORS Configuration for Worktree Frontend Ports

**Problem Solved:**
When creating new worktrees with different frontend ports, users encountered CORS errors when trying to log in or make API calls because the backend's CORS configuration didn't include the worktree's frontend port.

**Solution Implemented:**
The worktree creation process now automatically configures CORS to whitelist the worktree's frontend port in two locations:

1. **`backend/.env` Updates:**
   - Automatically adds the worktree frontend port to `ALLOWED_ORIGINS`
   - Creates `ALLOWED_ORIGINS` with sensible defaults if it doesn't exist
   - Checks for existing port before adding (idempotent)

2. **`backend/config/initializers/cors.rb` Updates:**
   - Adds worktree frontend port to development defaults array
   - Updates fallback configuration for when no environment variable is set
   - Ensures immediate functionality without manual configuration

**Example:**
For a worktree with frontend port 4004:
- `.env`: `ALLOWED_ORIGINS=http://localhost:4000,...,http://localhost:4004`
- `cors.rb`: `allowed_origins = ["http://localhost:4000", ..., "http://localhost:4004"]`

**Benefits:**
- ✅ Login works immediately in new worktrees
- ✅ API calls succeed without CORS errors
- ✅ No manual CORS configuration required
- ✅ Each worktree is isolated but properly configured
- ✅ Prevents wasted debugging time on CORS issues

**Files Modified:**
- `scripts/worktree-manager.sh` - Added CORS configuration logic (lines 520-554)
- `SKILL.md` - Added CORS Configuration section and updated Safety Features

**Technical Details:**
- Configuration happens during `.env` file copying phase
- Uses `sed` for in-place modifications with backup cleanup
- Checks for existing configuration to avoid duplicates
- Provides clear console feedback during creation process
- Gracefully handles missing files with warnings

---

## Previous Changes

See Git history for previous worktree management skill updates.
